! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math sequences strings sbufs ;
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

: split-subseq ( seq subseq -- seqs )
    dup empty? [
        drop 1array
    ] [
        [ dup ] swap [ split1-slice swap ] curry produce nip
    ] if ;

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

: (split) ( n seq quot: ( ... elt -- ... ? ) slice-quot -- pieces )
    pick [
        swap curry [ keep 1 + swap ] curry [
            [ find-from drop dup ] 2curry [ keep -rot ] curry
        ] dip produce nip
    ] 2keep swap [
        [ length swapd ] keep
    ] dip 2curry call suffix ; inline

PRIVATE>

: split-when ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ 0 ] 2dip [ subseq ] (split) ; inline

: split-when-slice ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ 0 ] 2dip [ <slice> ] (split) ; inline

: split ( seq separators -- pieces )
    [ member? ] curry split-when ; inline

: split-slice ( seq separators -- pieces )
    [ member? ] curry split-when-slice ; inline

<PRIVATE

: (split*) ( n seq quot: ( ... elt -- ... ? ) slice-quot -- pieces )
    pick [
        swap curry [ keep swap ] curry [
            [ [ find-from drop dup ] 2curry [ keep -rot ] curry ] 2keep
            [ not ] compose [ find-from drop dup ] 2curry
            [ dip -rot ] curry [ swap ] prepose
            [ [ dup ] if ] curry [ 2dup = ] prepose
            [ [ f ] if ] curry compose
        ] dip produce nip
    ] 2keep swap [
        [ length [ swapd dupd < ] keep ] keep
    ] dip 2curry [ suffix ] compose [ drop ] if ; inline

PRIVATE>

: split*-when ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ 0 ] 2dip [ subseq ] (split*) ; inline

: split*-when-slice ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ 0 ] 2dip [ <slice> ] (split*) ; inline

: split* ( seq separators -- pieces )
    [ member? ] curry split*-when ; inline

: split*-slice ( seq separators -- pieces )
    [ member? ] curry split*-when-slice ; inline

GENERIC: string-lines ( str -- seq )

M: string string-lines
    dup [ "\r\n" member? ] any? [
        "\n" split
        [
            but-last-slice [
                dup ?last CHAR: \r = [ but-last ] when
                [ CHAR: \r = ] split-when
            ] map! drop
        ] [
            [ length 1 - ] keep
            [ [ CHAR: \r = ] split-when ] change-nth
        ]
        [ concat ]
        tri
    ] [
        1array
    ] if ;

M: sbuf string-lines "" like string-lines ;
