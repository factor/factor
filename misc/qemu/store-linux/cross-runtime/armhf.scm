(use-modules (guix profiles)
             (guix packages)
             (guix utils)
             (gnu packages)
             (gnu packages audio)
             (gnu packages gl)
             (gnu packages gnome)
             (gnu packages gtk))

(define openal-alsa
  (package
    (inherit openal)
    (name "openal-alsa")
    (inputs (modify-inputs (package-inputs openal) (delete "pulseaudio")))
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
  (package (inherit freealut)
           (name "freealut-alsa")
           (inputs (list openal-alsa))))

(define librsvg-cross
  (let ((base (parameterize ((%current-system "armhf-linux"))
                (librsvg-for-system))))
    (package
      (inherit base)
      (name "librsvg-cross")
      (arguments
       (substitute-keyword-arguments (package-arguments base)
         ((#:configure-flags flags #~'())
          #~(append #$flags (list "--disable-introspection")))))
      (native-inputs
       (modify-inputs (package-native-inputs base)
         (append gdk-pixbuf))))))

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
       ((#:phases phases)
        #~(modify-phases #$phases
            (delete 'set-layer-path-in-manifests)))))))

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

(define gtk-icon-cache-native
  (package
    (inherit gtk+)
    (name "gtk-icon-cache-native")
    (propagated-inputs '())
    (inputs
     (append
      (modify-inputs (package-inputs gtk+)
        (delete "colord-minimal" "rest"))
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
           (list "-Dwayland_backend=false" "-Dintrospection=false")))))))

(define gtk2-cross
  (package
    (inherit gtk+-2)
    (name "gtk2-cross")
    (propagated-inputs
     (modify-inputs (package-propagated-inputs gtk+-2)
       (delete "librsvg")
       (append librsvg-cross)))
    (native-inputs
     (modify-inputs (package-native-inputs gtk+-2)
       (append `(,gtk-icon-cache-native "bin") gdk-pixbuf)))
    (arguments
     (substitute-keyword-arguments (package-arguments gtk+-2)
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
       (append librsvg-cross)))
    (inputs
     (modify-inputs (package-inputs gtk+)
       (delete "colord-minimal" "rest")))
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
           (list "-Dwayland_backend=false" "-Dintrospection=false")))))))

(concatenate-manifests
 (list
  (packages->manifest
   (list openal-alsa freealut-alsa gtk2-cross gtk3-cross librsvg-cross
         mesa-softpipe libepoxy-softpipe glu-softpipe))
  (specifications->manifest
   '("openssl" "pcre" "pcre2" "zlib" "readline" "libffi" "sqlite"
     "tzdata" "libogg" "libvorbis" "capstone"
     "glib" "pango" "cairo" "gdk-pixbuf"
     "libx11" "libxcursor" "libxrandr" "libxi"
     "fontconfig" "freetype" "font-dejavu" "shared-mime-info"))))
