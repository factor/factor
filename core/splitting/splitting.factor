! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math make strings arrays vectors sequences
sets math.order accessors ;
IN: splitting

<PRIVATE

: ?chomp ( seq begin tester chopper -- newseq ? )
    [ [ 2dup ] dip call ] dip
    [ [ length ] dip call t ] curry
    [ drop f ] if ; inline

PRIVATE>

: ?head ( seq begin -- newseq ? )
    [ head? ] [ tail ] ?chomp ;

: ?head-slice ( seq begin -- newseq ? )
    [ head? ] [ tail-slice ] ?chomp ;

: ?tail ( seq end -- newseq ? )
    [ tail? ] [ head* ] ?chomp ;

: ?tail-slice ( seq end -- newseq ? )
    [ tail? ] [ head-slice* ] ?chomp ;

<PRIVATE

: (split1) ( seq subseq quot -- before after )
    [
        swap [
            [ drop length ] [ start dup ] 2bi
            [ [ nip ] [ + ] 2bi t ]
            [ 2drop f f f ]
            if
        ] keep swap
    ] dip [ 2nip f ] if ; inline

PRIVATE>

: split1 ( seq subseq -- before after )
    [ snip ] (split1) ;

: split1-slice ( seq subseq -- before-slice after-slice )
    [ snip-slice ] (split1) ;

: split1-last ( seq subseq -- before after )
    [ <reversed> ] bi@ split1 [ reverse ] bi@
    dup [ swap ] when ;

: split1-last-slice ( seq subseq -- before-slice after-slice )
    [ <reversed> ] bi@ split1-slice [ <reversed> ] bi@
    [ f ] [ swap ] if-empty ;

: (split) ( separators n seq -- )
    3dup rot [ member? ] curry find-from drop
    [ [ swap subseq , ] 2keep 1 + swap (split) ]
    [ swap dup zero? [ drop ] [ tail ] if , drop ] if* ; inline recursive

: split, ( seq separators -- ) 0 rot (split) ;

: split ( seq separators -- pieces )
    [ split, ] { } make ;

GENERIC: string-lines ( str -- seq )

M: string string-lines
    dup "\r\n" intersects? [
        "\n" split [
            but-last-slice [
                "\r" ?tail drop "\r" split
            ] map
        ] keep peek "\r" split suffix concat
    ] [
        1array
    ] if ;
