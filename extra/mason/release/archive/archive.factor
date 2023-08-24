! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators io.directories io.pathnames kernel
make mason.common mason.config mason.platform namespaces
sequences system words ;
IN: mason.release.archive

: base-name ( -- string )
    [ "factor-" % platform % "-" % stamp get % ] "" make ;

: extension ( os -- extension )
    dup word? [ name>> ] when
    {
        { "windows" [ ".zip" ] }
        { "macosx" [ ".dmg" ] }
        [ drop ".tar.gz" ]
    } case ;

: archive-name ( -- string )
    base-name target-os get extension append ;

:: make-windows-archive ( archive-name -- )
    { "zip" "-r" archive-name "factor" } short-running-process ;

:: make-disk-image ( archive-name volume-name dmg-root -- )
    {
        "hdiutil" "create"
        "-srcfolder" dmg-root
        "-fs" "HFS+"
        "-volname" volume-name
        archive-name
    } short-running-process ;

! Make the .dmg
: make-macosx-archive ( archive-name -- )
    "dmg-root" make-directory
    "factor" "dmg-root" copy-tree-into
    "factor" "dmg-root" make-disk-image
    "dmg-root" delete-tree ;

:: make-unix-archive ( archive-name -- )
    { "tar" "-cvzf" archive-name "factor" } short-running-process ;

: make-archive ( archive-name -- )
    target-os get {
        { windows [ make-windows-archive ] }
        { macosx [ make-macosx-archive ] }
        [ drop make-unix-archive ]
    } case ;

: releases ( -- path )
    builds-dir get "releases" append-path dup make-directories ;

: save-archive ( archive-name -- )
    releases move-file-into ;
