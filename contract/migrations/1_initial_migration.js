const MifToken = artifacts.require("MifToken");

module.exports = (deployer) => {
    deployer.deploy(MifToken);
};

