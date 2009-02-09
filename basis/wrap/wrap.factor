USING: kernel sequences math arrays locals fry accessors
lists splitting call make combinators.short-circuit namespaces
grouping splitting.monotonic ;
IN: wrap

<PRIVATE

! black is the text length, white is the whitespace length
TUPLE: element contents black white ;
C: <element> element

: element-length ( element -- n )
    [ black>> ] [ white>> ] bi + ;

: swons ( cdr car -- cons )
    swap cons ;

: unswons ( cons -- cdr car )
    [ cdr ] [ car ] bi ;

: 1list? ( list -- ? )
    { [ ] [ cdr +nil+ = ] } 1&& ;

: lists>arrays ( lists -- arrays )
    [ list>seq ] lmap>array ;

TUPLE: paragraph lines head-width tail-cost ;
C: <paragraph> paragraph

SYMBOL: line-max
SYMBOL: line-ideal

: deviation ( length -- n )
    line-ideal get - sq ;

: top-fits? ( paragraph -- ? )
    [ head-width>> ]
    [ lines>> 1list? line-ideal line-max ? get ] bi <= ;

: fits? ( paragraph -- ? )
    ! Make this not count spaces at end
    { [ lines>> car 1list? ] [ top-fits? ] } 1|| ;

:: min-by ( seq quot -- elt )
    f 1.0/0.0 seq [| key value new |
        new quot call :> newvalue
        newvalue value < [ new newvalue ] [ key value ] if
    ] each drop ; inline

: paragraph-cost ( paragraph -- cost )
    [ head-width>> deviation ]
    [ tail-cost>> ] bi + ;

: min-cost ( paragraphs -- paragraph )
    [ paragraph-cost ] min-by ;

: new-line ( paragraph element -- paragraph )
    [ [ lines>> ] [ 1list ] bi* swons ]
    [ nip black>> ]
    [ drop paragraph-cost ] 2tri
    <paragraph> ;

: glue ( paragraph element -- paragraph )
    [ [ lines>> unswons ] dip swons swons ]
    [ [ head-width>> ] [ element-length ] bi* + ]
    [ drop tail-cost>> ] 2tri
    <paragraph> ;

: wrap-step ( paragraphs element -- paragraphs )
    [ '[ _ glue ] map ]
    [ [ min-cost ] dip new-line ]
    2bi prefix
    [ fits? ] filter ;

: 1paragraph ( element -- paragraph )
    [ 1list 1list ]
    [ black>> ] bi
    0 <paragraph> ;

: post-process ( paragraph -- array )
    lines>> lists>arrays
    [ [ contents>> ] map ] map ;

: initialize ( elements -- elements paragraph )
    <reversed> unclip-slice 1paragraph 1array ;

: wrap ( elements line-max line-ideal -- paragraph )
    [
        line-ideal set
        line-max set
        initialize
        [ wrap-step ] reduce
        min-cost
        post-process
    ] with-scope ;

PRIVATE>

TUPLE: segment key width break? ;
C: <segment> segment

<PRIVATE

: segments-length ( segments -- length )
    [ width>> ] map sum ;

: make-element ( whites blacks -- element )
    [ append ] [ [ segments-length ] bi@ ] 2bi <element> ;
 
: ?first2 ( seq -- first/f second/f )
    [ 0 swap ?nth ]
    [ 1 swap ?nth ] bi ;

: split-segments ( seq -- half-elements )
    [ [ break?>> ] bi@ = ] monotonic-split ;

: ?first-break ( seq -- newseq f/element )
    dup first first break?>>
    [ unclip-slice f swap make-element ]
    [ f ] if ;

: make-elements ( seq f/element -- elements )
    [ 2 <groups> [ ?first2 make-element ] map ] dip
    [ prefix ] when* ;

: segments>elements ( seq -- newseq )
    split-segments ?first-break make-elements ;

PRIVATE>

: wrap-segments ( segments line-max line-ideal -- lines )
    [ segments>elements ] 2dip wrap [ concat ] map ;

<PRIVATE

: split-lines ( string -- elements-lines )
    string-lines [
        " \t" split harvest
        [ dup length 1 <element> ] map
    ] map ;

: join-elements ( wrapped-lines -- lines )
    [ " " join ] map ;

: join-lines ( strings -- string )
    "\n" join ;

PRIVATE>

: wrap-lines ( lines width -- newlines )
    [ split-lines ] dip '[ _ dup wrap join-elements ] map concat ;

: wrap-string ( string width -- newstring )
    wrap-lines join-lines ;

: wrap-indented-string ( string width indent -- newstring )
    [ length - wrap-lines ] keep '[ _ prepend ] map join-lines ;
