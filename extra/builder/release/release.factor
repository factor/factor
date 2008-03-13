
USING: kernel system namespaces sequences splitting combinators
       io.files io.launcher
       bake combinators.cleave builder.common builder.util ;

IN: builder.release

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: releases ( -- path )
  builds "releases" path+
  dup exists? not
    [ dup make-directory ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: common-files ( -- seq )
  {
    "boot.x86.32.image"
    "boot.x86.64.image"
    "boot.macosx-ppc.image"
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

: windows-archive-cmd ( -- cmd ) { "zip" "-r" archive-name "factor" } ;

: macosx-archive-cmd ( -- cmd )
  { "hdiutil" "create"
              "-srcfolder" "factor"
              "-fs" "HFS+"
              "-volname" "factor"
              archive-name } ;

: unix-archive-cmd ( -- cmd ) { "tar" "-cvzf" archive-name "factor" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: archive-cmd ( -- cmd )
  {
    { [ windows? ] [ windows-archive-cmd ] }
    { [ macosx?  ] [ macosx-archive-cmd  ] }
    { [ unix?    ] [ unix-archive-cmd    ] }
  }
  cond ;

: make-archive ( -- ) archive-cmd to-strings try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: remove-common-files ( -- )
  { "rm" "-rf" common-files } to-strings try-process ;

: remove-factor-app ( -- )
  macosx? not [ { "rm" "-rf" "Factor.app" } try-process ] when ;

: release ( -- )
  "factor"
    [
      remove-factor-app
      remove-common-files
    ]
  with-directory
  make-archive
  archive-name releases move-file-into ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: release? ( -- ? )
  {
    "./load-everything-vocabs"
    "./test-all-vocabs"
  }
    [ eval-file empty? ]
  all? ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: maybe-release ( -- ) release? [ release ] when ;