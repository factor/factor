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

: subseq-range ( seq subseq -- from/f to/f )
    [ subseq-index ] keep '[ dup _ length + ] [ f f ] if* ; inline

: (split1) ( seq subseq snip-quot -- before after )
    [ [ subseq-range ] keepd over ] dip [ 2nip f ] if ; inline

PRIVATE>

: split1 ( seq subseq -- before after )
    [ snip ] (split1) ;

: split1-slice ( seq subseq -- before-slice after-slice )
    [ snip-slice ] (split1) ;

: split-subseq ( seq subseq -- seqs )
    [
        1array
    ] [
        [ dup ] swap '[ _ split1-slice swap ] produce nip
    ] if-empty ;

: replace ( seq old new -- new-seq )
    pick [ [ split-subseq ] dip ] dip join-as ;

<PRIVATE

: (split1-when) ( ... seq quot: ( ... elt -- ... ? ) snip-quot -- ... before-slice after-slice )
    [ dupd find drop ] dip '[ dup 1 + rot @ ] [ f ] if* ; inline

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

:: (split-when) ( seq quot: ( ... elt -- ... ? ) slice-quot -- pieces )
    0
    [ [ seq quot find-from drop dup ] keep -rot ]
    [ [ seq slice-quot call ] keep 1 + swap ]
    V{ } produce-as nip swap
    seq length seq slice-quot call suffix! { } like ; inline

PRIVATE>

: split-when ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ subseq-unsafe ] (split-when) ; inline

: split-when-slice ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ <slice-unsafe> ] (split-when) ; inline

: split ( seq separators -- pieces )
    '[ _ member? ] split-when ; inline

: split-slice ( seq separators -- pieces )
    '[ _ member? ] split-when-slice ; inline

: split-indices ( seq indices -- pieces )
    over length suffix 0 swap [
        [ pick subseq ] keep swap
    ] map 2nip ;

! split-lines uses string-nth-fast which is 50% faster over
! nth-unsafe. be careful when changing the definition so that
! you don't unoptimize it.
GENERIC: split-lines ( seq -- seq' )

ALIAS: string-lines split-lines

M: string split-lines
    [ V{ } clone 0 ] dip [ 2dup bounds-check? ] [
        2dup [ "\r\n" member? ] find-from swapd [
            over [ [ nip length ] keep ] unless
            [ "" subseq-as suffix! ] 2keep [ 1 + ] dip
        ] dip CHAR: \r eq? [
            2dup ?nth CHAR: \n eq? [ [ 1 + ] dip ] when
        ] when
    ] while 2drop { } like ;

M: sbuf split-lines "" like split-lines ;

: join-lines-as ( seq exemplar -- seq ) "\n" swap join-as ; inline
: join-lines ( seq -- seq ) "" join-lines-as ; inline
: split-words ( seq -- seq ) " " split ; inline
: join-words-as ( seq exemplar -- seq ) " " swap join-as ; inline
: join-words ( seq -- seq ) " " join-words-as ; inline
