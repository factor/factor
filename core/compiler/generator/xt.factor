! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler

DEFER: (compile)

IN: generator
USING: alien arrays errors generic hashtables kernel
kernel-internals math namespaces prettyprint queues
sequences strings vectors words ;

: compiled-offset ( -- n ) building get length code-format * ;

TUPLE: label offset ;

C: label ( -- label ) ;

: define-label ( name -- ) <label> swap set ;

: resolve-label ( label/name -- )
    dup string? [ get ] when
    compiled-offset swap set-label-offset ;

SYMBOL: compiled-xts

: save-xt ( word xt -- )
    swap dup unchanged-word compiled-xts get set-hash ;

: push-new* ( obj table -- n )
    2dup [ eq? ] find-with drop dup -1 > [
        2nip
    ] [
        drop dup length >r push r>
    ] if ;

SYMBOL: literal-table

: add-literal ( obj -- n ) literal-table get push-new* ;

SYMBOL: word-table

: add-word ( word -- n ) word-table get push-new* ;

SYMBOL: relocation-table
SYMBOL: label-table

! Relocation classes
C-ENUM:
    rc-absolute-cell
    rc-absolute
    rc-relative
    rc-absolute-ppc-2/2
    rc-relative-ppc-2
    rc-relative-ppc-3
    rc-relative-arm-3
    rc-indirect-arm
    rc-indirect-arm-pc ;

! Relocation types
C-ENUM:
    rt-primitive
    rt-dlsym
    rt-literal
    rt-dispatch
    rt-xt
    rt-label ;

: (rel) ( arg class type offset -- pair )
    #! Write a relocation instruction for the runtime image
    #! loader.
    pick rc-absolute-cell = cell 4 ? -
    >r { 0 8 16 } bitfield r>
    2array ;

: rel, ( arg class type -- )
    compiled-offset (rel) relocation-table get nappend ;

: string>symbol ( str -- alien )
    #! On Windows CE the symbol name has to be unicode.
    os "wince" = [ string>u16-alien ] [ string>char-alien ] if ;

: rel-dlsym ( name dll class -- )
   >r >r string>symbol r> 2array add-literal r>
   rt-dlsym rel, ;

: rel-dispatch ( word-table# class -- ) rt-dispatch rel, ;

: rel-word ( word class -- )
    over primitive? [
        >r word-primitive r> rt-primitive
    ] [
        >r add-word r> rt-xt
    ] if rel, ;

: rel-literal ( literal class -- )
    >r add-literal r> rt-literal rel, ;

: rel-label ( label class -- )
    compiled-offset 3array label-table get push ;

: generate-labels ( -- )
    label-table get [
        first3 >r >r label-offset r> rt-label r> (rel)
        relocation-table get nappend
    ] each ;

: compiling? ( word -- ? )
    {
        { [ dup compiled-xts get hash-member? ] [ drop t ] }
        { [ dup word-changed? ] [ drop f ] }
        { [ t ] [ compiled? ] }
    } cond ;

: with-compiler ( quot -- )
    [
        H{ } clone compiled-xts set
        call
        compiled-xts get hash>alist finalize-compile
    ] with-scope ;
