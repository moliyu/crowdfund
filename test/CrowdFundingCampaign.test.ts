import { network } from "hardhat";
import { expect } from "chai";

const { ethers, networkHelpers } = await network.connect()

async function getTime() {
  const connection = await network.connect();
  return connection.networkHelpers.time;
}

function abs(number: bigint) {
  if (number < 0n) return -number;
  return number
}

async function Deploy() {

}

describe('CrowdFundingCampaign', () => {

  const CAMPAIGN_NAME = '测试众筹活动'
  const GOAL = ethers.parseEther("10")
  const DURATION_DAYS = 7

  async function deploy() {
    console.log('>>>: 初始化环境');
    const [owner, contributor1, contributor2, contributor3] = await ethers.getSigners();

    console.log(`>>>: [部署]
    - 发起人: ${owner.address}
    - 项目名称: ${CAMPAIGN_NAME}
    - 目标金额: ${GOAL}
    - 持续时间: ${DURATION_DAYS} 天
    `);

    const campaignFactory = await ethers.getContractFactory('CrowdFundingCampaign')
    const campaign = await campaignFactory.deploy(owner, CAMPAIGN_NAME, GOAL, DURATION_DAYS)
    
    await campaign.waitForDeployment()
    const address = await campaign.getAddress()
    console.log(`>>>: [部署完成]
    - 合约地址: ${address}
    `)
    return {
      campaign,
      owner,
      contributor1,
      contributor2,
      contributor3
    }
  }


  describe('Deployment', () => {
    it('Should deploy with correct initial state', async () => {
      const { campaign, owner } = await networkHelpers.loadFixture(deploy)
      const state = await campaign.state()
      const _owner = await campaign.owner()
      const _goal = await campaign.goal()
      const _totalRaised = await campaign.totalRaised()

      expect(state).to.equal(0)
      expect(_owner).to.equal(owner.address)
      expect(_goal).to.equal(GOAL)
      expect(_totalRaised).to.equal(0n)

      console.log(`>>>: [initState] ok`)
    })

    it('Should set the correct deadline', async () => {
      const { campaign } = await networkHelpers.loadFixture(deploy)
      const deadline = await campaign.deadline()
      const time = await getTime()
      const currentTime = await time.latest()
      const expectedDeadline = BigInt(currentTime) + BigInt(DURATION_DAYS * 24 * 60 * 60)

      const diff = abs(expectedDeadline - deadline)

      // allow 5 secs tolerance
      expect(diff).to.be.at.most(5)
      console.log(`>>>: [deadline] ok`)
    })

    it('should reject when params is invalid', async () => {
      const { campaign, owner } = await networkHelpers.loadFixture(deploy)

      console.log(`验证无效构建参数`)
      const factory = await ethers.getContractFactory('CrowdFundingCampaign')
      console.log('>>>: 测试零地址')
      await expect(factory.deploy(ethers.ZeroAddress, CAMPAIGN_NAME, GOAL, DURATION_DAYS)).to.be.revertedWith('CrowdfundingCampaign: invalid owner')

      console.log(`>>>: 验证空名字`)
      await expect(factory.deploy(owner.address, '', GOAL, DURATION_DAYS)).to.be.revert(ethers)
      console.log(`>>>: 验证金额>0`)
      await expect(factory.deploy(owner.address, CAMPAIGN_NAME, 0n, DURATION_DAYS)).to.be.revertedWith('CrowdfundingCampaign: goal must be positive')
      console.log(`>>>: 验证过期时间`)
      await expect(factory.deploy(owner.address, CAMPAIGN_NAME, 10n, 91n)).to.be.revert(ethers)
    })

  })
})