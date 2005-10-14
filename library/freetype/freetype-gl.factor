! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: #<unknown> alien arrays errors hashtables io kernel lists
math namespaces opengl prettyprint sequences styles ;
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
TUPLE: sprite width height dlist texture ;

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

: font-units>pixels ( n font-size -- n )
    face-size-y-scale FT_MulFix fix>float ;

: init-font-height ( font -- )
    dup font-handle face-size 
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

: fix>float 64 /f ;

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

: copy-row ( width texture bitmap row -- )
    #! Copy a row of the bitmap to the texture.
    2drop 2drop ;

: <glyph-texture> ( bitmap -- texture )
    dup glyph-bitmap-width next-power-of-2
    swap glyph-bitmap-rows next-power-of-2 * <c-object> ;

: copy-glyph ( bitmap texture -- )
    #! Copy a bitmap into a texture whose width/height are
    #! the width/height of the bitmap rounded up to the nearest
    #! power of 2.
    >r [ bitmap-width next-power-of-2 ] keep r>
    over bitmap-rows [ >r 3dup r> copy-row ] each 3drop ;

: glyph>texture ( bitmap -- texture )
    #! Given a glyph bitmap, copy it to a texture whose size is
    #! a power of two.
    dup <glyph-texture> [ copy-glyph ] keep ;

: <char-sprite> ( font char -- sprite )
    0 0 <sprite> ;

: char-sprite ( open-font char -- sprite )
    over font-sprites [ dupd <char-sprite> ] cache-nth nip ;

: draw-string ( font string -- )
    [ char-sprite drop ( sprite-dlist glCallList ) ] each-with ;
