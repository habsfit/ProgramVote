
;; title: ProgramVote
;; version: 1.0.0
;; summary: A voting system smart contract for academic program approval
;; description: This contract allows authorized voters to vote on academic program proposals.
;;              Only approved voters can participate, and programs need a majority to be approved.

;; traits
;;

;; token definitions
;;

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-program-not-found (err u102))
(define-constant err-already-voted (err u103))
(define-constant err-voting-ended (err u104))
(define-constant err-program-exists (err u105))
(define-constant err-invalid-voting-period (err u106))

;; data vars
(define-data-var next-program-id uint u1)

;; data maps
;; Map to track authorized voters
(define-map authorized-voters principal bool)

;; Map to store program proposals
(define-map programs uint {
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposer: principal,
    created-at: uint,
    voting-end-block: uint,
    yes-votes: uint,
    no-votes: uint,
    is-approved: bool,
    is-finalized: bool
})

;; Map to track if a voter has voted on a specific program
(define-map voter-program-votes {voter: principal, program-id: uint} bool)

;; public functions

;; Initialize the contract - add the deployer as the first authorized voter
(define-public (initialize)
    (begin
        (map-set authorized-voters contract-owner true)
        (ok true)
    )
)

;; Add an authorized voter (only contract owner)
(define-public (add-authorized-voter (voter principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set authorized-voters voter true)
        (ok true)
    )
)

;; Remove an authorized voter (only contract owner)
(define-public (remove-authorized-voter (voter principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-delete authorized-voters voter)
        (ok true)
    )
)

;; Submit a new program proposal
(define-public (submit-program (title (string-ascii 100)) (description (string-ascii 500)) (voting-blocks uint))
    (let
        (
            (program-id (var-get next-program-id))
            (current-block block-height)
            (voting-end-block (+ current-block voting-blocks))
        )
        (begin
            (asserts! (> voting-blocks u0) err-invalid-voting-period)
            (asserts! (is-none (map-get? programs program-id)) err-program-exists)

            (map-set programs program-id {
                title: title,
                description: description,
                proposer: tx-sender,
                created-at: current-block,
                voting-end-block: voting-end-block,
                yes-votes: u0,
                no-votes: u0,
                is-approved: false,
                is-finalized: false
            })

            (var-set next-program-id (+ program-id u1))
            (ok program-id)
        )
    )
)

;; Vote on a program proposal
(define-public (vote (program-id uint) (vote-yes bool))
    (let
        (
            (voter tx-sender)
            (program-data (unwrap! (map-get? programs program-id) err-program-not-found))
            (current-block block-height)
        )
        (begin
            ;; Check if voter is authorized
            (asserts! (default-to false (map-get? authorized-voters voter)) err-not-authorized)

            ;; Check if voting is still open
            (asserts! (< current-block (get voting-end-block program-data)) err-voting-ended)

            ;; Check if voter hasn't already voted
            (asserts! (is-none (map-get? voter-program-votes {voter: voter, program-id: program-id})) err-already-voted)

            ;; Record the vote
            (map-set voter-program-votes {voter: voter, program-id: program-id} true)

            ;; Update vote counts
            (if vote-yes
                (map-set programs program-id (merge program-data {yes-votes: (+ (get yes-votes program-data) u1)}))
                (map-set programs program-id (merge program-data {no-votes: (+ (get no-votes program-data) u1)}))
            )

            (ok true)
        )
    )
)

;; Finalize a program vote (can be called by anyone after voting period ends)
(define-public (finalize-program (program-id uint))
    (let
        (
            (program-data (unwrap! (map-get? programs program-id) err-program-not-found))
            (current-block block-height)
            (yes-votes (get yes-votes program-data))
            (no-votes (get no-votes program-data))
            (total-votes (+ yes-votes no-votes))
        )
        (begin
            ;; Check if voting period has ended
            (asserts! (>= current-block (get voting-end-block program-data)) err-voting-ended)

            ;; Check if not already finalized
            (asserts! (not (get is-finalized program-data)) err-voting-ended)

            ;; Determine if program is approved (majority yes votes and at least one vote)
            (let ((is-approved (and (> total-votes u0) (> yes-votes no-votes))))
                (map-set programs program-id (merge program-data {
                    is-approved: is-approved,
                    is-finalized: true
                }))
                (ok is-approved)
            )
        )
    )
)

;; read only functions

;; Check if a principal is an authorized voter
(define-read-only (is-authorized-voter (voter principal))
    (default-to false (map-get? authorized-voters voter))
)

;; Get program details
(define-read-only (get-program (program-id uint))
    (map-get? programs program-id)
)

;; Check if a voter has voted on a specific program
(define-read-only (has-voted (voter principal) (program-id uint))
    (default-to false (map-get? voter-program-votes {voter: voter, program-id: program-id}))
)

;; Get the next program ID
(define-read-only (get-next-program-id)
    (var-get next-program-id)
)

;; Get vote results for a program
(define-read-only (get-vote-results (program-id uint))
    (match (map-get? programs program-id)
        program-data (ok {
            yes-votes: (get yes-votes program-data),
            no-votes: (get no-votes program-data),
            total-votes: (+ (get yes-votes program-data) (get no-votes program-data)),
            is-approved: (get is-approved program-data),
            is-finalized: (get is-finalized program-data)
        })
        err-program-not-found
    )
)

;; Check if voting is still open for a program
(define-read-only (is-voting-open (program-id uint))
    (match (map-get? programs program-id)
        program-data (ok (< block-height (get voting-end-block program-data)))
        err-program-not-found
    )
)

;; Get contract owner
(define-read-only (get-contract-owner)
    contract-owner
)

;; private functions
;;

