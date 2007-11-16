! Copyright (C) 2007 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel math ;
IN: dlists

TUPLE: dlist front back length ;

: <dlist> ( -- obj )
    dlist construct-empty
    0 over set-dlist-length ;

: dlist-empty? ( dlist -- ? ) dlist-front not ;

<PRIVATE
TUPLE: dlist-node obj prev next ;
C: <dlist-node> dlist-node

: inc-length ( dlist -- )
    [ dlist-length 1+ ] keep set-dlist-length ; inline

: dec-length ( dlist -- )
    [ dlist-length 1- ] keep set-dlist-length ; inline

: set-prev-when ( dlist-node dlist-node/f -- )
    [ set-dlist-node-prev ] [ drop ] if* ;

: set-next-when ( dlist-node dlist-node/f -- )
    [ set-dlist-node-next ] [ drop ] if* ;

: set-next-prev ( dlist-node -- )
    dup dlist-node-next set-prev-when ;

: normalize-front ( dlist -- )
    dup dlist-back [ drop ] [ f swap set-dlist-front ] if ;

: normalize-back ( dlist -- )
    dup dlist-front [ drop ] [ f swap set-dlist-back ] if ;

: set-back-to-front ( dlist -- )
    dup dlist-back
    [ drop ] [ dup dlist-front swap set-dlist-back ] if ;

: set-front-to-back ( dlist -- )
    dup dlist-front
    [ drop ] [ dup dlist-back swap set-dlist-front ] if ;

: (dlist-find-node) ( quot dlist-node -- node/f ? )
    dup dlist-node-obj pick dupd call [
        drop nip t
    ] [
        drop dlist-node-next [ (dlist-find-node) ] [ drop f f ] if*
    ] if ; inline

: dlist-find-node ( quot dlist -- node/f ? )
    dlist-front [ (dlist-find-node) ] [ drop f f ] if* ; inline

: (dlist-each-node) ( quot dlist -- )
    over
    [ 2dup call >r dlist-node-next r> (dlist-each-node) ]
    [ 2drop ] if ; inline

: dlist-each-node ( quot dlist -- )
    >r dlist-front r> (dlist-each-node) ; inline
PRIVATE>

: push-front ( obj dlist -- )
    [ dlist-front f swap <dlist-node> dup set-next-prev ] keep
    [ set-dlist-front ] keep
    [ set-back-to-front ] keep
    inc-length ;

: push-back ( obj dlist -- )
    [ dlist-back f <dlist-node> ] keep
    [ dlist-back set-next-when ] 2keep
    [ set-dlist-back ] keep
    [ set-front-to-back ] keep
    inc-length ;

: pop-front ( dlist -- obj )
    dup dlist-front [
        dlist-node-next
        f over set-prev-when
        swap set-dlist-front
    ] 2keep dlist-node-obj
    swap [ normalize-back ] keep dec-length ;

: pop-front* ( dlist -- ) pop-front drop ;

: pop-back ( dlist -- obj )
    [
        dlist-back dup dlist-node-prev f over set-next-when
    ] keep
    [ set-dlist-back ] keep
    [ normalize-front ] keep
    dec-length
    dlist-node-obj ;

: pop-back* ( dlist -- ) pop-back drop ;

: dlist-find ( quot dlist -- obj/f ? )
    dlist-find-node dup [ >r dlist-node-obj r> ] when ; inline

: dlist-contains? ( quot dlist -- ? )
    dlist-find nip ; inline

: (delete-node) ( dlist dlist-node -- )
    {
        { [ 2dup >r dlist-front r> = ] [ drop pop-front* ] }
        { [ 2dup >r dlist-back r> = ] [ drop pop-back* ] }
        { [ t ] [ dup dlist-node-prev swap dlist-node-next set-prev-when
                  dec-length ] }
    } cond ;

: delete-node* ( quot dlist -- obj/f ? )
    tuck dlist-find-node [
        [ (delete-node) ] keep [ dlist-node-obj t ] [ f f ] if*
    ] [
        2drop f f
    ] if ; inline

: delete-node ( quot dlist -- obj/f )
    delete-node* drop ; inline

: dlist-delete ( obj dlist -- obj/f )
    >r [ eq? ] curry r> delete-node ;

: dlist-each ( dlist quot -- )
    [ dlist-node-obj ] swap compose dlist-each-node ; inline

: dlist-slurp ( dlist quot -- )
    over dlist-empty?
    [ 2drop ] [ [ >r pop-back r> call ] 2keep dlist-slurp ] if ;
    inline
