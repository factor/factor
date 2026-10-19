;; Load the regular manifest with the target system active from the start.
;; Guix package modules make architecture-dependent choices while loading, so
;; setting %current-system inside manifest.scm is too late for cross-system
;; shells (for example AArch64 Guix evaluating an ARMHF GTK environment).
(use-modules (guix utils))

(define target-system
  (or (getenv "FACTOR_GUIX_SYSTEM")
      (error "FACTOR_GUIX_SYSTEM is required")))
(define manifest
  (or (getenv "FACTOR_GUIX_MANIFEST")
      (error "FACTOR_GUIX_MANIFEST is required")))

(parameterize ((%current-system target-system))
  (primitive-load manifest))
