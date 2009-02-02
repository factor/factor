! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien alien.c-types alien.syntax kernel
destructors accessors fry words hashtables
sequences memoize assocs math math.functions locals init
namespaces combinators fonts colors core-foundation
core-foundation.strings core-foundation.attributed-strings
core-foundation.utilities core-graphics core-graphics.types
core-text.fonts core-text.utilities ;
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

: <CTLine> ( string open-font color -- line )
    [
        [
            kCTForegroundColorAttributeName set
            kCTFontAttributeName set
        ] H{ } make-assoc <CFAttributedString> &CFRelease
        CTLineCreateWithAttributedString
    ] with-destructors ;

TUPLE: line font line metrics dim bitmap age refs disposed ;

: compute-line-metrics ( line -- line-metrics )
    0 <CGFloat> 0 <CGFloat> 0 <CGFloat>
    [ CTLineGetTypographicBounds ] 3keep [ *CGFloat ] tri@
    line-metrics boa ;

: bounds>dim ( bounds -- dim )
    [ width>> ] [ [ ascent>> ] [ descent>> ] bi + ] bi
    [ ceiling >fixnum ]
    bi@ 2array ;

:: <line> ( font string -- line )
    [
        [let* | open-font [ font cache-font CFRetain |CFRelease ]
                line [ string open-font font foreground>> <CTLine> |CFRelease ]
                metrics [ line compute-line-metrics ]
                dim [ bounds bounds>dim ] |
            dim [
                {
                    [ font background>> >rgba-components CGContextSetRGBFillColor ]
                    [ 0 0 dim first2 <CGRect> CGContextFillRect ]
                    [ 0 metrics descent>> CGContextSetTextPosition ]
                    [ line swap CTLineDraw ]
                } cleave
            ] with-bitmap-context
            [ open-font line bounds dim ] dip 0 0 f
        ]
        line boa
    ] with-destructors ;

M: line dispose* [ font>> CFRelease ] [ line>> CFRelease ] bi ;

: ref/unref-line ( line n -- )
    '[ _ + ] change-refs 0 >>age drop ;

: ref-line ( line -- ) 1 ref/unref-line ;
: unref-line ( line -- ) -1 ref/unref-line ;

SYMBOL: cached-lines

: cached-line ( font string -- line )
    cached-lines get [ <line> ] 2cache ;

CONSTANT: max-line-age 10

: age ( obj -- ? )
    [ 1+ ] change-age age>> max-line-age >= ;

: age-line ( line -- ? )
    #! Outputs t whether the line is dead.
    dup refs>> 0 = [ age ] [ drop f ] if ;

: age-assoc ( assoc quot -- assoc' )
    '[ nip @ ] assoc-partition
    [ values dispose-each ] dip ;

: age-lines ( -- )
    cached-lines global [ [ age-line ] age-assoc ] change-at ;

[ H{ } clone cached-lines set-global ] "core-text" add-init-hook