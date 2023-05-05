# Cyberconnect Discount Middlewares

This repository contains a collection of
[Cyberconnect](https://cyberconnect.me/)
middlewares to apply a discount on an essence in different
ways.
[CollectPaidMw.sol](https://github.com/cyberconnecthq/cybercontracts/blob/main/src/middlewares/essence/CollectPaidMw.sol)
is used as the base for writing these new middlewares.

## Essence Middlewares:

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

---

## Usage:
To compile and deploy the contracts you can clone the
original
[cybercontracts](https://github.com/cyberconnecthq/cybercontracts/tree/main)
repo, and copy your desired `.sol` file under
[essence](https://github.com/cyberconnecthq/cybercontracts/tree/main/src/middlewares/essence)
directory.

Next, follow the
[deployment](https://github.com/cyberconnecthq/cybercontracts/tree/main#deployment)
guide to compile and deploy. You can skip the compilation
by using any of the compiled [abi](abi), [evm](evm),
and [bin](bin) files for all the middlewares and their
dependencies (available here in this repo).
