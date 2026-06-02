import hre from "hardhat";

async function main() {
  const { ethers } = await hre.network.connect();
  const [deployer] = await ethers.getSigners();
  const network = await ethers.provider.getNetwork();
  const chainId = Number(network.chainId);
  const networkName = chainId === 59141 ? "Linea" : chainId === 84532 ? "Base" : `Chain ${chainId}`;
  console.log(`Deploying to ${networkName} Sepolia (chainId: ${chainId})...`);
  console.log(`Deployer: ${deployer.address}`);
  const contracts = {};

  const SeverityCalculatorArtifact = await hre.artifacts.readArtifact("SeverityCalculator");
  const scFactory = new ethers.ContractFactory(SeverityCalculatorArtifact.abi, SeverityCalculatorArtifact.bytecode, deployer);
  const severityCalculator = await scFactory.deploy();
  await severityCalculator.waitForDeployment();
  contracts.SeverityCalculator = await severityCalculator.getAddress();
  console.log(`  SeverityCalculator: ${contracts.SeverityCalculator}`);

  const BugBountyPlatformArtifact = await hre.artifacts.readArtifact("BugBountyPlatform");
  const bbpFactory = new ethers.ContractFactory(BugBountyPlatformArtifact.abi, BugBountyPlatformArtifact.bytecode, deployer);
  const bugBountyPlatform = await bbpFactory.deploy(deployer.address, contracts.SeverityCalculator);
  await bugBountyPlatform.waitForDeployment();
  contracts.BugBountyPlatform = await bugBountyPlatform.getAddress();
  console.log(`  BugBountyPlatform: ${contracts.BugBountyPlatform}`);

  const baseUrl = chainId === 59141 ? "https://sepolia.lineascan.build" : "https://sepolia.basescan.org";
  console.log(`\nVerify on ${networkName} Explorer:`);
  for (const [name, addr] of Object.entries(contracts)) {
    console.log(`  ${name}: ${baseUrl}/address/${addr}`);
  }
  console.log(JSON.stringify({ network: `${networkName.toLowerCase()}_sepolia`, chainId, deployer: deployer.address, contracts }, null, 2));
}

main().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });