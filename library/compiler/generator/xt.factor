! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays assembler errors generic hashtables kernel
kernel-internals math namespaces prettyprint queues
sequences strings vectors words ;

: <label> ( -- label )
    #! Make a label.
    gensym  dup t "label" set-word-prop ;

: label? ( obj -- ? )
    dup word? [ "label" word-prop ] [ drop f ] if ;

! We use a hashtable "compiled-xts" that maps words to
! xt's that are currently being compiled. The commit-xt's word
! sets the xt of each word in the hashtable to the value in the
! hastable.
SYMBOL: compiled-xts

: save-xt ( xt word -- ) compiled-xts get set-hash ;

: commit-xts ( -- )
    compiled-xts get [ swap set-word-xt ] hash-each ;

: compiled-xt ( word -- xt )
    dup compiled-xts get hash [ ] [ word-xt ] ?if ;

SYMBOL: literal-table

: add-literal ( obj -- n )
    dup literal-table get [ eq? ] find-with drop dup -1 > [
        nip
    ] [
        drop literal-table get dup length >r push r>
    ] if ;

SYMBOL: relocation-table

: rel, ( n -- ) relocation-table get push ;

: rel-absolute-cell 0 ;
: rel-absolute 1 ;
: rel-relative 2 ;
: rel-absolute-2/2 3 ;
: rel-relative-2/2 4 ;
: rel-relative-2 5 ;
: rel-relative-3 6 ;

: compiled ( -- n ) building get length code-format * ;

: rel-type, ( arg class type -- )
    #! Write a relocation instruction for the runtime image
    #! loader.
    over >r >r >r 16 shift r> 8 shift bitor r> bitor rel,
    compiled r> rel-absolute-cell = cell 4 ? - rel, ;

: rel-dlsym ( name dll class -- )
   >r 2array add-literal r> 1 rel-type, ;

: rel-here ( class -- )
    dup rel-relative = [ drop ] [ 0 swap 2 rel-type, ] if ;

: rel-word ( word class -- )
    over primitive?
    [ >r word-primitive r> 0 ] [ >r add-literal r> 5 ] if
    rel-type, ;

: rel-cards ( class -- ) 0 swap 3 rel-type, ;

: rel-literal ( literal class -- )
    >r add-literal r> 4 rel-type, ;

! When a word is encountered that has not been previously
! compiled, it is pushed onto this vector. Compilation stops
! when the vector is empty.
SYMBOL: compile-words

: compiling? ( word -- ? )
    #! A word that is compiling or already compiled will not be
    #! added to the list of words to be compiled.
    dup compiled?
    over label? or
    over compile-words get member? or
    swap compiled-xts get hash or ;

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
