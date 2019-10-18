! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math namespaces strings arrays vectors sequences ;
IN: splitting

TUPLE: groups seq n sliced? ;

: check-groups 0 <= [ "Invalid group count" throw ] when ;

: <groups> ( seq n -- groups )
    dup check-groups f groups construct-boa ; inline

: <sliced-groups> ( seq n -- groups )
    <groups> t over set-groups-sliced? ;

M: groups length
    dup groups-seq length swap groups-n [ + 1- ] keep /i ;

M: groups set-length
    [ groups-n * ] keep delegate set-length ;

: group@ ( n groups -- from to seq )
    [ groups-n [ * dup ] keep + ] keep
    groups-seq [ length min ] keep ;

M: groups nth
    [ group@ ] keep
    groups-sliced? [ <slice> ] [ subseq ] if ;

M: groups set-nth
    group@ <slice> 0 swap copy ;

M: groups like drop { } like ;

INSTANCE: groups sequence

: group ( seq n -- array ) <groups> { } like ;

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
    [ <reversed> ] 2apply split1 [ reverse ] 2apply
    dup [ swap ] when ;

: (split) ( separators n seq -- )
    3dup rot [ member? ] curry find* drop
    [ [ swap subseq , ] 2keep 1+ swap (split) ]
    [ swap dup zero? [ drop ] [ tail ] if , drop ] if* ; inline

: split, ( seq separators -- ) 0 rot (split) ;

: split ( seq separators -- pieces ) [ split, ] { } make ;

: string-lines ( str -- seq )
    dup [ "\r\n" member? ] contains? [
        "\n" split [
            1 head-slice* [
                "\r" ?tail drop "\r" split
            ] map
        ] keep peek "\r" split add concat
    ] [
        1array
    ] if ;
