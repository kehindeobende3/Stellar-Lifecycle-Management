;; Engineering Projects Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var project-counter uint u0)
(define-map projects uint {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    status: (string-ascii 20),
    resources-required: uint,
    resources-allocated: uint,
    creator: principal
})

;; Public Functions
(define-public (create-project (name (string-ascii 100)) (description (string-utf8 1000)) (resources-required uint))
    (let
        (
            (project-id (+ (var-get project-counter) u1))
        )
        (map-set projects project-id {
            name: name,
            description: description,
            status: "proposed",
            resources-required: resources-required,
            resources-allocated: u0,
            creator: tx-sender
        })
        (var-set project-counter project-id)
        (ok project-id)
    )
)

(define-public (allocate-resources (project-id uint) (amount uint))
    (let
        (
            (project (unwrap! (map-get? projects project-id) err-invalid-parameters))
        )
        (asserts! (< (+ (get resources-allocated project) amount) (get resources-required project)) err-invalid-parameters)
        (map-set projects project-id
            (merge project {
                resources-allocated: (+ (get resources-allocated project) amount),
                status: (if (>= (+ (get resources-allocated project) amount) (get resources-required project))
                    "in-progress"
                    (get status project)
                )
            })
        )
        (ok true)
    )
)

(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
    (let
        (
            (project (unwrap! (map-get? projects project-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get creator project)) err-not-authorized)
        (map-set projects project-id
            (merge project {
                status: new-status
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-project (project-id uint))
    (map-get? projects project-id)
)

(define-read-only (get-project-count)
    (var-get project-counter)
)

