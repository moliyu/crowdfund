import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("CrowdFundingFactory", (m) => {
  const factory = m.contract("CrowdFundingFactory");
  return { factory };
});
