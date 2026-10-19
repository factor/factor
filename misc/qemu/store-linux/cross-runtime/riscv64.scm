;;; Candidate for misc/qemu/store-linux/cross-runtime.scm.
;;; The caller pins Guix with channels.scm and supplies --system and --target.
(use-modules (guix profiles)
             (guix packages)
             (guix utils)
             (gnu packages)
             (gnu packages audio)
             (gnu packages gl)
             (gnu packages gnome)
             (gnu packages gtk))

(define (required-environment-variable name)
  (or (getenv name)
      (error (string-append name " must name the target Guix system"))))

(define (enabled? name)
  (member (or (getenv name) "") '("1" "yes" "true" "on")))

;; This is a Guix system name, such as armhf-linux.  It is deliberately
;; distinct from both the build system and the --target GNU triplet.
(define target-system
  (required-environment-variable "FACTOR_GUIX_TARGET_SYSTEM"))
(define include-gtk2? (enabled? "FACTOR_GUIX_GTK2"))
(define use-softpipe? (enabled? "FACTOR_GUIX_SOFTPIPE"))
(define openal-mode (or (getenv "FACTOR_GUIX_OPENAL") "stock"))
(define print-backends
  (or (getenv "FACTOR_GUIX_PRINT_BACKENDS") "default"))
(define file-only-print? (string=? print-backends "file"))
(define ppc64le-target? (string=? target-system "powerpc64le-linux"))

(unless (member openal-mode '("stock" "alsa-null" "none"))
  (error "FACTOR_GUIX_OPENAL must be stock, alsa-null, or none"))
(unless (member print-backends '("default" "file"))
  (error "FACTOR_GUIX_PRINT_BACKENDS must be default or file"))

;; Guix 1.5 derives OS_TEST from the target triplet's first component and
;; therefore passes "powerpc64le".  NSS 3.101.4 recognizes "ppc64le" only;
;; without this normalization its C dispatch code is built but the matching
;; SHA-512, ChaCha20 and GCM assembly objects are omitted from FreeBL.
(define nss-package (specification->package "nss"))

(define nss-ppc64le-cross
  (package
    (inherit nss-package)
    (arguments
     ;; package->bag binds %current-target-system before forcing this field.
     ;; Native/build-side NSS therefore retains the exact original arguments;
     ;; only the PPC64LE target bag receives NSS's expected OS_TEST spelling.
     (if (equal? (%current-target-system) "powerpc64le-linux-gnu")
         (substitute-keyword-arguments (package-arguments nss-package)
           ((#:make-flags flags)
            #~(map (lambda (flag)
                     (if (string-prefix? "OS_TEST=" flag)
                         "OS_TEST=ppc64le"
                         flag))
                   #$flags)))
         (package-arguments nss-package)))))

;; The arguments thunk above leaves native and implicit build-side lowering
;; byte-identical while this reaches every target NSS edge.
(define rewrite-ppc64le-nss
  (package-input-rewriting `((,nss-package . ,nss-ppc64le-cross))))

;; Keep upstream arguments and disable only backends unavailable in the
;; portable runtime.  FreeALUT must refer to this exact OpenAL variant.
(define openal-alsa
  (package
    (inherit openal)
    (name "openal-alsa")
    (inputs (modify-inputs (package-inputs openal)
              (delete "pulseaudio")))
    (arguments
     (substitute-keyword-arguments (package-arguments openal)
       ((#:tests? _ #t) #f)
       ((#:configure-flags flags #~'())
        #~(append #$flags
                  (list "-DALSOFT_BACKEND_PULSEAUDIO=OFF"
                        "-DALSOFT_BACKEND_PIPEWIRE=OFF"
                        "-DALSOFT_BACKEND_JACK=OFF"
                        "-DALSOFT_BACKEND_ALSA=ON"
                        "-DALSOFT_BACKEND_NULL=ON")))
       ;; Upstream's phase also rewrites loaders for backends removed above.
       ;; The measured cross build instead resolves its sole dynamic backend.
       ((#:phases phases)
        #~(modify-phases #$phases
            (replace 'use-full-library-paths
              (lambda _
                (substitute* "alc/backends/alsa.cpp"
                  (("LoadLib\\(\"libasound\\.so\\.2\"\\)")
                   (string-append
                    "LoadLib(\""
                    #$(this-package-input "alsa-lib")
                    "/lib/libasound.so.2\")")))))))))))

(define freealut-alsa
  (package
    (inherit freealut)
    (name "freealut-alsa")
    (inputs (list openal-alsa))))

;; Preserve Mesa's upstream flags and phases, then override only the expensive
;; or irrelevant drivers.  build-tests is the one deliberate test deviation.
(define mesa-softpipe
  (package
    (inherit mesa)
    (name "mesa-softpipe")
    (inputs (modify-inputs (package-inputs mesa) (delete "llvm")))
    (native-inputs
     (modify-inputs (package-native-inputs mesa)
       (delete "clang" "libclc")))
    (arguments
     (substitute-keyword-arguments (package-arguments mesa)
       ((#:configure-flags flags #~'())
        #~(append #$flags
                  (list "-Dgallium-drivers=softpipe"
                        "-Dvulkan-drivers=" "-Dvulkan-layers="
                        "-Dplatforms=x11" "-Dllvm=disabled"
                        "-Dvideo-codecs=" "-Dbuild-tests=false")))
       ;; With Vulkan disabled, the pinned Mesa 25.2.3 phase has no layer
       ;; manifests to patch.  This exact deletion came from the ARM worker.
       ((#:phases phases)
        #~(modify-phases #$phases
            (delete 'set-layer-path-in-manifests)))))))

;; Rewrite propagated edges as well, otherwise stock LLVM Mesa remains in the
;; closure beside the reduced package.
(define libepoxy-softpipe
  (package
    (inherit libepoxy)
    (name "libepoxy-softpipe")
    (propagated-inputs
     (modify-inputs (package-propagated-inputs libepoxy)
       (replace "mesa" mesa-softpipe)))))
(define glu-softpipe
  (package
    (inherit glu)
    (name "glu-softpipe")
    (propagated-inputs
     (modify-inputs (package-propagated-inputs glu)
       (replace "mesa" mesa-softpipe)))))
;; librsvg-for-system chooses the C implementation for ARMHF.  Parameterize
;; only this selection: changing %current-system globally would falsely turn
;; the target into the build machine.  ARM's configure also needs a native
;; gdk-pixbuf query-loaders program.
(define target-librsvg
  (let ((base (parameterize ((%current-system target-system))
                (librsvg-for-system))))
    (if (member target-system '("armhf-linux" "powerpc64le-linux"))
        (package
          (inherit base)
          (name "librsvg-cross")
          (arguments
           (substitute-keyword-arguments (package-arguments base)
             ((#:configure-flags flags #~'())
              #~(append #$flags (list "--disable-introspection")))))
          (native-inputs
           (modify-inputs (package-native-inputs base)
             (append gdk-pixbuf))))
        base)))

;; These variants are selected only when FACTOR_GUIX_CROSS_FIXES is enabled;
;; native callers continue to receive the public GTK packages.
(define cross-fixes? (enabled? "FACTOR_GUIX_CROSS_FIXES"))

(when (and use-softpipe? (not cross-fixes?))
  (error "FACTOR_GUIX_SOFTPIPE requires FACTOR_GUIX_CROSS_FIXES"))

(define gtk-icon-cache-native
  (package
    (inherit gtk+)
    (name "gtk-icon-cache-native")
    (propagated-inputs '())
    (inputs
     (append
      (let ((inputs (modify-inputs (package-inputs gtk+)
                      (delete "colord-minimal" "rest"))))
        (if file-only-print?
            (modify-inputs inputs (delete "cups"))
            inputs))
      (modify-inputs (package-propagated-inputs gtk+)
        (delete "librsvg")
        (replace "mesa" mesa-softpipe)
        (replace "libepoxy" libepoxy-softpipe)
        (append gdk-pixbuf))))
    (arguments
     (substitute-keyword-arguments (package-arguments gtk+)
       ((#:tests? _ #t) #f)
       ((#:configure-flags flags)
        #~(append
           (map (lambda (flag)
                  (cond ((string=? flag "-Dcolord=yes") "-Dcolord=no")
                        ((string=? flag "-Dcloudproviders=true")
                         "-Dcloudproviders=false")
                        (else flag)))
                #$flags)
           (list "-Dwayland_backend=false" "-Dintrospection=false")
           (if #$file-only-print? (list "-Dprint_backends=file") '())))))))

(define gtk2-cross
  (package
    (inherit gtk+-2)
    (name "gtk2-cross")
    (inputs
     (if file-only-print?
         (modify-inputs (package-inputs gtk+-2) (delete "cups"))
         (package-inputs gtk+-2)))
    (propagated-inputs
     (modify-inputs (package-propagated-inputs gtk+-2)
       (delete "librsvg")
       (append target-librsvg)))
    (native-inputs
     (modify-inputs (package-native-inputs gtk+-2)
       (append `(,gtk-icon-cache-native "bin") gdk-pixbuf)))
    (arguments
     (substitute-keyword-arguments (package-arguments gtk+-2)
       ((#:configure-flags flags)
        #~(append #$flags
                  (if #$file-only-print?
                      (list "--with-print-backends=file")
                      '())))
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'configure 'use-native-icon-cache-compiler
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "gtk/Makefile"
                  (("^gtk_update_icon_cache_program = \\\\\n[ \\t]+\\./gtk-update-icon-cache$")
                   (string-append
                    "gtk_update_icon_cache_program = "
                    (search-path (string-split (getenv "PATH") #\:)
                                 "gtk-update-icon-cache")
                    "\n"))
                  (("^gtk_update_icon_cache_program = [^\\\\\n]*$")
                   (string-append
                    "gtk_update_icon_cache_program = "
                    (search-path (string-split (getenv "PATH") #\:)
                                 "gtk-update-icon-cache")
                    "\n")))))))))))

(define gtk3-cross
  (package
    (inherit gtk+)
    (name "gtk3-cross")
    (propagated-inputs
     (modify-inputs (package-propagated-inputs gtk+)
       (delete "librsvg")
       (replace "mesa" mesa-softpipe)
       (replace "libepoxy" libepoxy-softpipe)
       (append target-librsvg)))
    (inputs
     (let ((inputs (modify-inputs (package-inputs gtk+)
                     (delete "colord-minimal" "rest"))))
       (if file-only-print?
           (modify-inputs inputs (delete "cups"))
           inputs)))
    (arguments
     (substitute-keyword-arguments (package-arguments gtk+)
       ((#:configure-flags flags)
        #~(append
           (map (lambda (flag)
                  (cond ((string=? flag "-Dcolord=yes") "-Dcolord=no")
                        ((string=? flag "-Dcloudproviders=true")
                         "-Dcloudproviders=false")
                        (else flag)))
                #$flags)
           (list "-Dwayland_backend=false" "-Dintrospection=false")
           (if #$file-only-print? (list "-Dprint_backends=file") '())))))))

(define audio-packages
  (cond ((string=? openal-mode "none") '())
        ((string=? openal-mode "alsa-null")
         (list openal-alsa freealut-alsa))
        (else (list openal freealut))))

(define ui-packages
  (if cross-fixes?
      (append (if include-gtk2? (list gtk2-cross) '())
              (if use-softpipe?
                  ;; This order matches the measured ARM profile, keeping its
                  ;; profile derivation stable as well as package derivations.
                  (list gtk3-cross target-librsvg mesa-softpipe
                        libepoxy-softpipe glu-softpipe)
                  ;; Cross GTK pruning has only been measured together with
                  ;; the softpipe closure, so do not silently mix variants.
                  (error "FACTOR_GUIX_CROSS_FIXES currently requires FACTOR_GUIX_SOFTPIPE")))
      (append (list target-librsvg mesa libepoxy glu gtk+)
              (if include-gtk2? (list gtk+-2) '()))))

(define runtime-specifications
  '("openssl" "pcre" "pcre2" "zlib" "readline" "libffi" "sqlite"
    "tzdata" "libogg" "libvorbis" "capstone"
    "glib" "pango" "cairo" "gdk-pixbuf"
    "libx11" "libxcursor" "libxrandr" "libxi"
    "fontconfig" "freetype" "font-dejavu" "shared-mime-info"))

;; Keep the established ARM branch structurally unchanged.  PPC needs the
;; replacement throughout the graph because NSS is reached via Cairo/Poppler.
(if ppc64le-target?
    (packages->manifest
     (map rewrite-ppc64le-nss
          (append audio-packages ui-packages
                  (map specification->package runtime-specifications))))
    (concatenate-manifests
     (list
      (packages->manifest (append audio-packages ui-packages))
      (specifications->manifest runtime-specifications))))
