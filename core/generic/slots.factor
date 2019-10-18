! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

IN: generic
USING: arrays kernel kernel-internals math namespaces
parser sequences strings words ;

: define-typecheck ( class generic quot -- )
    over define-generic -rot define-method ;

: define-slot-word ( class slot word quot -- )
    rot >fixnum add* define-typecheck ;

: reader-effect ( -- effect ) 1 1 <effect> ; inline

: define-reader ( class slot decl reader -- )
    dup [
        dup reader-effect "declared-effect" set-word-prop
        [ slot ] rot dup object eq?
        [ drop ] [ 1array [ declare ] swap add* append ] if
        define-slot-word
    ] [
        2drop 2drop
    ] if ;

: writer-effect ( -- effect ) 2 0 <effect> ; inline

: define-writer ( class slot writer -- )
    dup [
        dup writer-effect "declared-effect" set-word-prop
        [ set-slot ] define-slot-word
    ] [
        3drop
    ] if ;

: define-slot ( class slot decl reader writer -- )
    >r >r >r 2dup r> r> define-reader r> define-writer ;

: intern-slots ( spec -- spec )
    [ [ dup array? [ first2 create ] when ] map ] map ;

: define-slots ( class spec -- )
    [ first4 define-slot ] each-with ;

: reader-word ( class name -- word )
    >r word-name "-" r> 3append in get 2array ;

: writer-word ( class name -- word )
    [ swap "set-" % word-name % "-" % % ] "" make in get 2array ;

: simple-slot ( class name -- )
    2dup reader-word , writer-word , ;

: simple-slots ( class slots base -- spec )
    over length [ + ] map-with
    [ [ , object , dupd simple-slot ] { } make ] 2map nip intern-slots ;
