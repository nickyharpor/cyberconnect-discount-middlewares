# Cyberconnect Discount Middlewares

This repository contains a collection of
[Cyberconnect](https://cyberconnect.me/)
middlewares to apply a discount on an essence in several
different ways.
[CollectPaidMw.sol](https://github.com/cyberconnecthq/cybercontracts/blob/main/src/middlewares/essence/CollectPaidMw.sol)
serves as the base for all middlewares.

## Usage:

### Option 1:
The [interfaces](abi) and [bytecodes](bin) of all the 
contracts are available. You can use them to deploy 
your own contract using [deploy.js](deploy.js).

### Option 2:
To compile and deploy the contracts you can clone the
original
[cybercontracts](https://github.com/cyberconnecthq/cybercontracts/tree/main)
repo, and copy your desired `.sol` file under
[essence](https://github.com/cyberconnecthq/cybercontracts/tree/main/src/middlewares/essence)
directory. Next, follow the
[deployment](https://github.com/cyberconnecthq/cybercontracts/tree/main#deployment)
guide to compile and deploy.

## Demo (BNB Testnet):

| Middleware | Address |
| --- | --- |
| Early Bird | [0x998A7331529EDe43fdB3CabA7f85F265eE63B636](https://testnet.bscscan.com/address/0x998A7331529EDe43fdB3CabA7f85F265eE63B636) |
| First N | [0x8B08012f7fab8FaDD7c3c6d686ABA3e73Cf9262D](https://testnet.bscscan.com/address/0x8b08012f7fab8fadd7c3c6d686aba3e73cf9262d) |
| Hot Essence | [0x09bccAF5769A44DfbA3BD7610d693f604764f9Cf](https://testnet.bscscan.com/address/0x09bccAF5769A44DfbA3BD7610d693f604764f9Cf) |
| Upgrade | [0x36f797cf56a9b772470658eb02F25507081e7bF9](https://testnet.bscscan.com/address/0x36f797cf56a9b772470658eb02F25507081e7bF9) |


## Middlewares:

### [CollectEarlyBirdMw.sol](CollectEarlyBirdMw.sol)

Discount applies for the early bird collectors. A target
block in future is set as the end of early bird discount.

###### Example use cases:

* Increasing the hype of an essence
* Selling more in less time

###### Additional init params:

`uint256 targetBlock` indicates a block in the future after
which the discount is disabled.

`uint256 discount` sets discount percentage. Must be less
than or equal to `Constants._MAX_BPS`. Zero means no
discount.

---

### [CollectFirstNMw.sol](CollectFirstNMw.sol)

A discount is applied for the first N collectors
of the essence.

###### Example use cases:

* Selling tickets to an event
* Promoting a profile by making users check for such an
essence more often

###### Additional init params:

`uint256 firstN` indicates how many first collectors
receive a discount.

`uint256 discount` sets discount percentage. Must be less
than or equal to `Constants._MAX_BPS`. Zero means no
discount.

---

### [CollectHotEssenceMw.sol](CollectHotEssenceMw.sol)

Discount applies on the essence when it's not in trend
any more (i.e. after a target block has passed.)

###### Example use cases:

* Selling trading signals
* Selling a music album

###### Additional init params:

`uint256 targetBlock` indicates the block at which the
discount starts to apply.

`uint256 discount` sets discount percentage. Must be less
than or equal to `Constants._MAX_BPS`. Zero means no
discount.

---

### [CollectUpgradeMw.sol](CollectUpgradeMw.sol)

Discount applies on the essence only if the collector has
already collected a specified essence (e.g. an essence
containing an older version of a software)

###### Example use cases:

* App upgrades
* Loyalty programs

###### Additional init params:

`uint256 previousEssenceId` indicates the ID of the essence
which should have been already collected in order to get
a discount.

`uint256 upgradeDiscount` sets discount percentage. Must be less
than or equal to `Constants._MAX_BPS`. Zero means no
discount.
