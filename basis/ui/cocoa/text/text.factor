! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors alien core-graphics.types core-text kernel
hashtables namespaces sequences ui.gadgets.worlds ui.render
opengl opengl.gl destructors combinators combinators.smart
core-foundation core-foundation.dictionaries core-foundation.numbers
core-foundation.strings io.styles memoize ;
IN: ui.cocoa.text

SINGLETON: core-text-renderer

CONSTANT: font-names
    H{
        { "monospace" "Monaco" }
        { "sans-serif" "Helvetica" }
        { "serif" "Times" }
    }

: (bold) ( -- ) 1.0 kCTFontWeightTrait set ;

: (italic) ( -- ) 1.0 kCTFontSlantTrait set ;

: font-traits ( style -- dictionary )
    [
        {
            { plain [ ] }
            { bold [ (bold) ] }
            { italic [ (italic) ] }
            { bold-italic [ (bold) (italic) ] }
        } case
    ] H{ } make-assoc ;

: font-name-attr ( name -- )
    font-names at-default kCTFontNameAttribute set ;

: font-traits-attr ( style -- )
    font-traits kCTFontTraitsAttribute set ;

: font-size-attr ( size -- )
    kCTFontSizeAttribute set ;

: font-attrs ( font -- dictionary )
    [
        [
            [
                [ font-name-attr ]
                [ font-traits-attr ]
                [ font-size-attr ]
                tri*
            ] input<sequence
        ] H{ } make-assoc
    ] with-destructors ;

MEMO: cache-font ( font -- open-font )
    font-attrs <CTFont> ;

M: core-text-renderer open-font
    dup alien? [ cache-font ] unless ;

: string-dim ( open-font string -- dim )
    swap cached-line dim>> ;

M: core-text-renderer string-width ( open-font string -- w )
    string-dim first ;
 
M: core-text-renderer string-height ( open-font string -- h )
    [ " " ] when-empty string-dim second ;

TUPLE: line-texture line texture age disposed ;

: <line-texture> ( line -- texture )
    dup [ dim>> ] [ bitmap>> ] bi GL_RGBA make-texture
    0 f \ line-texture boa ;

M: line-texture dispose* texture>> delete-texture ;

: line-texture ( string open-font -- texture )
    world get fonts>> [ cached-line <line-texture> ] 2cache ;

: draw-line-texture ( line-texture -- )
    GL_TEXTURE_2D [
        GL_TEXTURE_BIT [
            GL_TEXTURE_COORD_ARRAY [
                GL_TEXTURE_2D over texture>> glBindTexture
                init-texture rect-texture-coords
                line>> dim>> fill-rect-vertices (gl-fill-rect)
                GL_TEXTURE_2D 0 glBindTexture
            ] do-enabled-client-state
        ] do-attribs
    ] do-enabled ;

M: core-text-renderer draw-string ( font string loc -- )
    [ swap open-font line-texture draw-line-texture ] with-translation ;

M: core-text-renderer x>offset ( x font string -- n )
    swap open-font cached-line line>> swap 0 <CGPoint> CTLineGetStringIndexForPosition ;

M: core-text-renderer free-fonts ( fonts -- )
    values dispose-each ;

core-text-renderer font-renderer set-global