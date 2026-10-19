;; Reduced GTK3 runtimes for cross-built Factor qualification.  Use the Guix
;; revision in channels.scm; the ordinary native manifest remains manifest.scm.
;; Load only the selected recipe: importing other package modules first can
;; change the derivations produced by the pinned Guix revision.
(primitive-load
 (string-append
  (dirname (current-filename)) "/cross-runtime/"
  (cond
   ((equal? (getenv "FACTOR_GUIX_TARGET_SYSTEM") "armhf-linux")
    "armhf.scm")
   ((equal? (getenv "FACTOR_GUIX_TARGET_SYSTEM") "powerpc64le-linux")
    "powerpc64le.scm")
   ((equal? (getenv "FACTOR_GUIX_TARGET_SYSTEM") "riscv64-linux")
    "riscv64.scm")
   (else
    (error "FACTOR_GUIX_TARGET_SYSTEM must be armhf-linux, powerpc64le-linux, or riscv64-linux")))))
