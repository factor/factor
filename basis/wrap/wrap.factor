USING: kernel sequences math arrays locals fry accessors splitting
make combinators.short-circuit namespaces grouping splitting.monotonic ;
IN: wrap

<PRIVATE

! black is the text length, white is the whitespace length
TUPLE: word contents black white ;
C: <word> word

: word-length ( word -- n )
    [ black>> ] [ white>> ] bi + ;

TUPLE: cons cdr car ; ! This order works out better
C: <cons> cons

: >cons< ( cons -- cdr car )
    [ cdr>> ] [ car>> ] bi ;

: list-each ( list quot -- )
    over [
        [ [ car>> ] dip call ]
        [ [ cdr>> ] dip list-each ] 2bi
    ] [ 2drop ] if ; inline recursive

: singleton? ( list -- ? )
    { [ ] [ cdr>> not ] } 1&& ;

: <singleton> ( elt -- list )
    f swap <cons> ;

: list>array ( list -- array )
    [ [ , ] list-each ] { } make ;

: lists>arrays ( lists -- arrays )
    [ [ list>array , ] list-each ] { } make ;

TUPLE: paragraph lines head-width tail-cost ;
C: <paragraph> paragraph

SYMBOL: line-max
SYMBOL: line-ideal

: deviation ( length -- n )
    line-ideal get - sq ;

: top-fits? ( paragraph -- ? )
    [ head-width>> ]
    [ lines>> singleton? line-ideal line-max ? get ] bi <= ;

: fits? ( paragraph -- ? )
    ! Make this not count spaces at end
    { [ lines>> car>> singleton? ] [ top-fits? ] } 1|| ;

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

: new-line ( paragraph word -- paragraph )
    [ [ lines>> ] [ <singleton> ] bi* <cons> ]
    [ nip black>> ]
    [ drop paragraph-cost ] 2tri
    <paragraph> ;

: glue ( paragraph word -- paragraph )
    [ [ lines>> >cons< ] dip <cons> <cons> ]
    [ [ head-width>> ] [ word-length ] bi* + ]
    [ drop tail-cost>> ] 2tri
    <paragraph> ;

: wrap-step ( paragraphs word -- paragraphs )
    [ '[ _ glue ] map ]
    [ [ min-cost ] dip new-line ]
    2bi prefix
    [ fits? ] filter ;

: 1paragraph ( word -- paragraph )
    [ <singleton> <singleton> ]
    [ black>> ] bi
    0 <paragraph> ;

: post-process ( paragraph -- array )
    lines>> lists>arrays
    [ [ contents>> ] map ] map ;

: initialize ( words -- words paragraph )
    <reversed> unclip-slice 1paragraph 1array ;

: wrap ( words line-max line-ideal -- paragraph )
    [
        line-ideal set
        line-max set
        initialize
        [ wrap-step ] reduce
        min-cost
        post-process
    ] with-scope ;

PRIVATE>

TUPLE: element key width break? ;
C: <element> element

<PRIVATE

: elements-length ( elements -- length )
    [ width>> ] map sum ;

: make-word ( whites blacks -- word )
    [ append ] [ [ elements-length ] bi@ ] 2bi <word> ;
 
: ?first2 ( seq -- first/f second/f )
    [ 0 swap ?nth ]
    [ 1 swap ?nth ] bi ;

: split-elements ( seq -- half-words )
    [ [ break?>> ] bi@ = ] monotonic-split ;

: ?first-break ( seq -- newseq f/word )
    dup first first break?>>
    [ unclip-slice f swap make-word ]
    [ f ] if ;

: make-words ( seq f/word -- words )
    [ 2 <groups> [ ?first2 make-word ] map ] dip
    [ prefix ] when* ;

: elements>words ( seq -- newseq )
    split-elements ?first-break make-words ;

PRIVATE>

: wrap-elements ( elements line-max line-ideal -- lines )
    [ elements>words ] 2dip wrap [ concat ] map ;

<PRIVATE

: split-lines ( string -- words-lines )
    string-lines [
        " \t" split harvest
        [ dup length 1 <word> ] map
    ] map ;

: join-words ( wrapped-lines -- lines )
    [ " " join ] map ;

: join-lines ( strings -- string )
    "\n" join ;

PRIVATE>

: wrap-lines ( lines width -- newlines )
    [ split-lines ] dip '[ _ dup wrap join-words ] map concat ;

: wrap-string ( string width -- newstring )
    wrap-lines join-lines ;

: wrap-indented-string ( string width indent -- newstring )
    [ length - wrap-lines ] keep '[ _ prepend ] map join-lines ;
