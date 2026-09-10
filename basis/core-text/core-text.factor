! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types alien.data alien.syntax arrays byte-arrays
assocs binary-search cache classes colors combinators core-foundation core-foundation.arrays
core-foundation.attributed-strings core-foundation.strings
core-foundation.dictionaries
core-graphics core-graphics.types core-text.fonts destructors
fonts io.encodings.string io.encodings.utf16 kernel layouts make math
math.functions math.order math.vectors namespaces opengl sequences
sorting strings vectors ;
IN: core-text

TYPEDEF: void* CTLineRef
TYPEDEF: void* CTRunRef

C-GLOBAL: CFStringRef kCTFontAttributeName
C-GLOBAL: CFStringRef kCTKernAttributeName
C-GLOBAL: CFStringRef kCTLigatureAttributeName
C-GLOBAL: CFStringRef kCTForegroundColorAttributeName
C-GLOBAL: CFStringRef kCTParagraphStyleAttributeName
C-GLOBAL: CFStringRef kCTUnderlineStyleAttributeName
C-GLOBAL: CFStringRef kCTVerticalFormsAttributeName
C-GLOBAL: CFStringRef kCTGlyphInfoAttributeName

FUNCTION: CTLineRef CTLineCreateWithAttributedString ( CFAttributedStringRef string )

FUNCTION: void CTLineDraw ( CTLineRef line, CGContextRef context )

FUNCTION: CGFloat CTLineGetOffsetForStringIndex ( CTLineRef line, CFIndex charIndex, CGFloat* secondaryOffset )

FUNCTION: CFIndex CTLineGetStringIndexForPosition ( CTLineRef line, CGPoint position )

FUNCTION: double CTLineGetTypographicBounds ( CTLineRef line, CGFloat* ascent, CGFloat* descent, CGFloat* leading )

FUNCTION: CGRect CTLineGetImageBounds ( CTLineRef line, CGContextRef context )

FUNCTION: CFIndex CTLineGetGlyphCount ( CTLineRef line )
FUNCTION: CFArrayRef CTLineGetGlyphRuns ( CTLineRef line )
FUNCTION: CFIndex CTRunGetGlyphCount ( CTRunRef run )
FUNCTION: void CTRunDraw ( CTRunRef run, CGContextRef context, CFRange range )
FUNCTION: CFDictionaryRef CTRunGetAttributes ( CTRunRef run )
! Use the raw pointer to read coordinates without allocating a CGPoint per glyph.
FUNCTION: void* CTRunGetPositionsPtr ( CTRunRef run )
FUNCTION: CFRange CTRunGetStringRange ( CTRunRef run )
FUNCTION: uint32_t CTRunGetStatus ( CTRunRef run )
CONSTANT: kCTRunStatusRightToLeft 1
CONSTANT: kCTRunStatusHasNonIdentityMatrix 4
FUNCTION: void CTRunGetPositions ( CTRunRef run, CFRange range, CGPoint* positions )
FUNCTION: double CTRunGetTypographicBounds ( CTRunRef run, CFRange range, CGFloat* ascent, CGFloat* descent, CGFloat* leading )

MEMO: make-attributes ( open-font color -- hashtable )
    [
        kCTForegroundColorAttributeName ,,
        kCTFontAttributeName ,,
    ] H{ } make ;

: <CTLine> ( string open-font color -- line )
    [
        [
            dup selection? [ string>> ] when
            string check-instance
        ] 2dip
        make-attributes <CFAttributedString> &CFRelease
        CTLineCreateWithAttributedString
    ] with-destructors ;

TUPLE: line < disposable font string line metrics image loc dim
render-loc render-dim render-ext selection-key selection-spans index-map render-index ;

: typographic-bounds ( line -- width ascent descent leading )
    { CGFloat CGFloat CGFloat }
    [ CTLineGetTypographicBounds ] with-out-parameters ; inline

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
    [ ceiling ] bi@ 2array ;

: fill-background ( context font dim -- )
    [ background>> >rgba-components CGContextSetRGBFillColor ]
    [ [ 0 0 ] dip first2 <CGRect> CGContextFillRect ]
    bi-curry* bi ;

: string-index>utf16 ( n string -- index )
    swap head utf16n encode length 2 /i ;

: line-string ( line -- string )
    string>> dup selection? [ string>> ] when ;

! Only supplementary characters change the relationship between Factor and
! UTF-16 indices. Build a sparse map on the first caret/selection operation;
! ASCII needs no scan, and layout-only lines need no map at all.
:: line-index-map ( line -- map )
    line index-map>> [ ] [
        line line-string :> string
        string aux>> [
            [ string [| ch i | ch 0xffff > [ i , ] when ] each-index ] { } make
        ] [ { } ] if :> positions
        positions dup [ + ] map-index 2array
        dup line index-map<<
    ] if* ;

:: indices-before ( n positions -- count )
    n positions natural-search :> ( i value )
    value [ i value n < [ 1 + ] when ] [ 0 ] if ;

:: line-index>utf16 ( n line -- index )
    n n line line-index-map first indices-before + ;

:: utf16>line-index ( index line -- n )
    index 0 max :> clamped
    clamped clamped line line-index-map second indices-before -
    line line-string length min ;

: run-x ( run -- x )
    0 1 <CFRange> { CGPoint } [ CTRunGetPositions ] with-out-parameters x>> ;

! A logical selection can occupy disjoint visual intervals in a bidi line.
! At run boundaries, primary caret offsets alone refer to the line direction
! and can choose the opposite edge of the selected run.
:: run-selection-span ( ctline run start end -- span/f )
    run CTRunGetStringRange [ location>> ] [ length>> ] bi over + :> ( a b )
    start a max :> lo
    end b min :> hi
    lo hi < [
        run run-x :> left
        run 0 0 <CFRange> f f f CTRunGetTypographicBounds left + :> right
        run CTRunGetStatus kCTRunStatusRightToLeft bitand zero?
        [ left right ] [ right left ] if :> ( leading trailing )
        lo a = [ leading ] [ ctline lo f CTLineGetOffsetForStringIndex ] if
        hi b = [ trailing ] [ ctline hi f CTLineGetOffsetForStringIndex ] if
        [ min ] [ max ] 2bi 2array
    ] [ f ] if ;

! Merge touching runs before painting translucent highlights, so fractional
! run boundaries do not receive antialias coverage twice.
:: merge-selection-spans ( spans -- merged )
    V{ } clone :> merged
    spans [ first ] sort-by [| span |
        merged empty? [ span merged push ] [
            merged last :> previous
            span first previous second <= [
                previous first previous second span second max 2array
                merged set-last
            ] [ span merged push ] if
        ] if
    ] each
    merged >array ;

:: line-selection-spans ( line start end -- spans )
    start end [ min ] [ max ] 2bi 2array :> key
    line selection-key>> key = [ line selection-spans>> ] [
        key [ line line-index>utf16 ] map first2 :> ( a b )
        line line>> :> ctline
        a b = [
            ctline a f CTLineGetOffsetForStringIndex dup 2array 1array
        ] [
            ctline CTLineGetGlyphRuns CF>array
            [ ctline swap a b run-selection-span ] map sift merge-selection-spans
        ] if :> spans
        key line selection-key<<
        spans line selection-spans<<
        spans
    ] if ;

: CGRect-translate-x ( CGRect x -- CGRect' )
    [ dup CGRect-x ] dip - over set-CGRect-x ;

:: fill-selection-background ( context loc dim line -- )
    line string>> :> string
    string selection? [
        context string color>> >rgba-components CGContextSetRGBFillColor
        line string [ start>> ] [ end>> ] bi line-selection-spans [
            first2 :> ( a b )
            context a loc first - 0 b a - dim second <CGRect> CGContextFillRect
        ] each
    ] when ;

: line-rect ( line -- rect )
    dummy-context CTLineGetImageBounds ;

: set-text-position ( context loc -- )
    first2 [ neg ] bi@ CGContextSetTextPosition ;

:: line-loc ( metrics loc dim -- loc )
    loc first round >integer
    metrics ascent>> dim second loc second + - round >integer 1 - 2array ;

:: <line> ( font string -- line )
    [
        line new-disposable
        font cache-font :> open-font
        string open-font font foreground>> <CTLine> |CFRelease :> line
        open-font line compute-line-metrics
        [ >>metrics ] [ metrics>dim >>dim ] bi
        font >>font
        string >>string
        line >>line
    ] with-destructors ;

! The single-image API is bounded; the UI renders regions of the full line.
CONSTANT: max-layout-dim 16383

:: prepare-render ( line -- )
    line render-loc>> [
        line line>> line-rect :> rect
        rect origin>> CGPoint>loc :> (loc)
        rect size>> CGSize>dim :> (dim)
        ! Image bounds describe paths, not all antialias coverage. Include
        ! a guard on every side, and typographic bounds for backgrounds
        ! (including whitespace) and selections.
        line string>> selection?
        line font>> background>> >rgba alpha>> zero? not or [
            (loc) 0 line metrics>> descent>> neg 2array vmin
            (loc) (dim) v+ line metrics>>
            [ width>> ] [ ascent>> ] bi 2array vmax
        ] [ (loc) (loc) (dim) v+ ] if
        [ vfloor { 1 1 } v- ] [ vceiling { 1 1 } v+ ] bi* :> ( loc end )
        end loc v- [ >integer ] map :> ext
        ext { 1 1 } v- :> dim
        loc line render-loc<<
        dim line render-dim<<
        ext line render-ext<<
        line metrics>> loc dim line-loc line loc<<
    ] unless ;

! Region coordinates are measured from the top-left of the complete image.
! Keep the original CTLine so shaping, bidi, and ligatures cross tile edges.
TUPLE: glyph-region run range left right order max-right ;

:: glyph-position-x ( positions i -- x )
    positions i cell 2 * * cell 8 = [ alien-double ] [ alien-float ] if ; inline

:: <glyph-region> ( run positions start count bounds order -- region )
    1/0. :> left!
    -1/0. :> right!
    count <iota> [| i |
        positions start i + glyph-position-x :> x
        x left min left!
        x right max right!
    ] each
    glyph-region new run >>run start count <CFRange> >>range order >>order
    left bounds CGRect-x + 2 - >>left
    right bounds CGRect-x + bounds CGRect-w + 2 + >>right ;

:: add-run-regions ( run regions -- )
    run CTRunGetGlyphCount :> count
    count zero? [
        run CTRunGetAttributes kCTFontAttributeName CFDictionaryGetValue
        CTFontGetBoundingBox :> bounds
        run CTRunGetStatus kCTRunStatusHasNonIdentityMatrix bitand zero? [
            run CTRunGetPositionsPtr [ ] [
                count cell 2 * * <byte-array> :> positions
                run 0 count <CFRange> positions CTRunGetPositions
                positions
            ] if* :> positions
            count 255 + 256 /i <iota> [| i |
                run positions i 256 * count i 256 * - 256 min bounds regions length
                <glyph-region> regions push
            ] each
        ] [
            ! Unusual text matrices retain native drawing without culling.
            glyph-region new run >>run 0 count <CFRange> >>range
            -1/0. >>left 1/0. >>right regions length >>order regions push
        ] if
    ] unless ;

:: line-render-index ( line -- regions )
    line render-index>> [ ] [
        V{ } clone :> regions
        line line>> CTLineGetGlyphRuns CF>array [ regions add-run-regions ] each
        regions [ left>> ] sort-by :> sorted
        -1/0. :> right!
        sorted [| region |
            right region right>> max right!
            right region max-right<<
        ] each
        sorted dup line render-index<<
    ] if* ;

:: visible-glyph-regions ( line left right -- regions )
    line line-render-index :> regions
    0 :> lo!
    regions length :> hi!
    [ lo hi < ] [
        lo hi + 2 /i :> mid
        mid regions nth max-right>> left <
        [ mid 1 + lo! ] [ mid hi! ] if
    ] while
    V{ } clone :> visible
    [ lo regions length < [ lo regions nth left>> right <= ] [ f ] if ] [
        lo regions nth :> region
        region right>> left >= [ region visible push ] when
        lo 1 + lo!
    ] while
    ! Spatial lookup must not change the paint order of overlapping glyphs.
    visible [ order>> ] sort-by ;

:: draw-line-region ( context line loc dim -- )
    line line>> CTLineGetGlyphCount 4096 > [
        line loc first loc first dim first + visible-glyph-regions [| region |
            context CGContextSaveGState
            region run>> context region range>> CTRunDraw
            context CGContextRestoreGState
        ] each
    ] [ line line>> context CTLineDraw ] if ;

:: render-region ( line offset dim -- image )
    line prepare-render
    line render-loc>> offset first
    line render-ext>> second offset second - dim second - 2array v+ :> loc
    line font>> :> font
    dim [
        {
            [ font dim fill-background ]
            [ loc dim line fill-selection-background ]
            ! Keep Core Text's baseline at zero. Moving the text position
            ! outside a tile changes rasterization of large color emoji.
            [ loc first2 [ neg ] bi@ CGContextTranslateCTM ]
            [ line loc dim draw-line-region ]
        } cleave
    ] make-bitmap-image ;

:: render ( line -- line image )
    line prepare-render
    line line { 0 0 } line render-ext>>
    [ max-layout-dim 1 + min ] map render-region ;

: line>image ( line -- image )
    dup image>> [ render >>image ] unless image>> ;

M: line dispose* line>> CFRelease ;

SYMBOL: cached-lines

: cached-line ( font string -- line )
    gl-scale-factor get-global 3array
    cached-lines get-global [ first2 <line> ] cache ;

STARTUP-HOOK: [ <cache-assoc> cached-lines set-global ]
