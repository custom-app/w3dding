// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract WeddingToken is ERC1155Upgradeable, AccessControlUpgradeable {
    event Proposition(address indexed )
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => string) private _uris;
    mapping(address => mapping(address => string)) public propositions;
    mapping(address => EnumerableSet.AddressSet) private _from;
    mapping(address => EnumerableSet.AddressSet) private _to;

    function initialize() external initializer {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev Make wedding propositon. data should be JSON or link
    */
    function propose(address to, string memory data) external {
        propositions[_msgSender()][to] = data;
        _from[_msgSender()].add(to);
        _to[to].add(_msgSender());
    }

    function getIncomingPropositions() external view returns (address[] memory, string[] memory) {
        
    }

    /**
   * @dev See {IERC1155-safeTransferFrom}.
   */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        revert("WeddingToken: transfer not allowed");
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override {
        revert("WeddingToken: transfer not allowed");
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     */
    function uri(uint256 id) public view override returns (string memory) {
        return _uris[id];
    }
}
