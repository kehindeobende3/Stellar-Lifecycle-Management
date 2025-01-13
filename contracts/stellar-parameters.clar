;; Stellar Parameters Management Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var star-counter uint u0)
(define-map stars uint {
    name: (string-ascii 100),
    mass: uint,
    radius: uint,
    temperature: uint,
    age: uint,
    stage: (string-ascii 20),
    creator: principal
})

;; Public Functions
(define-public (create-star (name (string-ascii 100)) (mass uint) (radius uint) (temperature uint) (age uint) (stage (string-ascii 20)))
    (let
        (
            (star-id (+ (var-get star-counter) u1))
        )
        (map-set stars star-id {
            name: name,
            mass: mass,
            radius: radius,
            temperature: temperature,
            age: age,
            stage: stage,
            creator: tx-sender
        })
        (var-set star-counter star-id)
        (ok star-id)
    )
)

(define-public (update-star-parameters (star-id uint) (mass uint) (radius uint) (temperature uint) (age uint) (stage (string-ascii 20)))
    (let
        (
            (star (unwrap! (map-get? stars star-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get creator star)) err-not-authorized)
        (map-set stars star-id
            (merge star {
                mass: mass,
                radius: radius,
                temperature: temperature,
                age: age,
                stage: stage
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-star (star-id uint))
    (map-get? stars star-id)
)

(define-read-only (get-star-count)
    (var-get star-counter)
)

