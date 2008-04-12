
USING: kernel system namespaces sequences splitting combinators
       io io.files io.launcher prettyprint bootstrap.image
       bake combinators.cleave builder.common builder.util ;

IN: builder.release

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: releases ( -- path )
  builds "releases" append-path
  dup exists? not
    [ dup make-directory ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: base-name ( -- string )
  { "factor" [ os unparse ] cpu- stamp> } to-strings "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: extension ( -- extension )
  {
    { [ os winnt?  ] [ ".zip"    ] }  
    { [ os macosx? ] [ ".dmg"    ] }
    { [ os unix?   ] [ ".tar.gz" ] }
  }
  cond ;

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
    { [ os windows? ] [ windows-archive-cmd ] }
    { [ os macosx?  ] [ macosx-archive-cmd  ] }
    { [ os unix?    ] [ unix-archive-cmd    ] }
  }
  cond ;

: make-archive ( -- ) archive-cmd to-strings try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: remove-common-files ( -- )
  { "rm" "-rf" common-files } to-strings try-process ;

: remove-factor-app ( -- )
  os macosx? not [ { "rm" "-rf" "Factor.app" } try-process ] when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: upload-to-factorcode

: remote-location ( -- dest )
  "factorcode.org:/var/www/factorcode.org/newsite/downloads"
  platform
  append-path ;
    
: upload ( -- )
  { "scp" archive-name remote-location } to-strings
  [ "Error uploading binary to factorcode" print ]
  run-or-bail ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: maybe-upload ( -- )
  upload-to-factorcode get
    [ upload ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! update-clean-branch
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: branch-name ( -- string )
  { "clean" [ os unparse ] cpu- } to-strings "-" join ;

: refspec ( -- string ) "master:" branch-name append ;

: push-to-clean-branch ( -- )
  { "git" "push" "factorcode.org:/git/factor.git" refspec }
  to-strings
  try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: upload-clean-image ( -- )
  {
    "scp"
    my-boot-image-name
    "factorcode.org:/var/www/factorcode.org/newsite/images/clean"
  }
  to-strings
  try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: update-clean-branch ( -- )
  "factor"
    [
      push-to-clean-branch
      upload-clean-image
    ]
  with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: maybe-update-clean-branch ( -- )
  upload-to-factorcode get
    [ update-clean-branch ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: release ( -- )
  maybe-update-clean-branch
  "factor"
    [
      remove-factor-app
      remove-common-files
    ]
  with-directory
  make-archive
  maybe-upload
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