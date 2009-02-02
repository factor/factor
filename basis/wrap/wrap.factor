USING: sequences kernel namespaces make splitting
math math.order fry assocs accessors ;
IN: wrap

! Word wrapping/line breaking -- not Unicode-aware

TUPLE: word key width break? ;

C: <word> word

<PRIVATE

SYMBOL: width

: break-here? ( column word -- ? )
    break?>> not [ width get > ] [ drop f ] if ;

: find-optimal-break ( words -- n )
    [ 0 ] dip [ [ width>> + dup ] keep break-here? ] find drop nip ;

: (wrap) ( words -- )
    dup find-optimal-break
    [ 1 max cut-slice [ , ] [ (wrap) ] bi* ] [ , ] if* ;

: intersperse ( seq elt -- seq' )
    [ '[ _ , ] [ , ] interleave ] { } make ;

: split-lines ( string -- words-lines )
    string-lines [
        " \t" split harvest
        [ dup length f <word> ] map
        " " 1 t <word> intersperse
    ] map ;

: join-words ( wrapped-lines -- lines )
    [
        [ break?>> ]
        [ trim-head-slice ]
        [ trim-tail-slice ] bi
        [ key>> ] map concat
    ] map ;

: join-lines ( strings -- string )
    "\n" join ;

PRIVATE>

: wrap ( words width -- lines )
    width [
        [ (wrap) ] { } make
    ] with-variable ;

: wrap-lines ( lines width -- newlines )
    [ split-lines ] dip '[ _ wrap join-words ] map concat ;

: wrap-string ( string width -- newstring )
    wrap-lines join-lines ;

: wrap-indented-string ( string width indent -- newstring )
    [ length - wrap-lines ] keep '[ _ prepend ] map join-lines ;
