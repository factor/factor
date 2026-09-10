! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors alien.c-types alien.data
alien.syntax arrays classes.struct destructors kernel libc locals math
math.bitwise math.order math.rectangles math.vectors pango.ffi
pango.cairo.ffi cairo.ffi sequences sorting vectors ;
IN: ui.text.pango.indexed

! Public Pango ABI structures. Keep these names separate from the opaque
! GIR types. The glyph arrays remain owned by the original PangoLayout.
STRUCT: indexed-analysis
    { shape-engine void* } { lang-engine void* } { font void* }
    { level uchar } { gravity uchar } { flags uchar } { script uchar }
    { language void* } { extra-attrs void* } ;
STRUCT: indexed-item
    { offset int } { length int } { num-chars int }
    { analysis indexed-analysis } ;
STRUCT: indexed-glyph-string
    { num-glyphs int } { glyphs void* } { log-clusters void* } { space int } ;
STRUCT: indexed-glyph-item
    { item indexed-item* } { glyphs indexed-glyph-string* }
    { y-offset int } { start-x-offset int } { end-x-offset int } ;
STRUCT: indexed-layout-line
    { layout void* } { start-index int } { length int }
    { runs void* } { flags uint } ;
STRUCT: indexed-glyph-info
    { glyph uint } { width int } { x-offset int } { y-offset int } { attr uint } ;

LIBRARY: pango
FUNCTION-ALIAS: layout-text-pointer void* pango_layout_get_text ( void* layout )
FUNCTION-ALIAS: glyph-index-to-x void pango_glyph_string_index_to_x
    ( void* glyphs, void* text, int length, void* analysis, int index, bool trailing, int* x )
FUNCTION-ALIAS: glyph-x-to-index void pango_glyph_string_x_to_index
    ( void* glyphs, void* text, int length, void* analysis, int x, int* index, int* trailing )

TUPLE: glyph-region glyphs cluster-offset font analysis text start length x width y ink order max-right ;
TUPLE: glyph-index regions logical spatial width ink ;

:: cluster-at ( glyphs i -- offset )
    glyphs log-clusters>> i int heap-size * alien-signed-4 ; inline

:: <glyph-region> ( run start end x baseline text -- region )
    run glyphs>> :> glyphs
    run item>> :> item
    item analysis>> :> analysis
    analysis level>> 1 bitand zero? [
        glyphs start cluster-at
        end glyphs num-glyphs>> < [ glyphs end cluster-at ] [ item length>> ] if
    ] [
        glyphs end 1 - cluster-at
        start zero? [ item length>> ] [ glyphs start 1 - cluster-at ] if
    ] if :> ( lo hi )
    end start - :> count
    indexed-glyph-string new count >>num-glyphs
        start indexed-glyph-info heap-size * glyphs glyphs>> <displaced-alien> >>glyphs
        start int heap-size * glyphs log-clusters>> <displaced-alien> >>log-clusters :> view
    view pango_glyph_string_get_width :> width
    PangoRectangle new :> ink
    view analysis font>> ink f pango_glyph_string_extents
    x PANGO_SCALE /f :> px
    baseline run y-offset>> PANGO_SCALE /f - :> py
    glyph-region new view >>glyphs lo >>cluster-offset analysis font>> >>font
        analysis >>analysis lo item offset>> + >>start hi lo - >>length
        lo item offset>> + text <displaced-alien> >>text
        px >>x width PANGO_SCALE /f >>width py >>y
        ink x>> PANGO_SCALE /f px + ink y>> PANGO_SCALE /f py + 2array
        ink width>> ink height>> 2array [ PANGO_SCALE /f ] map <rect> >>ink ;

:: <glyph-index> ( layout baseline -- index )
    layout 0 pango_layout_get_line_readonly indexed-layout-line memory>struct :> line
    layout layout-text-pointer :> text
    V{ } clone :> regions
    0 :> x!
    line runs>> :> node!
    [ node ] [
        node 0 alien-cell indexed-glyph-item memory>struct :> run
        x run start-x-offset>> + x!
        run glyphs>> :> glyphs
        0 :> start!
        [ start glyphs num-glyphs>> < ] [
            start 256 + glyphs num-glyphs>> min :> end!
            [ end glyphs num-glyphs>> < [
                glyphs end cluster-at glyphs end 1 - cluster-at =
            ] [ f ] if ] [ end 1 + end! ] while
            run start end x baseline text <glyph-region> :> region
            region regions length >>order regions push
            x region glyphs>> pango_glyph_string_get_width + x!
            end start!
        ] while
        x run end-x-offset>> + x!
        node void* heap-size alien-cell node!
    ] while
    regions [ ink>> loc>> first ] sort-by :> spatial
    -1/0. :> right!
    spatial [| region |
        region ink>> rect-extent nip first right max right!
        region right >>max-right drop
    ] each
    glyph-index new regions >>regions regions [ start>> ] sort-by >>logical
        spatial >>spatial
        x PANGO_SCALE /f >>width
        regions [ ink>> ] map dup empty? [ drop { 0 0 } { 0 0 } <rect> ]
        [ unclip [ rect-union ] reduce ] if >>ink ;

! Horizontal ASCII advances provide a monotonic index for caret lookup.
! Drawing uses actual ink bounds and preserves the native paint order.
:: region-at-x ( x regions -- i )
    0 :> lo! regions length :> hi!
    [ lo hi < ] [
        lo hi + 2 /i :> mid
        mid regions nth :> region
        region x>> region width>> + x <= [ mid 1 + lo! ] [ mid hi! ] if
    ] while
    lo regions length 1 - min 0 max ;

:: visible-glyph-regions ( index x width -- regions )
    index spatial>> :> regions
    0 :> lo! regions length :> hi!
    [ lo hi < ] [
        lo hi + 2 /i :> mid
        mid regions nth max-right>> x < [ mid 1 + lo! ] [ mid hi! ] if
    ] while
    V{ } clone :> visible
    [ lo regions length < [
        lo regions nth ink>> loc>> first x width + <=
    ] [ f ] if ] [
        lo regions nth :> region
        region ink>> rect-extent nip first x >= [ region visible push ] when
        lo 1 + lo!
    ] while
    visible [ order>> ] sort-by ;

:: draw-indexed-region ( cr index x width -- )
    index x width visible-glyph-regions [| region |
        cr region x>> region y>> cairo_move_to
        cr region font>> region glyphs>> pango_cairo_show_glyph_string
    ] each ;

:: region-at-offset ( offset regions -- region )
    0 :> lo! regions length :> hi!
    [ lo hi < ] [
        lo hi + 2 /i :> mid
        mid regions nth start>> offset <= [ mid 1 + lo! ] [ mid hi! ] if
    ] while
    lo 1 - 0 max regions nth ;

! Only hit testing needs normalized cluster indices. Allocate a bounded
! temporary native array; never store pointers into movable Factor memory.
:: region-hit-glyphs ( region -- glyphs )
    region glyphs>> :> original
    original num-glyphs>> int <c-array> :> clusters
    original num-glyphs>> [| i |
        original i cluster-at region cluster-offset>> - i clusters set-nth
    ] each-integer
    original clone clusters malloc-byte-array &free >>log-clusters ;

:: indexed-offset>x ( offset index -- x )
    offset index logical>> region-at-offset :> region
    [ region region-hit-glyphs region text>> region length>> region analysis>>
    offset region start>> - 0 region length>> clamp f
    { int } [ glyph-index-to-x ] with-out-parameters
    PANGO_SCALE /f region x>> + ] with-destructors ;

:: indexed-x>offset ( x index -- offset )
    index regions>> :> regions
    x regions region-at-x regions nth :> region
    [ region region-hit-glyphs region text>> region length>> region analysis>>
    x region x>> - PANGO_SCALE * >integer
    { int int } [ glyph-x-to-index ] with-out-parameters
    + region start>> + ] with-destructors ;
