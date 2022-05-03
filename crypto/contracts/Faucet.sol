// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

contract Faucet is AccessControlUpgradeable {
    bytes32 private FAUCET_ROLE;

    uint256 public totalLimit;
    uint256 public singleCallValue;
    bool public opened;
    mapping(address => uint256) public lockTime;
    mapping(address => uint256) public totalRequested;

    /**
     * @dev initializer.
     * @param _faucetAccount address of faucet calling account
     * @param _totalLimit limit for single address
     * @param _singleCallValue single call faucet value
     */
    function initialize(
        address _faucetAccount,
        uint256 _totalLimit,
        uint256 _singleCallValue
    ) external initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        FAUCET_ROLE = bytes32(0x0000000000000000000000000000000000000000000000000000000000000001);
        if (_faucetAccount != address(0)) {
            _grantRole(FAUCET_ROLE, _faucetAccount);
        }
        totalLimit = _totalLimit;
        singleCallValue = _singleCallValue;
        opened = true;
    }

    /// @dev supports interface for inheritance conflict resolving.
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AccessControlUpgradeable) returns (bool) {
        return
        interfaceId == type(IAccessControlUpgradeable).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /**
     * @dev faucet.
     * @param to address of receiver
     */
    function faucet(address payable to) external onlyRole(FAUCET_ROLE) {
        require(opened, "Faucet: closed");
        require(totalRequested[to] + singleCallValue <= totalLimit, "Faucet: limit reached");
        require(block.timestamp > lockTime[to], "Faucet: lock time has not expired");
        require(address(this).balance >= singleCallValue, "Faucet: insufficient funds");

        to.transfer(singleCallValue);
        totalRequested[to] += singleCallValue;
        lockTime[to] = block.timestamp + 1 days;
    }

    /**
     * @dev setTotalLimit.
     * @param _totalLimit new limit for single address
     */
    function setTotalLimit(uint256 _totalLimit) external onlyRole(DEFAULT_ADMIN_ROLE) {
        totalLimit = _totalLimit;
    }

    /**
     * @dev setSingleCallValue.
     * @param _singleCallValue new value for single faucet call
     */
    function setSingleCallValue(uint256 _singleCallValue) external onlyRole(DEFAULT_ADMIN_ROLE) {
        singleCallValue = _singleCallValue;
    }

    /// @dev open faucet
    function open() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!opened, "Faucet: opened");
        opened = true;
    }

    /// @dev close faucet
    function close() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(opened, "Faucet: closed");
        opened = false;
    }

    /**
     * @dev removeFaucetPermission.
     */
    function removeFaucetPermission(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(FAUCET_ROLE, account);
    }

    /**
     * @dev faucet.
     */
    function grantFaucetPermission(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(FAUCET_ROLE, account);
    }

    receive() external payable {

    }
}