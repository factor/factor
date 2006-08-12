! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays assembler errors generic hashtables kernel
kernel-internals math namespaces prettyprint queues
sequences strings vectors words ;

DEFER: (compile)

: compiled-offset ( -- n ) building get length code-format * ;

TUPLE: label offset ;

C: label ( -- label ) ;

: define-label ( name -- ) <label> swap set ;

: resolve-label ( label -- )
    compiled-offset swap set-label-offset ;

SYMBOL: compiled-xts

: save-xt ( word xt -- )
    over changed-words get remove-hash
    swap compiled-xts get set-hash ;

SYMBOL: literal-table

: add-literal ( obj -- n )
    dup literal-table get [ eq? ] find-with drop dup -1 > [
        nip
    ] [
        drop literal-table get dup length >r push r>
    ] if ;

SYMBOL: relocation-table
SYMBOL: label-table

: rel-absolute-cell 0 ;
: rel-absolute 1 ;
: rel-relative 2 ;
: rel-absolute-2/2 3 ;
: rel-relative-2/2 4 ;
: rel-relative-2 5 ;
: rel-relative-3 6 ;

: (rel) ( arg class type offset -- { type offset } )
    #! Write a relocation instruction for the runtime image
    #! loader.
    pick rel-absolute-cell = cell 4 ? -
    >r >r >r 16 shift r> 8 shift bitor r> bitor r>
    2array ;

: rel, ( arg class type -- )
    compiled-offset (rel) relocation-table get swap nappend ;

: rel-dlsym ( name dll class -- )
   >r 2array add-literal r> 1 rel, ;

: rel-here ( class -- )
    dup rel-relative = [ drop ] [ 0 swap 2 rel, ] if ;

: rel-word ( word class -- )
    over primitive?
    [ >r word-primitive r> 0 ] [ >r add-literal r> 5 ] if
    rel, ;

: rel-cards ( class -- ) 0 swap 3 rel, ;

: rel-literal ( literal class -- )
    >r add-literal r> 4 rel, ;

: rel-label ( label class -- )
    compiled-offset 3array label-table get push ;

: generate-labels ( -- )
    label-table get [
        first3 >r >r label-offset r> 6 r> (rel)
        relocation-table get swap nappend
    ] each ;

: compiling? ( word -- ? )
    {
        { [ dup compiled-xts get hash-member? ] [ drop t ] }
        { [ dup changed-words get hash-member? ] [ drop f ] }
        { [ t ] [ compiled? ] }
    } cond ;

: with-compiler ( quot -- )
    [
        H{ } clone compiled-xts set
        call
        compiled-xts get hash>alist finalize-compile
    ] with-scope ;
