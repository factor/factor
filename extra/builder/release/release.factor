
USING: kernel namespaces sequences combinators io.files io.launcher
       bake combinators.cleave builder.common builder.util ;

IN: builder.release

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: releases ( -- path ) builds "/releases" append dup make-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: common-files ( -- seq )
  {
    "boot.x86.32.image"
    "boot.x86.64.image"
    "boot.macosx-ppc.boot"
    "vm"
    "temp"
    "logs"
    ".git"
    ".gitignore"
    "Makefile"
    "cp_dir"
    "unmaintained"
    "misc/target"
    "misc/wordsize"
    "misc/wordsize.c"
    "misc/macos-release.sh"
    "misc/source-release.sh"
    "misc/windows-release.sh"
    "misc/version.sh"
  } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: system sequences splitting ;

: cpu- ( -- cpu ) cpu "." split "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: base-name ( -- string ) { "factor" os cpu- stamp> } to-strings "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: extension ( -- extension )
  os
  {
    { "linux" [ ".tar.gz" ] }
    { "winnt" [ ".zip" ] }
    { "macosx" [ ".dmg" ] }
  }
  case ;

: archive-name ( -- string ) base-name extension append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-file ( source destination -- )
  swap { "mv" , , } bake run-process drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: linux-release ( -- )

  "factor" cd

  { "rm" "-rf" "Factor.app" } run-process drop

  { "rm" "-rf" common-files } to-strings run-process drop

  ".." cd

  { "tar" "-cvzf" archive-name "factor" } to-strings run-process drop

  archive-name releases move-file ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: windows-release ( -- )

  "factor" cd

  { "rm" "-rf" "Factor.app" } run-process drop

  { "rm" "-rf" common-files } to-strings run-process drop

  ".." cd

  { "zip" "-r" archive-name "factor" } to-strings run-process drop

  archive-name releases move-file ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: macosx-release ( -- )

  "factor" cd

  { "rm" "-rf" common-files } to-strings run-process drop

  ".." cd

  { "hdiutil" "create"
              "-srcfolder" "factor"
              "-fs" "HFS+"
              "-volname" "factor"
              archive-name }
  to-strings run-process drop

  archive-name releases move-file ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: release ( -- )
  os
    {
      { "linux"  [ linux-release   ] }
      { "winnt"  [ windows-release ] }
      { "macosx" [ macosx-release  ] }
    }
  case ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: release? ( -- ? )
  {
    "../load-everything-vocabs"
    "../test-all-vocabs"
  }
    [ eval-file empty? ]
  all? ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: maybe-release ( -- ) release? [ release ] when ;