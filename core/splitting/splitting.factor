! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math namespaces strings arrays vectors sequences
sets math.order accessors ;
IN: splitting

TUPLE: abstract-groups seq n ;

: check-groups dup 0 <= [ "Invalid group count" throw ] when ; inline

: construct-groups ( seq n class -- groups )
    >r check-groups r> boa ; inline

GENERIC: group@ ( n groups -- from to seq )

M: abstract-groups nth group@ subseq ;

M: abstract-groups set-nth group@ <slice> 0 swap copy ;

M: abstract-groups like drop { } like ;

INSTANCE: abstract-groups sequence

TUPLE: groups < abstract-groups ;

: <groups> ( seq n -- groups )
    groups construct-groups ; inline

M: groups length
    [ seq>> length ] [ n>> ] bi [ + 1- ] keep /i ;

M: groups set-length
    [ n>> * ] [ seq>> ] bi set-length ;

M: groups group@
    [ n>> [ * dup ] keep + ] [ seq>> ] bi [ length min ] keep ;

TUPLE: sliced-groups < groups ;

: <sliced-groups> ( seq n -- groups )
    sliced-groups construct-groups ; inline

M: sliced-groups nth group@ <slice> ;

TUPLE: clumps < abstract-groups ;

: <clumps> ( seq n -- groups )
    clumps construct-groups ; inline

M: clumps length
    [ seq>> length ] [ n>> ] bi - 1+ ;

M: clumps set-length
    [ n>> + 1- ] [ seq>> ] bi set-length ;

M: clumps group@
    [ n>> over + ] [ seq>> ] bi ;

TUPLE: sliced-clumps < groups ;

: <sliced-clumps> ( seq n -- groups )
    sliced-clumps construct-groups ; inline

M: sliced-clumps nth group@ <slice> ;

: group ( seq n -- array ) <groups> { } like ;

: clump ( seq n -- array ) <clumps> { } like ;

: ?head ( seq begin -- newseq ? )
    2dup head? [ length tail t ] [ drop f ] if ;

: ?head-slice ( seq begin -- newseq ? )
    2dup head? [ length tail-slice t ] [ drop f ] if ;

: ?tail ( seq end -- newseq ? )
    2dup tail? [ length head* t ] [ drop f ] if ;

: ?tail-slice ( seq end -- newseq ? )
    2dup tail? [ length head-slice* t ] [ drop f ] if ;

: split1 ( seq subseq -- before after )
    dup pick start dup [
        [ >r over r> head -rot length ] keep + tail
    ] [
        2drop f
    ] if ;

: last-split1 ( seq subseq -- before after )
    [ <reversed> ] bi@ split1 [ reverse ] bi@
    dup [ swap ] when ;

: (split) ( separators n seq -- )
    3dup rot [ member? ] curry find-from drop
    [ [ swap subseq , ] 2keep 1+ swap (split) ]
    [ swap dup zero? [ drop ] [ tail ] if , drop ] if* ; inline

: split, ( seq separators -- ) 0 rot (split) ;

: split ( seq separators -- pieces ) [ split, ] { } make ;

: string-lines ( str -- seq )
    dup "\r\n" intersect empty? [
        1array
    ] [
        "\n" split [
            1 head-slice* [
                "\r" ?tail drop "\r" split
            ] map
        ] keep peek "\r" split suffix concat
    ] if ;
