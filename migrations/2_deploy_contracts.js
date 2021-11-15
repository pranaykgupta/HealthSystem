var HealthSystem = artifacts.require("./HealthSystem.sol");

module.exports = function(deployer) {
  deployer.deploy(HealthSystem);
};
