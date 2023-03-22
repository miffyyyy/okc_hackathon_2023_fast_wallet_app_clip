const MifToken = artifacts.require("MifToken");

module.exports = function (deployer) {
  deployer.deploy(MifToken);
};
