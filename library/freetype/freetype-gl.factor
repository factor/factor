! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien arrays errors hashtables io kernel
kernel-internals lists math namespaces opengl prettyprint
sequences styles ;
IN: freetype

! Memory management: freetype is allocated and freed by
! with-freetype.
SYMBOL: freetype
SYMBOL: open-fonts

: freetype-error ( n -- ) 0 = [ "FreeType error" throw ] unless ;

: init-freetype ( -- )
    global [
        f <void*> dup FT_Init_FreeType freetype-error
        *void* freetype set
        {{ }} clone open-fonts set
    ] bind ;

: free-dlists ( seq -- )
    drop ;

: free-textures ( seq -- )
    drop ;

: free-sprites ( glyphs -- )
    dup [ sprite-dlist ] map free-dlists
    [ sprite-texture ] map free-textures ;

! A font object from FreeType.
! the handle is an FT_Face.
! sprites is a vector.
TUPLE: font ascent descent height handle sprites ;

: flush-font ( font -- )
    #! Only do this after re-creating a GL context!
    dup font-sprites [ ] subset free-sprites
    { } clone swap set-font-sprites ;

: close-font ( font -- )
    dup flush-font font-handle FT_Done_Face ;

: flush-fonts ( -- )
    #! Only do this after re-creating a GL context!
    open-fonts get hash-values [ flush-font ] each ;

: close-freetype ( -- )
    global [
        open-fonts get hash-values [ close-font ] each
        open-fonts off
        freetype get FT_Done_FreeType
    ] bind ;

: with-freetype ( quot -- )
    init-freetype [ close-freetype ] cleanup ; inline

: ttf-name ( font style -- name )
    cons {{
        [[ [[ "Monospaced" plain       ]] "VeraMono" ]]
        [[ [[ "Monospaced" bold        ]] "VeraMoBd" ]]
        [[ [[ "Monospaced" bold-italic ]] "VeraMoBI" ]]
        [[ [[ "Monospaced" italic      ]] "VeraMoIt" ]]
        [[ [[ "Sans Serif" plain       ]] "Vera"     ]]
        [[ [[ "Sans Serif" bold        ]] "VeraBd"   ]]
        [[ [[ "Sans Serif" bold-italic ]] "VeraBI"   ]]
        [[ [[ "Sans Serif" italic      ]] "VeraIt"   ]]
        [[ [[ "Serif" plain            ]] "VeraSe"   ]]
        [[ [[ "Serif" bold             ]] "VeraSeBd" ]]
        [[ [[ "Serif" bold-italic      ]] "VeraBI"   ]]
        [[ [[ "Serif" italic           ]] "VeraIt"   ]]
    }} hash ;

: ttf-path ( name -- string )
    [ "/fonts/" % % ".ttf" % ] "" make resource-path ;

: open-face ( font style -- face )
    #! Open a TrueType font with the given logical name and
    #! style.
    ttf-name ttf-path >r freetype get r>
    0 f <void*> [ FT_New_Face freetype-error ] keep *void* ;

: dpi 72 ;

: fix>int 64 /i ;

: font-units>pixels ( n font -- n )
    face-size face-size-y-scale FT_MulFix fix>int ;

: init-ascent ( font face -- )
    dup face-y-max swap font-units>pixels swap set-font-ascent ;

: init-descent ( font face -- )
    dup face-y-min swap font-units>pixels swap set-font-descent ;

: init-font ( font -- )
    dup font-handle 2dup init-ascent dupd init-descent
    dup font-ascent over font-descent - swap set-font-height ;

C: font ( handle -- font )
    [ set-font-handle ] keep dup flush-font dup init-font ;

: open-font ( { font style ptsize } -- font )
    #! Open a font and set the point size of the font.
    first3 >r open-face dup 0 r> 6 shift
    dpi dpi FT_Set_Char_Size freetype-error <font> ;

: lookup-font ( font style ptsize -- font )
    #! Cache open fonts.
    3array open-fonts get [ open-font ] cache ;

: load-glyph ( font char -- glyph )
    >r font-handle r> dupd 0 FT_Load_Char
    freetype-error face-glyph ;

: glyph-size ( glyph -- dim )
    dup glyph-advance-x fix>int
    swap glyph-height fix>int 0 3array ;

: render-glyph ( font char -- bitmap )
    #! Render a character and return a pointer to the bitmap.
    load-glyph dup
    FT_RENDER_MODE_NORMAL FT_Render_Glyph freetype-error ;

: with-locked-block ( size quot -- | quot: address -- )
    swap 1 calloc [ swap call ] keep free ; inline

: b/b>w 8 shift bitor ;

: copy-pixel ( bit tex -- bit tex )
    f pick alien-unsigned-1 255 b/b>w
    f pick set-alien-unsigned-2
    >r 1+ r> 2 + ;

: (copy-row) ( bit tex bitend texend -- bitend texend )
    >r pick over >= [
        r> 2swap 2drop
    ] [
        >r copy-pixel r> r> (copy-row)
    ] if ;

: copy-row ( bit tex width width2 -- bitend texend width width2 )
    [ pick + >r pick + r> (copy-row) ] 2keep ;

: copy-bitmap ( glyph texture -- )
    over glyph-bitmap-rows >r
    over glyph-bitmap-width dup next-power-of-2 2 *
    >r >r >r glyph-bitmap-buffer alien-address r> r> r> r> 
    [ copy-row ] times 2drop 2drop ;

: bitmap>texture ( glyph sprite -- id )
    #! Given a glyph bitmap, copy it to a texture with the given
    #! width/height (which must be powers of two).
    tuck sprite-size2 * 2 * [
        [ copy-bitmap ] keep <alien> gray-texture
    ] with-locked-block ;

: glyph-texture-loc ( glyph font -- loc )
    font-ascent swap glyph-hori-bearing-y fix>int -
    0 swap 0 3array ;

: glyph-texture-size ( glyph -- dim )
    dup glyph-bitmap-width next-power-of-2
    swap glyph-bitmap-rows next-power-of-2 0 3array ;

: <char-sprite> ( font char -- sprite )
    #! Create a new display list of a rendered glyph. This
    #! allocates external resources. See free-sprites.
    over >r render-glyph dup r> glyph-texture-loc
    over glyph-size pick glyph-texture-size <sprite>
    [ bitmap>texture ] keep [ init-sprite ] keep ;

: char-sprite ( open-font char -- sprite )
    #! Get a cached display list of a FreeType-rendered
    #! glyph.
    over font-sprites [ dupd <char-sprite> ] cache-nth nip ;

: char-width ( open-font char -- w )
    char-sprite sprite-width ;

: string-width ( open-font string -- w )
    0 -rot [ char-width + ] each-with ;

: draw-string ( open-font string -- )
    GL_MODELVIEW [
        GL_TEXTURE_BIT [
            [ char-sprite sprite-dlist glCallList ] each-with
        ] save-attribs
    ] do-matrix ;
