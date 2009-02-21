! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.accessors alien.c-types arrays io kernel libc
math math.vectors namespaces opengl opengl.gl opengl.sprites assocs
sequences io.files continuations freetype
ui.gadgets.worlds ui.text ui.text.private ui.backend
byte-arrays accessors locals specialized-arrays.direct.uchar
combinators.smart fonts memoize ;
IN: ui.text.freetype

SINGLETON: freetype-renderer

M: freetype-renderer finish-text-rendering drop ;

: freetype-error ( n -- )
    0 = [ "FreeType error" throw ] unless ;

DEFER: init-freetype

: freetype ( -- alien )
    \ freetype [ init-freetype ] initialize-alien ;

TUPLE: freetype-font < identity-tuple
ascent descent height handle widths ;

M: freetype-font hashcode* drop freetype-font hashcode* ;

M: freetype-renderer free-fonts ( world -- )
    values [ free-sprites ] each ;

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
    } at [ "No such font" throw ] unless* ;

: ttf-path ( name -- string )
    "resource:fonts/" ".ttf" surround ;

MEMO: ttf-font ( font -- contents length )
    ttf-name ttf-path malloc-file-contents ;

: open-face ( font -- face )
    #! We use FT_New_Memory_Face, not FT_New_Face, since
    #! FT_New_Face only takes an ASCII path name and causes
    #! problems on localized versions of Windows
    [ freetype ] dip ttf-font 0 f <void*>
    [ FT_New_Memory_Face freetype-error ] keep *void* ;

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

MEMO: (open-font) ( font -- open-font )
    freetype-font new
        H{ } clone >>widths
        over open-face >>handle
        swap size>> set-char-size
        init-font ;

GENERIC: open-font ( font -- open-font )

M: font open-font
    freetype drop clone f >>background f >>foreground (open-font) ;

: load-glyph ( font char -- glyph )
    [ handle>> dup ] dip 0 FT_Load_Char
    freetype-error face-glyph ;

: char-width ( open-font char -- w )
    swap [ widths>> ] keep
    [ swap load-glyph glyph-hori-advance ft-ceil ] curry cache ;

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

: sums ( seq -- seq )
    0 [ + ] accumulate nip ;

: font-sprites ( font world -- sprites )
    fonts>> [ drop H{ } clone ] cache ;

: draw-background ( widths open-font -- )
    [ sum ] [ height>> ] bi* 2array gl-fill-rect ;

:: draw-selection ( widths open-font line -- )
    line color>> gl-color
    widths line start>> head-slice sum 0 2array [
        line [ start>> ] [ end>> ] bi widths <slice> sum
        open-font height>> 2array gl-fill-rect
    ] with-translation ;

M:: freetype-renderer draw-string ( font line -- )
    line dup selection? [ string>> ] when :> string
    font open-font :> open-font
    open-font world get font-sprites :> sprites
    open-font string char-widths :> widths
    GL_TEXTURE_2D [
        font background>> gl-color
        widths open-font draw-background
        line selection? [ widths open-font line draw-selection ] when
        font foreground>> gl-color
        string widths sums [ [ open-font sprites ] 2dip draw-char ] 2each
    ] do-enabled ;

: run-char-widths ( open-font string -- widths )
    char-widths [ sums ] [ 2 v/n ] bi v+ ;

M: freetype-renderer x>offset ( x font string -- n )
    [ open-font ] dip
    [ run-char-widths [ <= ] with find drop ] keep swap
    [ ] [ length ] ?if ;

M:: freetype-renderer offset>x ( n font string -- x )
    font string n head-slice string-width ;

M: freetype-renderer line-metrics ( font string -- metrics )
    [ string-width ]
    [ drop open-font [ ascent>> ft-ceil ] [ descent>> ft-ceil ] bi 0 ] 2bi
    metrics boa ;

: init-freetype ( -- )
    global [
        f <void*> dup FT_Init_FreeType freetype-error
        *void* \ freetype set
        \ (open-font) reset-memoized
        \ ttf-font reset-memoized
    ] bind ;

freetype-renderer font-renderer set-global
