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

: make-windows-archive ( -- )
    [ "zip" , "-r" , archive-name , "factor" , ] { } make try-process ;

: make-macosx-archive ( -- )
    { "mkdir" "dmg-root" } try-process
    { "cp" "-R" "factor" "dmg-root" } try-process
    { "hdiutil" "create"
        "-srcfolder" "dmg-root"
        "-fs" "HFS+"
    "-volname" "factor" }
    archive-name suffix try-process
    "dmg-root" really-delete-tree ;

: make-unix-archive ( -- )
    [ "tar" , "-cvzf" , archive-name , "factor" , ] { } make try-process ;

: make-archive ( -- )
    target-os get {
        { "winnt" [ make-windows-archive ] }
        { "macosx" [ make-macosx-archive ] }
        [ drop make-unix-archive ]
    } case ;

: releases ( -- path )
    builds-dir get "releases" append-path dup make-directories ;

: save-archive ( -- )
    archive-name releases move-file-into ;