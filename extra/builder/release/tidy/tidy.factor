
USING: kernel system io.files io.launcher builder.util ;

IN: builder.release.tidy

: common-files ( -- seq )
  {
    "boot.x86.32.image"
    "boot.x86.64.image"
    "boot.macosx-ppc.image"
    "boot.linux-ppc.image"
    "vm"
    "temp"
    "logs"
    ".git"
    ".gitignore"
    "Makefile"
    "unmaintained"
    "build-support"
  } ;

: remove-common-files ( -- )
  { "rm" "-rf" common-files } to-strings try-process ;

: remove-factor-app ( -- )
  os macosx? not [ { "rm" "-rf" "Factor.app" } try-process ] when ;

: tidy ( -- )
  "factor" [ remove-factor-app remove-common-files ] with-directory ;
