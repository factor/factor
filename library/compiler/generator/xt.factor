! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays assembler errors generic hashtables kernel
kernel-internals math namespaces prettyprint queues
sequences strings vectors words ;

: compiled ( -- n ) building get length code-format * ;

TUPLE: label # offset ;

SYMBOL: label-table

: push-label ( label -- )
    label-table get 2dup memq?
    [ 2drop ] [ dup length pick set-label-# push ] if ;

C: label ( -- label ) ;

: define-label ( name -- ) <label> swap set ;

: resolve-label ( label -- )
    compiled swap set-label-offset ;

SYMBOL: compiled-xts

: save-xt ( word -- )
    compiled swap compiled-xts get set-hash ;

: commit-xts ( -- )
    compiled-xts get [ swap set-word-xt ] hash-each ;

SYMBOL: literal-table

: add-literal ( obj -- n )
    dup literal-table get [ eq? ] find-with drop dup -1 > [
        nip
    ] [
        drop literal-table get dup length >r push r>
    ] if ;

SYMBOL: relocation-table
SYMBOL: label-relocation-table

: rel-absolute-cell 0 ;
: rel-absolute 1 ;
: rel-relative 2 ;
: rel-absolute-2/2 3 ;
: rel-relative-2/2 4 ;
: rel-relative-2 5 ;
: rel-relative-3 6 ;

: (rel) ( arg class type -- { m n } )
    #! Write a relocation instruction for the runtime image
    #! loader.
    over >r >r >r 16 shift r> 8 shift bitor r> bitor
    compiled r> rel-absolute-cell = cell 4 ? - 2array ;

: rel, ( arg class type -- )
    (rel) relocation-table get nappend ;

: label, ( arg class type -- )
    (rel) label-relocation-table get nappend ;

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
    >r dup push-label label-# r> 5 label, ;

! When a word is encountered that has not been previously
! compiled, it is pushed onto this vector. Compilation stops
! when the vector is empty.
SYMBOL: compile-words

: compiling? ( word -- ? )
    #! A word that is compiling or already compiled will not be
    #! added to the list of words to be compiled.
    dup compiled?
    over compile-words get member? or
    swap compiled-xts get hash-member? or ;

: with-compiler ( quot -- )
    [
        H{ } clone compiled-xts set
        V{ } clone compile-words set
        call
        finalize-compile
        commit-xts
    ] with-scope ;

: postpone-word ( word -- )
    dup compiling? not over compound? and
    [ dup compile-words get push ] when drop ;
