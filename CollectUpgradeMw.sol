// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC721} from "../../dependencies/solmate/ERC721.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import {IEssenceMiddleware} from "../../interfaces/IEssenceMiddleware.sol";
import {ICyberEngine} from "../../interfaces/ICyberEngine.sol";
import {IProfileNFT} from "../../interfaces/IProfileNFT.sol";

import {Constants} from "../../libraries/Constants.sol";

import {FeeMw} from "../base/FeeMw.sol";

/**
 * @title  Collect Upgrade Middleware
 * @author Nicky Harpor
 * @notice Get a discount for upgrading to a new version of an Essence
 */
contract CollectUpgradeMw is IEssenceMiddleware, FeeMw {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
    MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyValidNamespace() {
        require(_namespace == msg.sender, "ONLY_VALID_NAMESPACE");
        _;
    }

    /*//////////////////////////////////////////////////////////////
    EVENT
    //////////////////////////////////////////////////////////////*/

    event CollectUpgradeMwSet(
        address indexed namespace,
        uint256 indexed profileId,
        uint256 indexed essenceId,
        uint256 totalSupply,
        uint256 amount,
        address recipient,
        address currency,
        bool subscribeRequired
    );

    /*//////////////////////////////////////////////////////////////
    STATES
    //////////////////////////////////////////////////////////////*/

    struct CollectUpgradeData {
        uint256 totalSupply;
        uint256 currentCollect;
        uint256 amount;
        address recipient;
        address currency;
        uint256 previousEssenceId;
        uint256 upgradeDiscount;
        bool subscribeRequired;
    }

    mapping(uint256 => mapping(uint256 => CollectUpgradeData))
    internal _paidEssenceData;
    address internal _namespace;

    /*//////////////////////////////////////////////////////////////
    CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address treasury, address namespace) FeeMw(treasury) {
        _namespace = namespace;
    }

    /*//////////////////////////////////////////////////////////////
    EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IEssenceMiddleware
     * @notice Stores the parameters for setting up the paid essence middleware, checks if the amount, recipient, and
     * currency is valid and approved. Also checks if discount is in range.
     */
    function setEssenceMwData(
        uint256 profileId,
        uint256 essenceId,
        bytes calldata data
    ) external override onlyValidNamespace returns (bytes memory) {
        (
        uint256 totalSupply,
        uint256 amount,
        address recipient,
        address currency,
        uint256 previousEssenceId,
        uint256 upgradeDiscount,
        bool subscribeRequired
        ) = abi.decode(data, (uint256, uint256, address, address, uint256, uint256, bool));

        require(amount != 0, "INVALID_AMOUNT");
        require(recipient != address(0), "INVALID_ADDRESS");
        require(_currencyAllowed(currency), "CURRENCY_NOT_ALLOWED");
        require(upgradeDiscount <= Constants._MAX_BPS, "INVALID_DISCOUNT");

        _paidEssenceData[profileId][essenceId].totalSupply = totalSupply;
        _paidEssenceData[profileId][essenceId].amount = amount;
        _paidEssenceData[profileId][essenceId].recipient = recipient;
        _paidEssenceData[profileId][essenceId].currency = currency;
        _paidEssenceData[profileId][essenceId].previousEssenceId = previousEssenceId;
        _paidEssenceData[profileId][essenceId].upgradeDiscount = upgradeDiscount;
        _paidEssenceData[profileId][essenceId]
        .subscribeRequired = subscribeRequired;

        emit CollectUpgradeMwSet(
            msg.sender,
            profileId,
            essenceId,
            totalSupply,
            amount,
            recipient,
            currency,
            subscribeRequired
        );
        return new bytes(0);
    }

    /**
     * @inheritdoc IEssenceMiddleware
     * @notice Determines whether the collection requires prior subscription and whether there is a limit, and processes the transaction
     * from the essence collector to the essence owner. Also applies discount.
     */
    function preProcess(
        uint256 profileId,
        uint256 essenceId,
        address collector,
        address,
        bytes calldata
    ) external override onlyValidNamespace {
        require(
            _paidEssenceData[profileId][essenceId].totalSupply >
            _paidEssenceData[profileId][essenceId].currentCollect,
            "COLLECT_LIMIT_EXCEEDED"
        );

        require(tx.origin == collector, "NOT_FROM_COLLECTOR");

        uint256 previousEssenceId = _paidEssenceData[profileId][essenceId].previousEssenceId;
        uint256 amount = _paidEssenceData[profileId][essenceId].amount;
        uint256 upgradeDiscount = _paidEssenceData[profileId][essenceId].upgradeDiscount;

        if (upgradeDiscount > 0) {
            if (_checkCollect(_namespace, profileId, collector, previousEssenceId)) {
                amount = amount - ((amount * upgradeDiscount) / Constants._MAX_BPS);
            }
        }

        address currency = _paidEssenceData[profileId][essenceId].currency;
        uint256 treasuryCollected = (amount * _treasuryFee()) /
        Constants._MAX_BPS;
        uint256 actualPaid = amount - treasuryCollected;

        if (_paidEssenceData[profileId][essenceId].subscribeRequired == true) {
            require(
                _checkSubscribe(_namespace, profileId, collector),
                "NOT_SUBSCRIBED"
            );
        }

        IERC20(currency).safeTransferFrom(
            collector,
            _paidEssenceData[profileId][essenceId].recipient,
            actualPaid
        );

        if (treasuryCollected > 0) {
            IERC20(currency).safeTransferFrom(
                collector,
                _treasuryAddress(),
                treasuryCollected
            );
        }
        _paidEssenceData[profileId][essenceId].currentCollect++;
    }

    /// @inheritdoc IEssenceMiddleware
    function postProcess(
        uint256,
        uint256,
        address,
        address,
        bytes calldata
    ) external {
        // do nothing
    }

    /*//////////////////////////////////////////////////////////////
    INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _checkSubscribe(
        address namespace,
        uint256 profileId,
        address collector
    ) internal view returns (bool) {
        address essenceOwnerSubscribeNFT = IProfileNFT(namespace)
        .getSubscribeNFT(profileId);

        return (essenceOwnerSubscribeNFT != address(0) &&
        ERC721(essenceOwnerSubscribeNFT).balanceOf(collector) != 0);
    }

    function _checkCollect(
        address namespace,
        uint256 profileId,
        address collector,
        uint256 previousEssenceId
    ) internal view returns (bool) {
        address previousEssenceNFT = IProfileNFT(namespace)
        .getEssenceNFT(profileId, previousEssenceId);

        return (previousEssenceNFT != address(0) &&
        ERC721(previousEssenceNFT).balanceOf(collector) != 0);
    }

}
