! Copyright (C) 2012 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators compiler.units continuations
destructors graphviz.dot images.viewer io.backend
io.directories io.encodings.8-bit.latin1 io.encodings.utf8
io.files io.files.unique io.launcher io.standard-paths kernel
locals make namespaces parser sequences summary system
unicode.case vocabs words ;
IN: graphviz.render

<PRIVATE

! "Layout Commands" from http://graphviz.org/Documentation.php
CONSTANT: standard-layouts {
    "circo"
    "dot"
    "fdp"
    "neato"
    "osage"
    "sfdp"
    "twopi"
}

PRIVATE>

SYMBOL: default-layout
"dot" default-layout set-global

SYMBOL: preview-format
"png" preview-format set-global

ERROR: unsupported-preview-format preview-format ;

M: unsupported-preview-format summary
    drop "Unsupported preview format" ;

SYMBOL: graph-encoding
utf8 graph-encoding set-global

ERROR: unsupported-encoding graph-encoding ;

M: unsupported-encoding summary
    drop "Must use utf8 or latin1 (match the graph's charset attribute)" ;

HOOK: default-graphviz-program os ( -- path/f )

M: object default-graphviz-program ( -- path/f )
    standard-layouts [ find-in-path ] find nip ;

ERROR: cannot-find-graphviz-installation ;

M: cannot-find-graphviz-installation summary
    drop "Cannot find Graphviz installation" ;

: ?default-graphviz-program ( -- path )
    default-graphviz-program
    [ cannot-find-graphviz-installation ] unless* ;

<PRIVATE

: try-graphviz-command ( path format layout -- )
    [
        ?default-graphviz-program ,
        [ , "-O" , ]
        [ "-T" , , ]
        [ "-K" , , ] tri*
    ] { } make try-output-process ;

: ?encoding ( -- encoding )
    graph-encoding get-global
    dup [ utf8? ] [ latin1? ] bi or
    [ unsupported-encoding ] unless ;

: ?delete-file ( path -- )
    dup exists? [ delete-file ] [ drop ] if ;

PRIVATE>

:: graphviz ( graph path format layout -- )
    path normalize-path :> dot-file
    [
        graph dot-file ?encoding write-dot
        dot-file format layout try-graphviz-command
    ]
    [ dot-file ?delete-file ] [ ] cleanup ;

: graphviz* ( graph path format -- )
    default-layout get-global graphviz ;

<PRIVATE

: try-preview-command ( from-path to-path -- )
    [
        ?default-graphviz-program ,
        [ , ]
        [ "-o" , , ] bi*
        "-T" , preview-format get-global ,
        "-K" , default-layout get-global ,
    ] { } make try-output-process ;

! Not only must Graphviz support the image format, but so must
! images.loader

: preview-extension ( -- extension )
    preview-format get-global >lower {
        { "bmp"  [ ".bmp" ] }
        { "gif"  [ ".gif" ] }
        { "ico"  [ ".ico" ] }
        { "jpg"  [ ".jpg" ] }
        { "jpeg" [ ".jpg" ] }
        { "jpe"  [ ".jpg" ] }
        { "png"  [ ".png" ] }
        { "tif"  [ ".tif" ] }
        { "tiff" [ ".tif" ] }
        [ unsupported-preview-format ]
    } case ;

:: with-preview ( graph quot: ( path -- ) -- )
    "preview" ".dot" [| code-file |
        "preview" preview-extension [| image-file |
            graph code-file ?encoding write-dot
            code-file image-file try-preview-command
            image-file quot call( path -- )
        ] cleanup-unique-file
    ] cleanup-unique-file ;

PRIVATE>

: preview ( graph -- )
    [ image. ] with-preview ;

: preview-window ( graph -- )
    [ image-window ] with-preview ;

<PRIVATE

! http://graphviz.org/content/output-formats
CONSTANT: standard-formats {
    "bmp"
    "canon"
    "dot"
    "xdot"
    "cmap"
    "eps"
    "fig"
    "gd"
    "gd2"
    "gif"
    "ico"
    "imap"
    "cmapx"
    "imap_np"
    "cmapx_np"
    "ismap"
    "jpg"
    "jpeg"
    "jpe"
    "pdf"
    "plain"
    "plain-ext"
    "png"
    "ps"
    "ps2"
    "svg"
    "svgz"
    "tif"
    "tiff"
    "vml"
    "vmlz"
    "vrml"
    "wbmp"
    "webp"
    ! ! ! Canvas formats don't actually use path argument...
    ! "gtk"
    ! "xlib"
}

: define-graphviz-by-layout ( layout -- )
    [ "graphviz.render" create ]
    [ [ graphviz ] curry ] bi
    ( graph path format -- )
    define-declared ;

: define-graphviz-by-format ( format -- )
    [
        dup standard-layouts member? [ "-file" append ] when
        "graphviz.render" create
    ]
    [ [ graphviz* ] curry ] bi
    ( graph path -- )
    define-declared ;

PRIVATE>

[
    standard-layouts [ define-graphviz-by-layout ] each
    standard-formats [ define-graphviz-by-format ] each
] with-compilation-unit

os windows? [ "graphviz.render.windows" require ] when
