! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel kernel.private math math.order
sbufs sequences sequences.private strings strings.private ;
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

: subseq-range ( seq subseq -- from/f to/f )
    tuck subseq-index [ dup rot length + ] [ drop f f ] if* ;

: ?snip ( from/f to/f seq -- before after )
    over [ snip ] [ 2nip f ] if ; inline

: ?snip-slice ( from/f to/f seq -- before after )
    over [ snip-slice ] [ 2nip f ] if ; inline

: split1 ( seq subseq -- before after )
    [ subseq-range ] keepd ?snip ; inline

: split1-slice ( seq subseq -- before-slice after-slice )
    [ subseq-range ] keepd ?snip-slice ; inline

: split-subseq ( seq subseq -- seqs )
    [
        1array
    ] [
        [ dup ] swap [ split1-slice swap ] curry produce nip
    ] if-empty ;

: replace ( seq old new -- new-seq )
    pick [ [ split-subseq ] dip ] dip join-as ;

: split1-when ( ... seq quot: ( ... elt -- ... ? ) -- ... before after )
    [ find drop ] keepd swap [ dup 1 + rot snip ] [ f ] if* ; inline

: split1-when-slice ( ... seq quot: ( ... elt -- ... ? ) -- ... before-slice after-slice )
    [ find drop ] keepd swap [ dup 1 + rot snip-slice ] [ f ] if* ; inline

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
        ] dip V{ } produce-as nip
    ] 2keep swap [
        [ length swapd ] keep
    ] dip 2curry call suffix! { } like ; inline

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

<PRIVATE

: linebreak? ( ch -- ? )
    { fixnum } declare
    dup CHAR: \n CHAR: \r between? [ drop t ] [         ! LINE FEED, CARRIAGE RETURN, LINE TABULATION, FORM FEED
        dup CHAR: \x1c CHAR: \x1e between? [ drop t ] [ ! FILE, GROUP, RECORD SEPARATOR
            dup CHAR: \x85 = [ drop t ] [               ! NEXT LINE (C1 CONTROL CODE)
                CHAR: \u002028 CHAR: \u002029 between?  ! LINE, PARAGRAPH SEPARATOR
            ] if
        ] if
    ] if ; inline

PRIVATE>

GENERIC: split-lines ( seq -- seq' )

ALIAS: string-lines split-lines

M:: string split-lines ( seq -- seq' )
    seq length :> len
    V{ } clone 0 [ dup len < ] [
        dup seq [ linebreak? ] find-from [
            len or [ seq subseq suffix! ] [ 1 + ] bi
        ] [
            CHAR: \r eq? [
               dup seq ?nth CHAR: \n eq? [ 1 + ] when
            ] when
        ] bi*
    ] while drop { } like ; inline

M: sbuf split-lines "" like split-lines ;

: join-lines-as ( seq exemplar -- seq ) "\n" swap join-as ; inline
: join-lines ( seq -- seq ) "" join-lines-as ; inline
: split-words ( seq -- seq ) " " split ; inline
: join-words-as ( seq exemplar -- seq ) " " swap join-as ; inline
: join-words ( seq -- seq ) " " join-words-as ; inline
