import { network } from "hardhat";
import { expect } from "chai";

const { ethers, networkHelpers } = await network.connect();

async function getTime() {
  const connection = await network.connect();
  return connection.networkHelpers.time;
}

async function setTimeAfterDeadline(deadline: bigint) {
  const time = await getTime();
  const currentTime = await time.latest();
  const diff = deadline - BigInt(currentTime);
  if (diff > 0) {
    await ethers.provider.send("evm_increaseTime", [(diff + 1n).toString()]);
    await ethers.provider.send("evm_mine", []);
  }
}

function abs(number: bigint) {
  if (number < 0n) return -number;
  return number;
}

function Log(message: string) {
  console.log(`>>>: ${message}`);
}

describe("CrowdFundingCampaign", () => {
  const CAMPAIGN_NAME = "测试众筹活动";
  const GOAL = ethers.parseEther("10");
  const DURATION_DAYS = 7;

  async function deploy() {
    console.log(">>>: 初始化环境");
    const [owner, contributor1, contributor2, contributor3] =
      await ethers.getSigners();

    console.log(`>>>: [部署]
    - 发起人: ${owner.address}
    - 项目名称: ${CAMPAIGN_NAME}
    - 目标金额: ${GOAL}
    - 持续时间: ${DURATION_DAYS} 天
    `);

    const campaignFactory = await ethers.getContractFactory(
      "CrowdFundingCampaign",
    );
    const campaign = await campaignFactory.deploy(
      owner,
      CAMPAIGN_NAME,
      GOAL,
      DURATION_DAYS,
    );

    await campaign.waitForDeployment();
    const address = await campaign.getAddress();
    console.log(`>>>: [部署完成]
    - 合约地址: ${address}
    `);
    return {
      campaign,
      owner,
      contributor1,
      contributor2,
      contributor3,
      address
    };
  }

  describe("Deployment", () => {
    it("Should deploy with correct initial state", async () => {
      const { campaign, owner } = await networkHelpers.loadFixture(deploy);
      const state = await campaign.state();
      const _owner = await campaign.owner();
      const _goal = await campaign.goal();
      const _totalRaised = await campaign.totalRaised();

      expect(state).to.equal(0);
      expect(_owner).to.equal(owner.address);
      expect(_goal).to.equal(GOAL);
      expect(_totalRaised).to.equal(0n);

      console.log(`>>>: [initState] ok`);
    });

    it("Should set the correct deadline", async () => {
      const { campaign } = await networkHelpers.loadFixture(deploy);
      const deadline = await campaign.deadline();
      const time = await getTime();
      const currentTime = await time.latest();
      const expectedDeadline =
        BigInt(currentTime) + BigInt(DURATION_DAYS * 24 * 60 * 60);

      const diff = abs(expectedDeadline - deadline);

      // allow 5 secs tolerance
      expect(diff).to.be.at.most(5);
      console.log(`>>>: [deadline] ok`);
    });

    it("should reject when params is invalid", async () => {
      const { campaign, owner } = await networkHelpers.loadFixture(deploy);

      console.log(`验证无效构建参数`);
      const factory = await ethers.getContractFactory("CrowdFundingCampaign");
      console.log(">>>: 测试零地址");
      await expect(
        factory.deploy(ethers.ZeroAddress, CAMPAIGN_NAME, GOAL, DURATION_DAYS),
      ).to.be.revertedWith("CrowdfundingCampaign: invalid owner");

      console.log(`>>>: 验证空名字`);
      await expect(
        factory.deploy(owner.address, "", GOAL, DURATION_DAYS),
      ).to.be.revert(ethers);
      console.log(`>>>: 验证金额>0`);
      await expect(
        factory.deploy(owner.address, CAMPAIGN_NAME, 0n, DURATION_DAYS),
      ).to.be.revertedWith("CrowdfundingCampaign: goal must be positive");
      console.log(`>>>: 验证过期时间`);
      await expect(
        factory.deploy(owner.address, CAMPAIGN_NAME, 10n, 91n),
      ).to.be.revert(ethers);
    });
  });

  describe("state transitions", async () => {
    it("state should be active", async () => {
      const { campaign, owner, contributor1 } =
        await networkHelpers.loadFixture(deploy);
      const stateInit = await campaign.state();
      expect(stateInit).to.equal(0n);
      Log("状态为Preparing");

      await campaign.start();
      const stateStart = await campaign.state();
      expect(stateStart).to.equal(1n);
      Log("状态为Active");

      await expect(campaign.connect(contributor1).start()).to.be.revertedWith(
        "CrowdfundingCampaign: not owner",
      );
      Log("only owner");

      await expect(campaign.start()).to.be.revert(ethers);
      Log("已启动的项目不能再次启");

      await expect(campaign.finalize()).to.be.revert(ethers);
      Log("项目截止前不能关闭");

      await campaign.connect(contributor1).contribute({ value: GOAL });
      const stateSuccess = await campaign.state();
      expect(stateSuccess).to.equal(2n);
      Log("项目success");
    });

    it("state should be 3=fail", async () => {
      const { campaign } = await networkHelpers.loadFixture(deploy);
      await campaign.start();
      const deadline = await campaign.deadline();
      await setTimeAfterDeadline(deadline);
      await campaign.finalize();
      const state = await campaign.state();
      expect(state).to.equal(3n);
      Log("项目筹集失败");
    });

    it("state should be 4=closed", async () => {
      const { campaign, contributor1 } = await networkHelpers.loadFixture(deploy);
      const dealine = await campaign.deadline();
      await campaign.start()
      await campaign.connect(contributor1).contribute({ value: GOAL })
      await setTimeAfterDeadline(dealine);
      await campaign.finalize();
      const finalState = await campaign.state();
      expect(finalState).to.be.equal(2n);
      Log("项目状态: 关闭");
    });

    it('contribute mutiple times', async() => {
      const { campaign, contributor1, contributor2 } = await networkHelpers.loadFixture(deploy)
      await campaign.start()
      await campaign.connect(contributor1).contribute({ value: ethers.parseEther('2') })
      await campaign.connect(contributor1).contribute({ value: ethers.parseEther('3') })
      let amount = await campaign.contributions(contributor1.address)
      let total = await campaign.totalRaised()
      expect(ethers.formatEther(amount)).to.equal('5.0')
      expect(ethers.formatEther(total)).to.equal('5.0')

      await campaign.connect(contributor2).contribute({ value: ethers.parseEther('3')})
      total = await campaign.totalRaised()
      expect(ethers.formatEther(total)).to.equal('8.0')

    })
  });
});
