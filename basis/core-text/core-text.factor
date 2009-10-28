! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien alien.c-types alien.syntax kernel destructors
accessors fry words hashtables strings sequences memoize assocs math
math.order math.vectors math.rectangles math.functions locals init
namespaces combinators fonts colors cache core-foundation
core-foundation.strings core-foundation.attributed-strings
core-foundation.utilities core-graphics core-graphics.types
core-text.fonts ;
IN: core-text

TYPEDEF: void* CTLineRef

C-GLOBAL: CFStringRef kCTFontAttributeName
C-GLOBAL: CFStringRef kCTKernAttributeName
C-GLOBAL: CFStringRef kCTLigatureAttributeName
C-GLOBAL: CFStringRef kCTForegroundColorAttributeName
C-GLOBAL: CFStringRef kCTParagraphStyleAttributeName
C-GLOBAL: CFStringRef kCTUnderlineStyleAttributeName
C-GLOBAL: CFStringRef kCTVerticalFormsAttributeName
C-GLOBAL: CFStringRef kCTGlyphInfoAttributeName

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

TUPLE: line < disposable line metrics image loc dim ;

: typographic-bounds ( line -- width ascent descent leading )
    0 <CGFloat> 0 <CGFloat> 0 <CGFloat>
    [ CTLineGetTypographicBounds ] 3keep [ *CGFloat ] tri@ ; inline

: store-typographic-bounds ( metrics width ascent descent leading -- metrics )
    {
        [ >>width ]
        [ >>ascent ]
        [ >>descent ]
        [ >>leading ]
    } spread ; inline

: compute-font-metrics ( metrics font -- metrics )
    [ CTFontGetCapHeight >>cap-height ]
    [ CTFontGetXHeight >>x-height ]
    bi ; inline

: compute-line-metrics ( open-font line -- line-metrics )
    [ metrics new ] 2dip
    [ compute-font-metrics ]
    [ typographic-bounds store-typographic-bounds ] bi*
    compute-height ;

: metrics>dim ( bounds -- dim )
    [ width>> ] [ [ ascent>> ] [ descent>> ] bi + ] bi
    [ ceiling >integer ]
    bi@ 2array ;

: fill-background ( context font dim -- )
    [ background>> >rgba-components CGContextSetRGBFillColor ]
    [ [ 0 0 ] dip first2 <CGRect> CGContextFillRect ]
    bi-curry* bi ;

: selection-rect ( dim line selection -- rect )
    [ start>> ] [ end>> ] bi
    [ f CTLineGetOffsetForStringIndex round ] bi-curry@ bi
    [ drop nip 0 ] [ swap - swap second ] 3bi <CGRect> ;

: CGRect-translate-x ( CGRect x -- CGRect' )
    [ dup CGRect-x ] dip - over set-CGRect-x ;

:: fill-selection-background ( context loc dim line string -- )
    string selection? [
        context string color>> >rgba-components CGContextSetRGBFillColor
        context dim line string selection-rect
        loc first CGRect-translate-x
        CGContextFillRect
    ] when ;

: line-rect ( line -- rect )
    dummy-context CTLineGetImageBounds ;

: set-text-position ( context loc -- )
    first2 [ neg ] bi@ CGContextSetTextPosition ;

:: line-loc ( metrics loc dim -- loc )
    loc first
    metrics ascent>> ceiling dim second loc second + - 2array ;

:: <line> ( font string -- line )
    [
        line new-disposable

        font cache-font :> open-font
        string open-font font foreground>> <CTLine> |CFRelease :> line

        line line-rect :> rect
        rect origin>> CGPoint>loc :> (loc)
        rect size>> CGSize>dim :> (dim)
        (loc) (dim) v+ :> (ext)
        (loc) [ floor ] map :> loc
        (loc) (dim) [ + ceiling ] 2map :> ext
        ext loc [ - >integer 1 max ] 2map :> dim
        open-font line compute-line-metrics :> metrics

        line >>line

        metrics >>metrics

        dim [
            {
                [ font dim fill-background ]
                [ loc dim line string fill-selection-background ]
                [ loc set-text-position ]
                [ [ line ] dip CTLineDraw ]
            } cleave
        ] make-bitmap-image >>image

        metrics loc dim line-loc >>loc

        metrics metrics>dim >>dim
    ] with-destructors ;

M: line dispose* line>> CFRelease ;

SYMBOL: cached-lines

: cached-line ( font string -- line )
    cached-lines get [ <line> ] 2cache ;

[ <cache-assoc> cached-lines set-global ] "core-text" add-init-hook
