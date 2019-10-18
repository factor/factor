! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables kernel kernel.private math
namespaces sequences vectors words strings layouts combinators
combinators.private classes optimizer.backend optimizer.def-use
optimizer.known-words optimizer.math inference.class
generic.standard ;
IN: optimizer

: optimize-1 ( node -- newnode ? )
    [
        H{ } clone class-substitutions set
        H{ } clone literal-substitutions set
        H{ } clone value-substitutions set
        dup compute-def-use
        dup kill-values
        dup infer-classes
        optimizer-changed off
        optimize-nodes
        optimizer-changed get
    ] with-scope ;

: optimize ( node -- newnode )
    optimize-1 [ optimize ] when ;

: simple-specializer ( quot dispatch# classes -- quot )
    swap (dispatch#) [
        object add* swap [ 2array ] curry map
        object method-alist>quot
    ] with-variable ;

: dispatch-specializer ( quot dispatch# symbol dispatcher -- quot )
    rot (dispatch#) [
        [
            picker %
            ,
            get swap <array> ,
            \ dispatch ,
        ] [ ] make
    ] with-variable ;

: tag-specializer ( quot dispatch# -- quot )
    num-tags \ tag dispatch-specializer ;

: type-specializer ( quot dispatch# -- quot )
    num-types \ type dispatch-specializer ;

: make-specializer ( quot dispatch# spec -- quot )
    {
        { [ dup number eq? ] [ drop tag-specializer ] }
        { [ dup object eq? ] [ drop type-specializer ] }
        { [ dup \ * eq? ] [ 2drop ] }
        { [ dup array? ] [ simple-specializer ] }
        { [ t ] [ 1array simple-specializer ] }
    } cond ;

: specialized-def ( word -- quot )
    dup word-def swap "specializer" word-prop [
        [ length ] keep <reversed> [ make-specializer ] 2each
    ] when* ;
