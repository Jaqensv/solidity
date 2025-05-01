# Topic: Mini Vault with Simulated Interest

## Objective
Implement a simple deposit smart contract in which users can deposit ETH and later withdraw it with a fixed, simulated interest rate applied by the contract (not based on real yield or investment returns).

---

# Specifications

## Main Functions

- `deposit() payable`:  
  Allows a user to deposit ETH into the contract.

- `withdraw()`:  
  Allows the user to withdraw their deposit with a fixed interest rate applied (e.g., +5%).

---

## Constraints

- Each user can **only deposit once** (to simplify the logic).
- The interest is **simulated** (e.g., 5%):  
  A deposit of 1 ETH results in a withdrawal of 1.05 ETH.
- The contract must hold **sufficient ETH liquidity** to process withdrawals:  
  It should handle the case where it cannot fully reimburse all users.
