! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators continuations io.directories io.files
io.files.links io.pathnames kernel make mason.common mason.config
mason.platform namespaces sequences system words ;
IN: mason.release.archive

: base-name ( -- string )
    [ "factor-" % platform % "-" % stamp get % ] "" make ;

: extension ( os -- extension )
    dup word? [ name>> ] when
    {
        { "windows" [ ".zip" ] }
        { "macos" [ ".dmg" ] }
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
        "-format" "UDZO"
        "-volname" volume-name
        archive-name
    } short-running-process ;

! Keep the complete distribution together when dragged into Applications.
: prepare-dmg-root ( -- )
    "dmg-root" make-directory
    "factor" "dmg-root" copy-tree-into
    "/Applications" "dmg-root/Applications" make-link
    "resource:extra/mason/release/archive/dmg_layout.DS_Store"
    "dmg-root/.DS_Store" copy-file ;

! The saved Finder layout avoids requiring a desktop session on Mason.
: make-macos-archive ( archive-name -- )
    [
        prepare-dmg-root
        "Factor" "dmg-root" make-disk-image
    ] [ "dmg-root" delete-tree ] finally ;

:: make-unix-archive ( archive-name -- )
    { "tar" "-cvz" "--no-xattrs" "-f" archive-name "factor" } short-running-process ;

: make-archive ( archive-name -- )
    target-os get {
        { windows [ make-windows-archive ] }
        { macos [ make-macos-archive ] }
        [ drop make-unix-archive ]
    } case ;

: releases ( -- path )
    builds-dir get "releases" append-path dup make-directories ;

: save-archive ( archive-name -- )
    releases move-file-into ;
