! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: #<unknown> alien arrays errors hashtables io kernel
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

! A sprite are a texture and display list.
TUPLE: sprite dlist texture ;

: free-dlists ( seq -- )
    "Freeing display lists: " print . ;

: free-textures ( seq -- )
    "Freeing textures: " print . ;

: free-sprites ( glyphs -- )
    dup [ sprite-dlist ] map free-dlists
    [ sprite-texture ] map free-textures ;

! A font object from FreeType.
! the handle is an FT_Face.
! sprites is a vector.
TUPLE: font height handle sprites metrics ;

: close-font ( font -- )
    dup font-sprites [ ] subset free-sprites
    font-handle FT_Done_Face ;

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

: dpi 100 ;

: fix>float 64 /f ;

: font-units>pixels ( n font -- n )
    face-size face-size-y-scale FT_MulFix fix>float ;

: init-font-height ( font -- )
    dup font-handle
    dup face-y-max over face-y-min - swap font-units>pixels 
    swap set-font-height ;

C: font ( handle -- font )
    { } clone over set-font-sprites
    { } clone over set-font-metrics
    [ set-font-handle ] keep
    dup init-font-height ;

: open-font ( { font style ptsize } -- font )
    #! Open a font and set the point size of the font.
    first3 >r open-face dup 0 r> 6 shift
    dpi dpi FT_Set_Char_Size freetype-error <font> ;

: lookup-font ( font style ptsize -- font )
    #! Cache open fonts.
    3array open-fonts get [ open-font ] cache ;

: load-glyph ( face char -- glyph )
    dupd 0 FT_Load_Char freetype-error face-glyph ;

: (char-size) ( font char -- dim )
    >r font-handle r> load-glyph
    dup glyph-width fix>float
    swap glyph-height fix>float 0 3array ;

: char-size ( open-font char -- w h )
    over font-metrics [ dupd (char-size) ] cache-nth nip first2 ;

: string-size ( font string -- w h )
    0 pick font-height
    2swap [ char-size >r rot + swap r> max ] each-with ;

: render-glyph ( face char -- bitmap )
    #! Render a character and return a pointer to the bitmap.
    load-glyph dup
    FT_RENDER_MODE_NORMAL FT_Render_Glyph freetype-error ;

: with-locked-block ( size quot -- | quot: address -- )
    swap malloc [ swap call ] keep free ; inline

: (copy-bitmap) ( bitmap-chase texture-chase width width-pow2 )
    >r 3dup swapd memcpy tuck >r >r + r> r> r> tuck >r >r + r> r> ;

: copy-bitmap ( glyph texture width-pow2 -- )
    pick glyph-bitmap-rows >r >r over glyph-bitmap-pitch >r >r
    glyph-bitmap-buffer alien-address r> r> r> r>
    [ (copy-bitmap) ] times 2drop 2drop ;

: bitmap>texture ( width height glyph -- id )
    #! Given a glyph bitmap, copy it to a texture with the given
    #! width/height (which must be powers of two).
    3drop
    32 32 * 4 * [
        <alien> 32 32 * 4 * [
            128 pick rot set-alien-signed-1
        ] each 32 32 rot gray-texture
    ] with-locked-block ;

: char-texture-size ( bitmap -- width height )
    dup glyph-bitmap-width swap glyph-bitmap-rows
    [ next-power-of-2 ] 2apply ;

: <char-sprite> ( face char -- sprite )
    render-glyph [ char-texture-size 2dup ] keep
    bitmap>texture [ texture>dlist ] keep <sprite> ;

: char-sprite ( open-font char -- sprite )
    over font-sprites
    [ >r dup font-handle r> <char-sprite> ] cache-nth nip ;

: draw-string ( font string -- )
    GL_TEXTURE_BIT [
        [ char-sprite sprite-dlist glCallList ] each-with
    ] save-attribs ;
