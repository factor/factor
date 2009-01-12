! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math make strings arrays vectors sequences
sets math.order accessors ;
IN: splitting

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
        [ [ over ] dip head -rot length ] keep + tail
    ] [
        2drop f
    ] if ;

: split1-slice ( seq subseq -- before-slice after-slice )
    dup pick start dup [
        [ [ over ] dip head-slice -rot length ] keep + tail-slice
    ] [
        2drop f
    ] if ;

: split1-last ( seq subseq -- before after )
    [ <reversed> ] bi@ split1 [ reverse ] bi@
    dup [ swap ] when ;

: split1-last-slice ( seq subseq -- before-slice after-slice )
    [ <reversed> ] bi@ split1-slice [ <reversed> ] bi@
    [ f ] [ swap ] if-empty ;

: (split) ( separators n seq -- )
    3dup rot [ member? ] curry find-from drop
    [ [ swap subseq , ] 2keep 1+ swap (split) ]
    [ swap dup zero? [ drop ] [ tail ] if , drop ] if* ; inline recursive

: split, ( seq separators -- ) 0 rot (split) ;

: split ( seq separators -- pieces ) [ split, ] { } make ;

: string-lines ( str -- seq )
    dup "\r\n" intersects? [
        "\n" split [
            but-last-slice [
                "\r" ?tail drop "\r" split
            ] map
        ] keep peek "\r" split suffix concat
    ] [
        1array
    ] if ;
