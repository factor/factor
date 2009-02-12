! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien alien.c-types alien.syntax kernel destructors
accessors fry words hashtables strings sequences memoize assocs math
math.functions locals init namespaces combinators fonts colors cache
images endian core-foundation core-foundation.strings
core-foundation.attributed-strings core-foundation.utilities
core-graphics core-graphics.types core-text.fonts core-text.utilities ;
IN: core-text

TYPEDEF: void* CTLineRef

C-GLOBAL: kCTFontAttributeName
C-GLOBAL: kCTKernAttributeName
C-GLOBAL: kCTLigatureAttributeName
C-GLOBAL: kCTForegroundColorAttributeName
C-GLOBAL: kCTParagraphStyleAttributeName
C-GLOBAL: kCTUnderlineStyleAttributeName
C-GLOBAL: kCTVerticalFormsAttributeName
C-GLOBAL: kCTGlyphInfoAttributeName

FUNCTION: CTLineRef CTLineCreateWithAttributedString ( CFAttributedStringRef string ) ;

FUNCTION: void CTLineDraw ( CTLineRef line, CGContextRef context ) ;

FUNCTION: CGFloat CTLineGetOffsetForStringIndex ( CTLineRef line, CFIndex charIndex, CGFloat* secondaryOffset ) ;

FUNCTION: CFIndex CTLineGetStringIndexForPosition ( CTLineRef line, CGPoint position ) ;

FUNCTION: double CTLineGetTypographicBounds ( CTLineRef line, CGFloat* ascent, CGFloat* descent, CGFloat* leading ) ;

FUNCTION: CGRect CTLineGetImageBounds ( CTLineRef line, CGContextRef context ) ;

ERROR: not-a-string object ;

: <CTLine> ( string open-font color -- line )
    [
        [
            dup selection? [ string>> ] when
            dup string? [ not-a-string ] unless
        ] 2dip
        [
            kCTForegroundColorAttributeName set
            kCTFontAttributeName set
        ] H{ } make-assoc <CFAttributedString> &CFRelease
        CTLineCreateWithAttributedString
    ] with-destructors ;

TUPLE: line font line metrics image disposed ;

: compute-line-metrics ( line -- line-metrics )
    0 <CGFloat> 0 <CGFloat> 0 <CGFloat>
    [ CTLineGetTypographicBounds ] 3keep [ *CGFloat ] tri@
    metrics boa ;

: bounds>dim ( bounds -- dim )
    [ width>> ] [ [ ascent>> ] [ descent>> ] bi + ] bi
    [ ceiling >fixnum ]
    bi@ 2array ;

: fill-background ( context font dim -- )
    [ background>> >rgba-components CGContextSetRGBFillColor ]
    [ [ 0 0 ] dip first2 <CGRect> CGContextFillRect ]
    bi-curry* bi ;

: selection-rect ( dim line selection -- rect )
    [ start>> ] [ end>> ] bi
    [ f CTLineGetOffsetForStringIndex ] bi-curry@ bi
    [ drop nip 0 ] [ swap - swap second ] 3bi <CGRect> ;

:: fill-selection-background ( context dim line string -- )
    string selection? [
        context string color>> >rgba-components CGContextSetRGBFillColor
        context dim line string selection-rect CGContextFillRect
    ] when ;

: set-text-position ( context metrics -- )
    [ 0 ] dip descent>> ceiling CGContextSetTextPosition ;

: <line-image> ( dim bitmap -- image )
    <image>
        swap >>bitmap
        swap >>dim
        BGRA >>component-order
        native-endianness >>byte-order ;

:: <line> ( font string -- line )
    [
        [let* | open-font [ font cache-font CFRetain |CFRelease ]
                line [ string open-font font foreground>> <CTLine> |CFRelease ]
                metrics [ line compute-line-metrics ]
                dim [ metrics bounds>dim ] |
            dim [
                {
                    [ font dim fill-background ]
                    [ dim line string fill-selection-background ]
                    [ metrics set-text-position ]
                    [ [ line ] dip CTLineDraw ]
                } cleave
            ] with-bitmap-context
            [ open-font line metrics dim ] dip <line-image>
        ]
        f line boa
    ] with-destructors ;

M: line dispose* [ font>> CFRelease ] [ line>> CFRelease ] bi ;

SYMBOL: cached-lines

: cached-line ( font string -- line )
    cached-lines get [ <line> ] 2cache ;

[ <cache-assoc> cached-lines set-global ] "core-text" add-init-hook