! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math sbufs sequences sequences.private
strings ;
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

: (split1) ( seq subseq snip-quot -- before after )
    [
        swap [
            [ drop length ] [ subseq-start dup ] 2bi
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

: split-subseq ( seq subseq -- seqs )
    [
        1array
    ] [
        [ dup ] swap [ split1-slice swap ] curry produce nip
    ] if-empty ;

: replace ( seq old new -- new-seq )
    pick [ [ split-subseq ] dip ] dip join-as ;

<PRIVATE

: (split1-when) ( ... seq quot: ( ... elt -- ... ? ) snip-quot -- ... before-slice after-slice )
    [ dupd find drop ] dip [ swap [ dup 1 + ] dip ] prepose [ f ] if* ; inline

PRIVATE>

: split1-when ( ... seq quot: ( ... elt -- ... ? ) -- ... before after )
    [ snip ] (split1-when) ; inline

: split1-when-slice ( ... seq quot: ( ... elt -- ... ? ) -- ... before-slice after-slice )
    [ snip-slice ] (split1-when) ; inline

: split1-last ( seq subseq -- before after )
    [ <reversed> ] bi@ split1 [ reverse ] bi@
    dup [ swap ] when ;

: split1-last-slice ( seq subseq -- before-slice after-slice )
    [ <reversed> ] bi@ split1-slice [ <reversed> ] bi@
    [ f ] [ swap ] if-empty ;

<PRIVATE

: (split) ( seq quot: ( ... elt -- ... ? ) slice-quot -- pieces )
    [ 0 ] 3dip pick [
        swap curry [ keep 1 + swap ] curry [
            [ find-from drop dup ] 2curry [ keep -rot ] curry
        ] dip produce nip
    ] 2keep swap [
        [ length swapd ] keep
    ] dip 2curry call suffix ; inline

PRIVATE>

: split-when ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ subseq-unsafe ] (split) ; inline

: split-when-slice ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ <slice-unsafe> ] (split) ; inline

: split ( seq separators -- pieces )
    [ member? ] curry split-when ; inline

: split-slice ( seq separators -- pieces )
    [ member? ] curry split-when-slice ; inline

: split-indices ( seq indices -- pieces )
    over length suffix 0 swap [
        [ pick subseq ] keep swap
    ] map 2nip ;

! string-lines uses string-nth-fast which is 50% faster over
! nth-unsafe. be careful when changing the definition so that
! you don't unoptimize it.
GENERIC: string-lines ( seq -- seq' )

M: string string-lines
    [ V{ } clone 0 ] dip [ 2dup bounds-check? ] [
        2dup [ "\r\n" member? ] find-from swapd [
            over [ [ nip length ] keep ] unless
            [ "" subseq-as suffix! ] 2keep [ 1 + ] dip
        ] dip CHAR: \r eq? [
            2dup ?nth CHAR: \n eq? [ [ 1 + ] dip ] when
        ] when
    ] while 2drop { } like ;

M: sbuf string-lines "" like string-lines ;
