;; Native development environment: guix shell -m manifest.scm
;; Select GTK3 with: FACTOR_UI_BACKEND=gtk3 guix shell -m manifest.scm
;; For the CLI only: FACTOR_HEADLESS=1 guix shell -m manifest.scm
(use-modules (guix profiles)
             (guix packages)
             (guix download)
             (guix utils)
             (guix build-system gnu)
             (gnu packages gnome)
             (gnu packages python)
             ((guix licenses) #:prefix license:))

;; Guix does not currently package the legacy x86 disassembler. The release
;; tarball includes its generated opcode tables and needs no Python 2.
(define udis86
  (package
    (name "udis86")
    (version "1.7.2")
    (source (origin
              (method url-fetch)
              (uri (string-append "mirror://sourceforge/udis86/udis86/1.7/udis86-"
                                  version ".tar.gz"))
              (sha256 (base32 "1x62nci70ql49snk97qyrqy0yzbrgsnym3w2svhk3xf6d9iaqllw"))))
    (build-system gnu-build-system)
    (native-inputs (list python-minimal-wrapper))
    (arguments '(#:configure-flags '("--enable-shared" "--disable-static")))
    (home-page "https://udis86.sourceforge.net/")
    (synopsis "Disassembler for x86 and x86-64")
    (description "Udis86 provides the legacy x86 disassembler used by Factor.")
    (license license:bsd-2)))

(define target-system
  (or (getenv "FACTOR_GUIX_SYSTEM") (%current-system)))

(define ui-backend
  (or (getenv "FACTOR_UI_BACKEND")
      (if (member target-system '("i686-linux" "armhf-linux" "powerpc-linux"))
          "gtk3" "gtk4")))
(unless (member ui-backend '("gtk4" "gtk3"))
  (error "FACTOR_UI_BACKEND must be gtk4 or gtk3" ui-backend))

(concatenate-manifests
 (list
  (packages->manifest
   (append
    (if (member target-system '("x86_64-linux" "i686-linux"))
        (list udis86) '())
    ;; Guix selects its C implementation where Rust is unavailable.
    (if (getenv "FACTOR_HEADLESS") '()
        (list (parameterize ((%current-system target-system))
                (librsvg-for-system))))))
  (specifications->manifest
   (append
    '("gcc-toolchain" "make" "pkg-config" "git" "curl" "nss-certs"
      "bash" "coreutils" "findutils" "diffutils" "grep" "sed" "gawk"
      "tar" "gzip" "which" "procps"
      "openssl" "pcre" "pcre2" "zlib" "readline" "libffi" "sqlite" "tzdata"
      "openal" "freealut" "libogg" "libvorbis" "capstone")
    (if (getenv "FACTOR_HEADLESS") '()
        ;; The full UI prefix also exercises the legacy GTK2 bindings.
        (list (if (string=? ui-backend "gtk3") "gtk+@3" "gtk") "gtk+@2"
              "glib" "pango" "cairo" "gdk-pixbuf" "libepoxy"
              "mesa" "glu" "libx11" "libxcursor" "libxrandr" "libxi"
              "fontconfig" "freetype" "font-dejavu" "shared-mime-info"))))))
