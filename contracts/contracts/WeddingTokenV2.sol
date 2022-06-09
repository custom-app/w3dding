// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract WeddingTokenV2 is ERC1155Upgradeable, AccessControlUpgradeable {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @dev PropositionData - data of marriage proposition
    struct PropositionData {
        string metaUri;             // uri to NFT metadata
        string conditionsData;      // JSON with conditions or uri to file with them
        uint256 divorceTimeout;     // divorce timeout
        uint256 timestamp;          // created at (unix timestamp in seconds)
        bool authorAccepted;        // are conditions accepted by author of proposition
        bool receiverAccepted;      // are conditions accepted by receiver of proposition
    }

    /// @dev State of divorce
    enum DivorceState {NotRequested, RequestedByAuthor, RequestedByReceiver}

    /// @dev Marriage - data of marriage
    struct Marriage {
        address author;                        // author of original proposition
        address receiver;                      // receiver of original proposition

        DivorceState divorceState;             // state of divorce
        uint256 divorceRequestTimestamp;       // timestamp at which divorce was requested
        uint256 divorceTimeout;                // timeout after which divorce can be confirmed unilaterally
        uint256 timestamp;                     // created at (unix timestamp in seconds)

        string metaUri;                        // uri to NFT metadata
        string conditionsData;                 // JSON with conditions or uri to file with them
    }

    uint256 public defaultDivorceTimeout;                                          // default divorce timeout
    uint256 public count;                                                          // nft id sequencer
    mapping(address => uint256) public currentMarriages;                           // id of current marriage NFT
    mapping(uint256 => Marriage) public marriages;                                 // marriage details for each nft

    mapping(address => mapping(address => PropositionData)) public propositions;   // propositions
    mapping(address => EnumerableSet.AddressSet) private _from;                    // sets of receivers of propositions
    mapping(address => EnumerableSet.AddressSet) private _to;                      // sets of sender of propositions

    string private contractUri;

    /// @dev Emitted when `from` makes a proposition to `to`, or when proposition is updated.
    event Proposition(address indexed from, address indexed to, string metaUri, string condData,
        bool authorAccepted, bool receiverAccepted);

    /// @dev Emitted when Wedding NFT is minted.
    event Wedding(address indexed author, address indexed receiver, string metaUri, string condData);

    /**
     * @dev Emitted when divorce is requested. At `timestamp` + `timeout` initiator of divorce will be able
     * to confirm divorce unilaterally. `byAuthor` indicates if request came from author of original proposition
     */
    event DivorceRequest(address indexed author, address indexed receiver,
        uint256 timestamp, uint256 timeout, bool byAuthor);

    /// @dev Emitted when divorce is accepted.
    event Divorce(address indexed author, address indexed receiver);

    /// @dev Execution allowed only for caller not in marriage.
    modifier onlyNotInMarriage {
        require(currentMarriages[_msgSender()] == 0, "WeddingToken: already in marriage");
        _;
    }

    /// @dev Execution allowed only for caller in marriage.
    modifier onlyInMarriage {
        require(currentMarriages[_msgSender()] != 0, "WeddingToken: not in marriage");
        _;
    }

    /**
     * @dev initializer.
     * @param _defaultDivorceTimeout default divorce timeout in seconds
     */
    function initialize(uint256 _defaultDivorceTimeout) external initializer {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        defaultDivorceTimeout = _defaultDivorceTimeout;
        count = 1;
    }

    /// @dev supports interface for inheritance conflict resolving.
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AccessControlUpgradeable, ERC1155Upgradeable) returns (bool) {
        return
        interfaceId == type(IAccessControlUpgradeable).interfaceId ||
        interfaceId == type(IERC1155Upgradeable).interfaceId ||
        interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /**
     * @dev Make wedding proposition. Emits a {Proposition} event.
     *
     * @param to - address of receiver
     * @param metaUri - uri to NFT metadata
     * @param condData - JSON with conditions or uri to file with them
     *
     * Requirements:
     * - If called from a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     *
     * Requirements:
     * - caller must not be in marriage
    */
    function propose(address to, string memory metaUri, string memory condData) external onlyNotInMarriage {
        require(_msgSender() != to, "WeddingToken: cannot mary yourself");
        require(!_from[_msgSender()].contains(to) && !_to[_msgSender()].contains(to),
            "WeddingToken: proposition exists");

        propositions[_msgSender()][to] = PropositionData(metaUri, condData,
            defaultDivorceTimeout, block.timestamp, true, false);
        _from[_msgSender()].add(to);
        _to[to].add(_msgSender());

        emit Proposition(_msgSender(), to, metaUri, condData, true, false);
    }

    /**
     * @dev Update proposition. Emits a {Proposition} event.
     *
     * @param to - address of partner
     * @param metaUri - uri to NFT metadata
     * @param condData - JSON with conditions or uri to file with them
     *
     * Requirements:
     * - caller must not be in marriage
    */
    function updateProposition(address to, string memory metaUri, string memory condData) external onlyNotInMarriage {
        require(_from[_msgSender()].contains(to) || _to[_msgSender()].contains(to),
            "WeddingToken: proposition doesn't exist");
        (PropositionData storage prop, bool isAuthor) = _findProposition(to);
        (prop.metaUri, prop.conditionsData) = (metaUri, condData);
        if (isAuthor) {
            (prop.authorAccepted, prop.receiverAccepted) = (true, false);
            emit Proposition(_msgSender(), to, metaUri, condData, true, false);
        } else {
            (prop.authorAccepted, prop.receiverAccepted) = (false, true);
            emit Proposition(to, _msgSender(), metaUri, condData, false, true);
        }
    }

    /**
     * @dev Accept wedding proposition. Emits a {Wedding} event.
     *
     * @param to - address of partner
     * @param metaHash - sha256 hash of uri to NFT metadata. Used to validate state
     * @param condHash - sha256 hash of conditions string. Used to validate state
     *
     * Requirements:
     * - caller must not be in marriage
     * - partner must not be in marriage
    */
    function acceptProposition(address to, bytes32 metaHash, bytes32 condHash) external onlyNotInMarriage {
        require(_from[_msgSender()].contains(to) || _to[_msgSender()].contains(to),
            "WeddingToken: proposition doesn't exist");
        (PropositionData storage prop, bool isAuthor) = _findProposition(to);
        require(currentMarriages[to] == 0, "WeddingToken: partner already in marriage");
        require((isAuthor && prop.receiverAccepted) || (!isAuthor && prop.authorAccepted),
            "WeddingToken: accept from partner required");
        require(sha256(bytes(prop.metaUri)) == metaHash, "WeddingToken: img hash did not match");
        require(sha256(bytes(prop.conditionsData)) == condHash, "WeddingToken: conditions hash did not match");

        uint256 id = count;
        count++;
        if (isAuthor) {
            marriages[id] = Marriage(_msgSender(), to, DivorceState.NotRequested,
                0, prop.divorceTimeout, block.timestamp, prop.metaUri, prop.conditionsData);
            delete propositions[_msgSender()][to];
            _from[_msgSender()].remove(to);
            _to[to].remove(_msgSender());
        } else {
            marriages[id] = Marriage(to, _msgSender(), DivorceState.NotRequested,
                0, prop.divorceTimeout, block.timestamp, prop.metaUri, prop.conditionsData);
            delete propositions[to][_msgSender()];
            _from[to].remove(_msgSender());
            _to[_msgSender()].remove(to);
        }

        currentMarriages[to] = id;
        currentMarriages[_msgSender()] = id;
        _mint(_msgSender(), id, 1, bytes(""));
        _mint(to, id, 1, bytes(""));

        if (isAuthor) {
            emit Wedding(_msgSender(), to, marriages[id].metaUri, marriages[id].conditionsData);
        } else {
            emit Wedding(to, _msgSender(), marriages[id].metaUri, marriages[id].conditionsData);
        }
    }

    /**
     * @dev Request divorce. Emits a {DivorceRequested} event.
     *
     * Requirements:
     * - caller must be in marriage
    */
    function requestDivorce() external onlyInMarriage {
        Marriage storage marriage = marriages[currentMarriages[_msgSender()]];
        require(marriage.divorceState == DivorceState.NotRequested, "WeddingToken: divorce already requested");
        marriage.divorceRequestTimestamp = block.timestamp;
        if (_msgSender() == marriage.author) {
            marriage.divorceState = DivorceState.RequestedByAuthor;
        } else {
            marriage.divorceState = DivorceState.RequestedByReceiver;
        }

        emit DivorceRequest(marriage.author, marriage.receiver, marriage.divorceRequestTimestamp,
            marriage.divorceTimeout, _msgSender() == marriage.author);
    }

    /**
     * @dev Confirm divorce. Emits a {Divorce} event.
     *
     * Requirements:
     * - caller must be in marriage
     * - divorce must be previously requested
     * - confirmation must be made by second partner or after timeout
    */
    function confirmDivorce() external onlyInMarriage {
        uint256 id = currentMarriages[_msgSender()];
        Marriage storage marriage = marriages[id];
        require(marriage.divorceState != DivorceState.NotRequested, "WeddingToken: divorce wasn't requested");
        address needConfirm;
        if (marriage.divorceState == DivorceState.RequestedByAuthor) {
            needConfirm = marriage.receiver;
        } else {
            needConfirm = marriage.author;
        }
        require(_msgSender() == needConfirm ||
            block.timestamp > marriage.divorceRequestTimestamp + marriage.divorceTimeout,
            "WeddingToken: divorce confirmation not allowed");
        (address author, address receiver) = (marriage.author, marriage.receiver);
        delete currentMarriages[marriage.author];
        delete currentMarriages[marriage.receiver];
        delete marriages[id];

        _burn(author, id, 1);
        _burn(receiver, id, 1);

        emit Divorce(author, receiver);
    }

    /**
     * @dev Change contract metadata uri.
     *
     * @param _uri - new contract uri
    */
    function setContractUri(string memory _uri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        contractUri = _uri;
    }

    /**
     * @dev Get all incoming propositions.
    */
    function getIncomingPropositions() external view returns (address[] memory, PropositionData[] memory) {
        EnumerableSet.AddressSet storage set = _to[_msgSender()];
        uint256 size = set.length();
        address[] memory from = new address[](size);
        PropositionData[] memory data = new PropositionData[](size);
        for (uint256 i = 0; i < size; i++) {
            from[i] = set.at(i);
            data[i] = propositions[from[i]][_msgSender()];
        }
        return (from, data);
    }

    /**
     * @dev Get all outgoing propositions.
    */
    function getOutgoingPropositions() external view returns (address[] memory, PropositionData[] memory) {
        EnumerableSet.AddressSet storage set = _from[_msgSender()];
        uint256 size = set.length();
        address[] memory to = new address[](size);
        PropositionData[] memory data = new PropositionData[](size);
        for (uint256 i = 0; i < size; i++) {
            to[i] = set.at(i);
            data[i] = propositions[_msgSender()][to[i]];
        }
        return (to, data);
    }

    /**
     * @dev Contract metadata URI for OpenSea integration
    */
    function contractURI() public view returns (string memory) {
        return contractUri;
    }

    /**
   * @dev See {IERC1155-safeTransferFrom}.
   */
    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public pure override {
        revert("WeddingToken: transfer not allowed");
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public pure override {
        revert("WeddingToken: transfer not allowed");
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     */
    function uri(uint256 id) public view override returns (string memory) {
        return marriages[id].metaUri;
    }

    /**
     * @dev Get current marriage data.
     */
    function getCurrentMarriage() public view returns (Marriage memory) {
        return marriages[currentMarriages[_msgSender()]];
    }

    /**
     * @dev Find proposition in incoming and outgoing propositions.
     */
    function _findProposition(address to) internal view returns (PropositionData storage, bool) {
        if (_from[_msgSender()].contains(to)) {
            return (propositions[_msgSender()][to], true);
        } else {
            return (propositions[to][_msgSender()], false);
        }
    }
}
