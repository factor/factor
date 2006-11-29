! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: kernel sequences hashtables kernel-internals words
namespaces generic vectors namespaces ;

! Name stack and variable binding simulation
SYMBOL: meta-n

: push-n meta-n get push ;
: pop-n meta-n get pop ;
: peek-n meta-n get peek ;

TUPLE: inferred-vars reads writes reads-globals writes-globals ;

: vars-trivial? ( vars -- ? ) tuple-slots [ empty? ] all? ;

: empty-vars ( -- vars )
    V{ } clone V{ } clone V{ } clone V{ } clone
    <inferred-vars> ;

: apply-var-seq ( seq -- )
    inferred-vars [
        >r [ tuple-slots ] map r> tuple-slots add flip
        [ concat prune >vector ] map first4 <inferred-vars>
    ] change ;
    
: apply-var-read ( symbol -- )
    dup meta-n get [ hash-member? ] contains-with? [
        drop
    ] [
        inferred-vars get 2dup inferred-vars-writes member? [
            2drop
        ] [
            inferred-vars-reads push-new
        ] if
    ] if ;
    
: apply-var-write ( symbol -- )
    meta-n get empty? [
        inferred-vars get inferred-vars-writes push-new
    ] [
        dup peek-n set-hash
    ] if ;

: apply-global-read ( symbol -- )
    inferred-vars get
    2dup inferred-vars-writes-globals member? [
        2drop
    ] [
        inferred-vars-reads-globals push-new
    ] if ;

: apply-global-write ( symbol -- )
    inferred-vars get inferred-vars-writes-globals push-new ;

: apply-vars ( vars -- )
    [
        dup inferred-vars-reads [ apply-var-read ] each
        dup inferred-vars-writes [ apply-var-write ] each
        dup inferred-vars-reads-globals [ apply-global-read ] each
        inferred-vars-writes-globals [ apply-global-write ] each
    ] when* ;
