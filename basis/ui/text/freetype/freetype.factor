! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.accessors alien.c-types arrays io kernel libc
math math.vectors namespaces opengl opengl.gl opengl.sprites assocs
sequences io.files continuations freetype
ui.gadgets.worlds ui.text ui.text.private ui.backend
byte-arrays accessors locals specialized-arrays.direct.uchar
combinators.smart ;
IN: ui.text.freetype

SINGLETON: freetype-renderer

SYMBOL: open-fonts

: freetype-error ( n -- )
    zero? [ "FreeType error" throw ] unless ;

DEFER: freetype

: init-freetype ( -- )
    global [
        f <void*> dup FT_Init_FreeType freetype-error
        *void* \ freetype set
        H{ } clone open-fonts set
    ] bind ;

: freetype ( -- alien )
    \ freetype get-global expired? [ init-freetype ] when
    \ freetype get-global ;

TUPLE: freetype-font < identity-tuple
ascent descent height handle widths ;

M: freetype-font hashcode* drop freetype-font hashcode* ;

: close-font ( font -- ) handle>> FT_Done_Face ;

: close-freetype ( -- )
    global [
        open-fonts [ [ drop close-font ] assoc-each f ] change
        freetype [ FT_Done_FreeType f ] change
    ] bind ;

M: freetype-renderer free-fonts ( world -- )
    values [ second free-sprites ] each ;

: ttf-name ( font -- name )
    [ [ name>> ] [ bold?>> ] [ italic?>> ] tri ] output>array H{
        { { "monospace" f f } "VeraMono" }
        { { "monospace" t f } "VeraMoBd" }
        { { "monospace" t t } "VeraMoBI" }
        { { "monospace" f t } "VeraMoIt" }
        { { "sans-serif" f f } "Vera" }
        { { "sans-serif" t f } "VeraBd" }
        { { "sans-serif" t t } "VeraBI" }
        { { "sans-serif" f t } "VeraIt" }
        { { "serif" f f } "VeraSe" }
        { { "serif" t f } "VeraSeBd" }
        { { "serif" t t } "VeraBI" }
        { { "serif" f t } "VeraIt" }
    } at ;

: ttf-path ( name -- string )
    "resource:fonts/" ".ttf" surround ;

: (open-face) ( path length -- face )
    #! We use FT_New_Memory_Face, not FT_New_Face, since
    #! FT_New_Face only takes an ASCII path name and causes
    #! problems on localized versions of Windows
    [ freetype ] 2dip 0 f <void*> [
        FT_New_Memory_Face freetype-error
    ] keep *void* ;

: open-face ( font -- face )
    ttf-name ttf-path malloc-file-contents (open-face) ;

SYMBOL: dpi

72 dpi set-global

: ft-floor ( m -- n ) -6 shift ; inline

: ft-ceil ( m -- n ) 63 + -64 bitand -6 shift ; inline

: font-units>pixels ( n font -- n )
    face-size face-size-y-scale FT_MulFix ;

: init-ascent ( font face -- font )
    [ face-y-max ] keep font-units>pixels >>ascent ; inline

: init-descent ( font face -- font )
    [ face-y-min ] keep font-units>pixels >>descent ; inline

: init-font ( font -- font )
    dup handle>> init-ascent
    dup handle>> init-descent
    dup [ ascent>> ] [ descent>> ] bi - ft-ceil >>height ; inline

: set-char-size ( open-font size -- open-font )
    [ dup handle>> 0 ] dip
    6 shift dpi get-global dup FT_Set_Char_Size freetype-error ;

: <freetype-font> ( font -- open-font )
    freetype-font new
        H{ } clone >>widths
        over open-face >>handle
        swap size>> set-char-size
        init-font ;

: open-font ( font -- open-font )
    freetype drop open-fonts get [ <freetype-font> ] cache ;

: load-glyph ( font char -- glyph )
    [ handle>> dup ] dip 0 FT_Load_Char
    freetype-error face-glyph ;

: char-width ( open-font char -- w )
    over widths>> [
        dupd load-glyph glyph-hori-advance ft-ceil
    ] cache nip ;

M: freetype-renderer string-width ( font string -- w )
    [ [ 0 ] dip open-font ] dip [ char-width + ] with each ;

M: freetype-renderer string-height ( font string -- h )
    drop open-font height>> ;

: glyph-size ( glyph -- dim )
    [ glyph-hori-advance ft-ceil ]
    [ glyph-height ft-ceil ]
    bi 2array ;

: render-glyph ( font char -- bitmap )
    load-glyph dup
    FT_RENDER_MODE_NORMAL FT_Render_Glyph freetype-error ;

:: copy-pixel ( i j bitmap texture -- i j )
    255 j texture set-nth
    i bitmap nth j 1 + texture set-nth
    i 1 + j 2 + ; inline

:: (copy-row) ( i j bitmap texture end -- )
    i end < [
        i j bitmap texture copy-pixel
            bitmap texture end (copy-row)
    ] when ; inline recursive

:: copy-row ( i j bitmap texture width width2 -- i j )
    i j bitmap texture i width + (copy-row)
    i width +
    j width2 + ; inline

:: copy-bitmap ( glyph texture -- )
    [let* | bitmap [ glyph glyph-bitmap-buffer ]
            rows [ glyph glyph-bitmap-rows ]
            width [ glyph glyph-bitmap-width ]
            width2 [ width next-power-of-2 2 * ] |
        bitmap [
            bitmap rows width * <direct-uchar-array> :> bitmap'
            0 0
            rows [ bitmap' texture width width2 copy-row ] times
            2drop
        ] when
    ] ;

: bitmap>texture ( glyph sprite -- id )
    tuck dim2>> product 2 * <byte-array>
    [ copy-bitmap ] keep [ dim2>> ] dip
    GL_LUMINANCE_ALPHA GL_UNSIGNED_BYTE make-texture ;

: glyph-texture-loc ( glyph font -- loc )
    [ drop glyph-hori-bearing-x ft-floor ]
    [ ascent>> swap glyph-hori-bearing-y - ft-floor ]
    2bi 2array ;

: glyph-texture-size ( glyph -- dim )
    [ glyph-bitmap-width next-power-of-2 ]
    [ glyph-bitmap-rows next-power-of-2 ]
    bi 2array ;

: <char-sprite> ( open-font char -- sprite )
    over [ render-glyph dup ] dip glyph-texture-loc
    over glyph-size pick glyph-texture-size <sprite>
    [ bitmap>texture ] keep [ init-sprite ] keep ;

:: char-sprite ( open-font sprites char -- sprite )
    char sprites [ open-font swap <char-sprite> ] cache ;

: draw-char ( open-font sprites char loc -- )
    GL_MODELVIEW [
        0 0 glTranslated
        char-sprite dlist>> glCallList
    ] do-matrix ;

: char-widths ( open-font string -- widths )
    [ char-width ] with { } map-as ;

: scan-sums ( seq -- seq' )
    0 [ + ] accumulate nip ;

:: (draw-string) ( open-font sprites string loc -- )
    GL_TEXTURE_2D [
        loc [
            string open-font string char-widths scan-sums [
                [ open-font sprites ] 2dip draw-char
            ] 2each
        ] with-translation
    ] do-enabled ;

: font-sprites ( font world -- open-font sprites )
    fonts>> [ open-font H{ } clone 2array ] cache first2 ;

M: freetype-renderer draw-string ( font string loc -- )
    [ world get font-sprites ] 2dip (draw-string) ;

: run-char-widths ( open-font string -- widths )
    char-widths [ scan-sums ] [ 2 v/n ] bi v+ ;

M: freetype-renderer x>offset ( x font string -- n )
    [ open-font ] dip
    [ run-char-widths [ <= ] with find drop ] keep swap
    [ ] [ length ] ?if ;

M:: freetype-renderer offset>x ( n font string -- x )
    font open-font string n head string-width ;

freetype-renderer font-renderer set-global
