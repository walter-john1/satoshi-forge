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
  (get-name
    ()
    (response (string-ascii 32) uint)
  )
  (get-symbol
    ()
    (response (string-ascii 32) uint)
  )
  (get-total-supply
    ()
    (response uint uint)
  )
))

;; Read-Only Functions (moved here to be available for other functions)

(define-read-only (get-protocol (protocol-id uint))
  (map-get? protocols { protocol-id: protocol-id })
)

(define-read-only (get-user-deposit (user principal))
  (map-get? user-deposits { user: user })
)

(define-read-only (get-total-tvl)
  (var-get total-tvl)
)

(define-read-only (is-whitelisted (token <sip-010-trait>))
  (default-to false
    (get approved (map-get? whitelisted-tokens { token: (contract-of token) }))
  )
)

;; Private Helper Functions

(define-private (get-protocol-list)
  (list u1 u2 u3 u4 u5)
)

(define-private (get-protocol-allocation (protocol-id uint))
  (get allocation
    (default-to { allocation: u0 }
      (map-get? strategy-allocations { protocol-id: protocol-id })
    ))
)

;; Access Control

(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner)
)

;; Validation Helpers

(define-private (is-valid-protocol-id (protocol-id uint))
  (and (> protocol-id u0) (<= protocol-id MAX-PROTOCOL-ID))
)

(define-private (is-valid-apy (apy uint))
  (and (>= apy MIN-APY) (<= apy MAX-APY))
)

(define-private (is-valid-name (name (string-ascii 64)))
  (and (not (is-eq name "")) (<= (len name) u64))
)

(define-private (protocol-exists (protocol-id uint))
  (is-some (map-get? protocols { protocol-id: protocol-id }))
)

;; Protocol Management

(define-public (add-protocol
    (protocol-id uint)
    (name (string-ascii 64))
    (initial-apy uint)
  )
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-protocol-id protocol-id) ERR-INVALID-PROTOCOL-ID)
    (asserts! (not (protocol-exists protocol-id)) ERR-PROTOCOL-EXISTS)
    (asserts! (is-valid-name name) ERR-INVALID-NAME)
    (asserts! (is-valid-apy initial-apy) ERR-INVALID-APY)

    (map-set protocols { protocol-id: protocol-id } {
      name: name,
      active: PROTOCOL-ACTIVE,
      apy: initial-apy,
    })

    (map-set strategy-allocations { protocol-id: protocol-id } { allocation: u0 })
    (ok true)
  )
)

(define-public (update-protocol-status
    (protocol-id uint)
    (active bool)
  )