;; Title: Satoshi Forge - BTC Yield Fusion Protocol
;;
;; Summary:
;; A modular, multi-strategy BTC yield optimizer enabling decentralized allocation 
;; of Bitcoin-based assets across whitelisted protocols with APY-driven logic.
;;
;; Description:
;; Satoshi Forge is a decentralized protocol built on Clarity that facilitates 
;; secure deposits of BTC-pegged tokens (via SIP-010), with automated distribution 
;; of funds into multiple whitelisted DeFi strategies. Users earn compound yield 
;; based on protocol APYs and allocations, with a full-featured reward system, 
;; deposit/withdrawal lifecycle, platform-level fee management, and emergency controls. 
;; Admins can whitelist tokens, configure strategies, and adjust fee parameters. 
;; This contract introduces protocol-level flexibility, user-level tracking, and 
;; system-wide security through access control and rebalancing logic.

;; Constants

(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-AMOUNT (err u1001))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1002))
(define-constant ERR-PROTOCOL-NOT-WHITELISTED (err u1003))
(define-constant ERR-STRATEGY-DISABLED (err u1004))
(define-constant ERR-MAX-DEPOSIT-REACHED (err u1005))
(define-constant ERR-MIN-DEPOSIT-NOT-MET (err u1006))
(define-constant ERR-INVALID-PROTOCOL-ID (err u1007))
(define-constant ERR-PROTOCOL-EXISTS (err u1008))
(define-constant ERR-INVALID-APY (err u1009))
(define-constant ERR-INVALID-NAME (err u1010))
(define-constant ERR-INVALID-TOKEN (err u1011))
(define-constant ERR-TOKEN-NOT-WHITELISTED (err u1012))

(define-constant PROTOCOL-ACTIVE true)
(define-constant PROTOCOL-INACTIVE false)

(define-constant MAX-PROTOCOL-ID u100)
(define-constant MAX-APY u10000) ;; 100% APY in basis points
(define-constant MIN-APY u0)

;; Data Variables

(define-data-var total-tvl uint u0)
(define-data-var platform-fee-rate uint u100) ;; 1% fee (basis: 10000)
(define-data-var min-deposit uint u100000) ;; Minimum deposit (in sats)
(define-data-var max-deposit uint u1000000000) ;; Maximum deposit (in sats)
(define-data-var emergency-shutdown bool false)

;; Storage Maps

(define-map user-deposits
  { user: principal }
  {
    amount: uint,
    last-deposit-block: uint,
  }
)

(define-map user-rewards
  { user: principal }
  {
    pending: uint,
    claimed: uint,
  }
)

(define-map protocols
  { protocol-id: uint }
  {
    name: (string-ascii 64),
    active: bool,
    apy: uint,
  }
)

(define-map strategy-allocations
  { protocol-id: uint }
  { allocation: uint }
)
;; in basis points (100 = 1%)

(define-map whitelisted-tokens
  { token: principal }
  { approved: bool }
)

;; SIP-010 Token Trait Definition

(define-trait sip-010-trait (
  (transfer
    (uint principal principal (optional (buff 34)))
    (response bool uint)
  )
  (get-balance
    (principal)
    (response uint uint)
  )
  (get-decimals
    ()
    (response uint uint)
  )