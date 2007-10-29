! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays math sequences.private vectors ;
IN: assocs

MIXIN: assoc

GENERIC: at* ( key assoc -- value/f ? )
GENERIC: set-at ( value key assoc -- )
GENERIC: new-assoc ( capacity exemplar -- newassoc )
GENERIC: delete-at ( key assoc -- )
GENERIC: clear-assoc ( assoc -- )
GENERIC: assoc-size ( assoc -- n )
GENERIC: assoc-like ( assoc exemplar -- newassoc )

M: assoc assoc-like drop ;

GENERIC: assoc-clone-like ( assoc exemplar -- newassoc )

GENERIC: >alist ( assoc -- newassoc )

GENERIC# assoc-find 1 ( assoc quot -- key value ? ) inline

M: assoc assoc-find
    >r >alist [ first2 ] r> compose find swap
    [ first2 t ] [ drop f f f ] if ;

: key? ( key assoc -- ? ) at* nip ; inline

: assoc-each ( assoc quot -- )
    [ f ] compose assoc-find 3drop ; inline

: (assoc>map) ( quot accum -- quot' )
    [ push ] curry compose ; inline

: assoc>map ( assoc quot exemplar -- seq )
    >r over assoc-size
    <vector> [ (assoc>map) assoc-each ] keep
    r> like ; inline

: assoc-map ( assoc quot -- newassoc )
    over >r [ 2array ] compose V{ } assoc>map r> assoc-like ;
    inline

: assoc-push-if ( key value quot accum -- )
    >r pick pick 2slip r> roll
    [ >r 2array r> push ] [ 3drop ] if ; inline

: assoc-pusher ( quot -- quot' accum )
    V{ } clone [ [ assoc-push-if ] 2curry ] keep ; inline

: assoc-subset ( assoc quot -- subassoc )
    over >r assoc-pusher >r assoc-each r> r> assoc-like ; inline

: assoc-all? ( assoc quot -- ? )
    [ not ] compose assoc-find 2nip not ; inline

: assoc-contains? ( assoc quot -- ? )
    assoc-find 2nip ; inline

: at ( key assoc -- value/f )
    at* drop ; inline

M: assoc assoc-clone-like ( assoc exemplar -- newassoc )
    over assoc-size swap new-assoc
    swap [ swap pick set-at ] assoc-each ;

: keys ( assoc -- keys )
    [ drop ] { } assoc>map ;

: values ( assoc -- values )
    [ nip ] { } assoc>map ;

: delete-at* ( key assoc -- old ? )
    [ at* ] 2keep delete-at ;

: rename-at ( newkey key assoc -- )
    tuck delete-at* [ -rot set-at ] [ 3drop ] if ;

: assoc-empty? ( assoc -- ? )
    assoc-size zero? ;

: (assoc-stack) ( key i seq -- value )
    over 0 < [
        3drop f
    ] [
        3dup nth-unsafe at*
        [ >r 3drop r> ] [ drop >r 1- r> (assoc-stack) ] if
    ] if ; inline

: assoc-stack ( key seq -- value )
    dup length 1- swap (assoc-stack) ;

: subassoc? ( assoc1 assoc2 -- ? )
    [ swapd at* [ = ] [ 2drop f ] if ] curry assoc-all? ;

: assoc= ( assoc1 assoc2 -- ? )
    2dup subassoc? >r swap subassoc? r> and ;

: assoc-hashcode ( n assoc -- code )
    [
        >r over r> hashcode* 2/ >r dupd hashcode* r> bitxor
    ] { } assoc>map hashcode* ;

: intersect ( assoc1 assoc2 -- intersection )
    swap [ nip key? ] curry assoc-subset ;

: update ( assoc1 assoc2 -- )
    swap [ swapd set-at ] curry assoc-each ;

: union ( assoc1 assoc2 -- union )
    2dup [ assoc-size ] 2apply + pick new-assoc
    [ rot update ] keep [ swap update ] keep ;

: diff ( assoc1 assoc2 -- diff )
    swap [ nip key? not ] curry assoc-subset ;

: remove-all ( assoc seq -- subseq )
    swap [ key? not ] curry subset ;

: substitute ( assoc seq -- )
    swap [ dupd at* [ nip ] [ drop ] if ] curry change-each ;

: cache ( key assoc quot -- value )
    pick pick at [
        >r 3drop r>
    ] [
        pick rot >r >r call dup r> r> set-at
    ] if* ; inline

: change-at ( key assoc quot -- )
    [ >r at r> call ] 3keep drop set-at ; inline

: at+ ( n key assoc -- )
    [ 0 or + ] change-at ;

: map>assoc ( seq quot exemplar -- assoc )
    >r [ 2array ] compose map r> assoc-like ; inline

M: assoc >alist [ 2array ] { } assoc>map ;

: value-at ( value assoc -- key/f )
    swap [ = nip ] curry assoc-find 2drop ;

: search-alist ( key alist -- pair i )
    [ first = ] curry* find swap ; inline

M: sequence at*
    search-alist [ second t ] [ f ] if ;

M: sequence set-at
    2dup search-alist
    [ 2nip set-second ]
    [ drop >r swap 2array r> push ] if ;

M: sequence new-assoc drop <vector> ;

M: sequence clear-assoc delete-all ;

M: sequence delete-at
    tuck search-alist nip
    [ swap delete-nth ] [ drop ] if* ;

M: sequence assoc-size length ;

M: sequence assoc-clone-like
    >r >alist r> clone-like ;

M: sequence assoc-like
    over sequence? [ like ] [ assoc-clone-like ] if ;

M: sequence >alist ;

! Override sequence => assoc instance for f
M: f clear-assoc drop ;

M: f assoc-like drop dup assoc-empty? [ drop f ] when ;

INSTANCE: sequence assoc
