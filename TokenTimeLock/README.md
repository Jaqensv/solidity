# Topic: Token Time Lock (Vesting Contract)

## Objective
Create a smart contract that locks ETH on behalf of a beneficiary and only allows withdrawal after a predefined time period.

---

# Specifications

## Main Functions

- `lock(address beneficiary) payable`:  
  The contract owner deposits ETH on behalf of a beneficiary. These funds will be locked and only become available after a set delay.

- `release()`:  
  Allows the beneficiary to withdraw the locked funds, but **only after** the lock period has expired.

---

## Constraints

- Each beneficiary can have **only one active deposit** at a time.
- The lock duration (e.g., 1 day) is either fixed in the contract or passed as a parameter during deployment.
- Once the funds are released, they **cannot be withdrawn again**.
- The contract must ensure it holds **enough ETH** to execute the release.

---

## Bonus

- Allow the beneficiary to query at any time:
  - the **locked amount**, and
  - the **remaining time before release**.
- Emit `Locked()` and `Released()` events to support frontend integration and analytics.
