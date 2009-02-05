! Copyright (C) 2008, 2009 Daniel Ehrenberg, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
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

: walk ( n words -- n )
    ! If on a break, take the rest of the breaks
    ! If not on a break, go back until you hit a break
    2dup bounds-check? [
        2dup nth break?>>
        [ [ break?>> not ] find-from drop ]
        [ [ break?>> ] find-last-from drop 1+ ] if
   ] [ drop ] if ;

: find-optimal-break ( words -- n )
    [ 0 ] keep
    [ [ width>> + dup ] keep break-here? ] find drop nip
    [ 1 max swap walk ] [ drop f ] if* ;

: (wrap) ( words -- )
    [
        dup find-optimal-break
        [ cut-slice [ , ] [ (wrap) ] bi* ] [ , ] if*
    ] unless-empty ;

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
        [ break?>> ] trim-slice
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
