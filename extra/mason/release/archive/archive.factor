! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators io.directories
io.directories.hierarchy io.files io.launcher io.pathnames
kernel make mason.common mason.config mason.platform namespaces
prettyprint sequences ;
IN: mason.release.archive

: base-name ( -- string )
    [ "factor-" % platform % "-" % stamp get % ] "" make ;

: extension ( -- extension )
    target-os get {
        { "winnt" [ ".zip" ] }
        { "macosx" [ ".dmg" ] }
        [ drop ".tar.gz" ]
    } case ;

: archive-name ( -- string ) base-name extension append ;

: make-windows-archive ( archive-name -- )
    [ "zip" , "-r" , , "factor" , ] { } make try-output-process ;

: make-macosx-archive ( archive-name -- )
    { "mkdir" "dmg-root" } try-output-process
    { "cp" "-R" "factor" "dmg-root" } try-output-process
    { "hdiutil" "create"
        "-srcfolder" "dmg-root"
        "-fs" "HFS+"
    "-volname" "factor" }
    swap suffix try-output-process
    "dmg-root" really-delete-tree ;

: make-unix-archive ( archive-name -- )
    [ "tar" , "-cvzf" , , "factor" , ] { } make try-output-process ;

: make-archive ( archive-name -- )
    target-os get {
        { "winnt" [ make-windows-archive ] }
        { "macosx" [ make-macosx-archive ] }
        [ drop make-unix-archive ]
    } case ;

: releases ( -- path )
    builds-dir get "releases" append-path dup make-directories ;

: save-archive ( archive-name -- )
    releases move-file-into ;