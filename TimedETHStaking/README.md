# Topic: Timed ETH Staking

## Objective
Implement a smart contract that allows users to stake ETH and later withdraw it with a reward that increases based on how long the ETH was staked.

---

# Specifications

## Main Functions

- `stake() payable`:  
  Allows a user to deposit ETH into the staking pool. Only one active stake per user is allowed.

- `unstake()`:  
  Allows the user to withdraw their staked ETH plus a reward that depends on how long it was staked.

---

## Constraints

- Each user can have **only one active stake** at a time.
- The reward is calculated using a linear formula:  
  `reward = amount * ((timeStaked * rewardMultiplier) / scale)`.
- A minimum staking duration (e.g., 60 seconds) is required before withdrawal.
- The contract must maintain a **central reward pool** (`pool`) that contains enough ETH to cover all expected rewards.
- The owner must fund the pool during deployment, and anyone can top it up afterward.

---

## Bonus

- Add a `getPendingReward()` function to let users preview their current reward.
- Allow the owner to update the reward multiplier via `rewardMultiplierModifier()`, with reasonable bounds.
- Emit `Staked()`, `Unstaked()`, `RewardMultiplierChanged()`, and `PoolModified()` events for better frontend tracking.
