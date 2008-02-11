! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables kernel kernel.private math
namespaces sequences vectors words strings layouts combinators
sequences.private classes generic.standard assocs ;
IN: optimizer.specializers

: (make-specializer) ( class picker -- quot )
    swap "predicate" word-prop append ;

: make-specializer ( classes -- quot )
    dup length <reversed>
    [ (picker) 2array ] 2map
    [ drop object eq? not ] assoc-subset
    dup empty? [ drop [ t ] ] [
        [ (make-specializer) ] { } assoc>map
        unclip [ swap [ f ] \ if 3array append [ ] like ] reduce
    ] if ;

: tag-specializer ( quot -- newquot )
    [
        [ dup tag ] %
        num-tags get swap <array> ,
        \ dispatch ,
    ] [ ] make ;

: specialized-def ( word -- quot )
    dup word-def swap "specializer" word-prop [
        dup { number } = [
            drop tag-specializer
        ] [
            dup [ array? ] all? [ 1array ] unless [
                [ make-specializer ] keep
                [ declare ] curry pick append
            ] { } map>assoc
            alist>quot
        ] if
    ] when* ;

: specialized-length ( specializer -- n )
    dup [ array? ] all? [ first ] when length ;
