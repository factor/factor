! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators compiler.units continuations
destructors images.viewer io.backend io.files.unique kernel
locals namespaces parser sequences summary unicode.case words
graphviz.ffi graphviz.builder ;
IN: graphviz.render

SYMBOL: default-layout
"dot" default-layout set-global

SYMBOL: default-format
"png" default-format set-global

ERROR: unsupported-format format ;
ERROR: unsupported-engine engine ;

M: unsupported-format summary
    drop "Unsupported layout format; check supported-formats" ;

M: unsupported-engine summary
    drop "Unsupported layout engine; check supported-engines" ;

<PRIVATE

: default-extension ( format -- extension )
    >lower {
        { "bmp"       [ ".bmp"  ] }
        { "canon"     [ ".dot"  ] }
        { "dot"       [ ".dot"  ] }
        { "xdot"      [ ".dot"  ] }
        { "eps"       [ ".eps"  ] }
        { "fig"       [ ".fig"  ] }
        { "gd"        [ ".gd"   ] }
        { "gd2"       [ ".gd2"  ] }
        { "gif"       [ ".gif"  ] }
        { "ico"       [ ".ico"  ] }
        { "imap"      [ ".map"  ] }
        { "cmapx"     [ ".map"  ] }
        { "imap_np"   [ ".map"  ] }
        { "cmapx_np"  [ ".map"  ] }
        { "ismap"     [ ".map"  ] }
        { "jpg"       [ ".jpg"  ] }
        { "jpeg"      [ ".jpg"  ] }
        { "jpe"       [ ".jpg"  ] }
        { "pdf"       [ ".pdf"  ] }
        { "plain"     [ ".txt"  ] }
        { "plain-ext" [ ".txt"  ] }
        { "png"       [ ".png"  ] }
        { "ps"        [ ".ps"   ] }
        { "ps2"       [ ".ps"   ] }
        { "svg"       [ ".svg"  ] }
        { "svgz"      [ ".svgz" ] }
        { "tif"       [ ".tif"  ] }
        { "tiff"      [ ".tif"  ] }
        { "vml"       [ ".vml"  ] }
        { "vmlz"      [ ".vmlz" ] }
        { "vrml"      [ ".vrml" ] }
        { "wbmp"      [ ".wbmp" ] }
        [ drop "" ]
    } case ;

: check-format ( -T -- )
    dup supported-formats member?
    [ drop ] [ unsupported-format ] if ; inline

: check-engine ( -K -- )
    dup supported-engines member?
    [ drop ] [ unsupported-engine ] if ; inline

: compute-engine ( Agraph_t* -K -- engine )
    [ nip ]
    [
        "layout" agget
        [ default-layout get-global ] when-empty
    ] if* dup check-engine ;

:: (graphviz) ( graph -O -T -K -- -o )
    -T check-format
    -O -T default-extension append normalize-path :> -o
    [
        gvContext &gvFreeContext :> gvc
        graph id>> graph kind agopen &agclose :> g
        g graph build-alien
        g -K compute-engine :> engine
        gvc g engine gvLayout drop
        [ gvc g -T -o gvRenderFilename drop -o ]
        [ gvc g gvFreeLayout drop ] [ ] cleanup
    ] with-destructors ;

: (preview) ( graph -- -o )
    "preview" unique-file
    default-format get-global
    f (graphviz) ; inline

PRIVATE>

: graphviz ( graph -O -T -K -- )
    (graphviz) drop ; inline

: graphviz* ( graph -O -T -- )
    f graphviz ; inline

: preview ( graph -- )
    (preview) image. ; inline

: preview-window ( graph -- )
    (preview) image-window ; inline

<PRIVATE

: define-graphviz-by-engine ( -K -- )
    [ "graphviz.render" create dup make-inline ]
    [ [ graphviz ] curry ] bi
    ( graph -O -T -- )
    define-declared ;

: define-graphviz-by-format ( -T -- )
    [
        dup supported-engines member? [ "-file" append ] when
        "graphviz.render" create dup make-inline
    ]
    [ [ graphviz* ] curry ] bi
    ( graph -O -- )
    define-declared ;

PRIVATE>

[
    supported-engines [ define-graphviz-by-engine ] each
    supported-formats [ define-graphviz-by-format ] each
] with-compilation-unit
