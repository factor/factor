
USING: kernel combinators system sequences io.files io.launcher prettyprint
       builder.util
       builder.common ;

IN: builder.release.archive

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: base-name ( -- string )
  { "factor" [ os unparse ] cpu- stamp> } to-strings "-" join ;

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

! : macosx-archive-cmd ( -- cmd )
!   { "hdiutil" "create"
!               "-srcfolder" "factor"
!               "-fs" "HFS+"
!               "-volname" "factor"
!               archive-name } ;

: macosx-archive-cmd ( -- cmd )
  { "mkdir" "dmg-root" }                         try-process
  { "cp" "-r" "factor" "dmg-root" }              try-process
  { "hdiutil" "create"
              "-srcfolder" "dmg-root"
              "-fs" "HFS+"
              "-volname" "factor"
              archive-name }          to-strings try-process
  { "rm" "-rf" "dmg-root" }                      try-process
  { "true" } ;

: unix-archive-cmd ( -- cmd ) { "tar" "-cvzf" archive-name "factor" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: archive-cmd ( -- cmd )
  {
    { [ os windows? ] [ windows-archive-cmd ] }
    { [ os macosx?  ] [ macosx-archive-cmd  ] }
    { [ os unix?    ] [ unix-archive-cmd    ] }
  }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-archive ( -- ) archive-cmd to-strings try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: releases ( -- path )
  builds "releases" append-path
  dup exists? not
    [ dup make-directory ]
  when ;

: save-archive ( -- ) archive-name releases move-file-into ;