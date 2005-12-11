! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler errors generic hashtables kernel
kernel-internals lists math namespaces prettyprint sequences
strings vectors words ;

! We use a hashtable "compiled-xts" that maps words to
! xt's that are currently being compiled. The commit-xt's word
! sets the xt of each word in the hashtable to the value in the
! hastable.
SYMBOL: compiled-xts

: save-xt ( word -- )
    compiled-offset swap compiled-xts get set-hash ;

: commit-xts ( -- )
    #! We must flush the instruction cache on PowerPC.
    flush-icache
    compiled-xts get [ swap set-word-xt ] hash-each ;

: compiled-xt ( word -- xt )
    dup compiled-xts get hash [ ] [ word-xt ] ?if ;

! deferred-xts is a vector of objects responding to the fixup
! generic.
SYMBOL: deferred-xts

: deferred-xt deferred-xts get push ;

! To support saving compiled code to disk, generator words
! append relocation instructions to this vector.
SYMBOL: relocation-table

: rel, ( n -- ) relocation-table get push ;

: cell-just-compiled compiled-offset cell - ;

: 4-just-compiled compiled-offset 4 - ;

: rel-absolute-cell 0 ;
: rel-absolute 1 ;
: rel-relative 2 ;
: rel-2/2 3 ;

: rel-type, ( arg class type -- )
    #! Write a relocation instruction for the runtime image
    #! loader.
    >r >r 16 shift r> 8 shift bitor r> bitor rel,
    cell-just-compiled rel, ;

: rel-dlsym ( name dll class -- )
    >r cons add-literal compiled-base - cell / r> 1 rel-type, ;

: rel-address ( class -- )
    #! Relocate address just compiled.
    dup rel-relative = [ 2drop ] [ 0 -rot 2 rel-type, ] if ;

: rel-word ( word class -- )
    over primitive? [
        >r word-primitive r> 0 rel-type,
    ] [
        rel-address drop
    ] if ;

: rel-userenv ( n class -- ) 3 rel-type, ;

: rel-cards ( class -- ) 4 rel-type, ;

! This is for fixing up forward references
GENERIC: resolve ( fixup -- addr )

TUPLE: absolute word ;

M: absolute resolve absolute-word compiled-xt ;

TUPLE: relative word to ;

M: relative resolve
    [ relative-word compiled-xt ] keep relative-to - ;

GENERIC: fixup ( addr fixup -- )

TUPLE: fixup-cell at ;

C: fixup-cell ( resolver at -- fixup )
    [ set-fixup-cell-at ] keep [ set-delegate ] keep ;

M: fixup-cell fixup ( addr fixup -- )
    fixup-cell-at set-compiled-cell ;

TUPLE: fixup-4 at ;

C: fixup-4 ( resolver at -- fixup )
    [ set-fixup-4-at ] keep [ set-delegate ] keep ;

M: fixup-4 fixup ( addr fixup -- )
    fixup-4-at set-compiled-4 ;

TUPLE: fixup-bitfield at mask ;

C: fixup-bitfield ( resolver at mask -- fixup )
    [ set-fixup-bitfield-mask ] keep
    [ set-fixup-bitfield-at ] keep
    [ set-delegate ] keep ;

: <fixup-3> ( resolver at -- )
    #! Only for PowerPC branch instructions.
    BIN: 11111111111111111111111100 <fixup-bitfield> ;

: <fixup-2> ( resolver at -- )
    #! Only for PowerPC conditional branch instructions.
    BIN: 1111111111111100 <fixup-bitfield> ;

: or-compiled ( n off -- )
    [ compiled-cell bitor ] keep set-compiled-cell ;

M: fixup-bitfield fixup ( addr fixup -- )
    [ fixup-bitfield-mask bitand ] keep
    fixup-bitfield-at or-compiled ;

TUPLE: fixup-2/2 at ;

C: fixup-2/2 ( resolver at -- fixup )
    [ set-fixup-2/2-at ] keep [ set-delegate ] keep ;

M: fixup-2/2 fixup ( addr fixup -- )
    fixup-2/2-at >r w>h/h r> tuck 4 - or-compiled or-compiled ;

: relative-4 ( word -- )
    dup rel-relative rel-word
    compiled-offset <relative>
    4-just-compiled <fixup-4> deferred-xt ;

: relative-3 ( word -- )
    #! Labels only -- no image relocation information saved
    4-just-compiled <relative>
    4-just-compiled <fixup-3> deferred-xt ;

: relative-2 ( word -- )
    #! Labels only -- no image relocation information saved
    4-just-compiled <relative>
    4-just-compiled <fixup-2> deferred-xt ;

: relative-2/2 ( word -- )
    #! Labels only -- no image relocation information saved
    compiled-offset <relative>
    4-just-compiled <fixup-2/2> deferred-xt ;

: absolute-4 ( word -- )
    dup rel-absolute rel-word
    <absolute> 4-just-compiled <fixup-4> deferred-xt ;

: absolute-2/2 ( word -- )
    dup rel-2/2 rel-word
    <absolute> cell-just-compiled <fixup-2/2> deferred-xt ;

: absolute-cell ( word -- )
    dup rel-absolute-cell rel-word
    <absolute> cell-just-compiled <fixup-cell> deferred-xt ;

! When a word is encountered that has not been previously
! compiled, it is pushed onto this vector. Compilation stops
! when the vector is empty.
SYMBOL: compile-words

: compiling? ( word -- ? )
    #! A word that is compiling or already compiled will not be
    #! added to the list of words to be compiled.
    dup compiled? over compile-words get member? or
    [ drop t ] [ compiled-xts get hash ] if ;

: fixup-xts ( -- )
    deferred-xts get [ dup resolve swap fixup ] each ;

: with-compiler ( quot -- )
    [
        V{ } clone deferred-xts set
        H{ } clone compiled-xts set
        V{ } clone compile-words set
        call
        fixup-xts
        commit-xts
    ] with-scope ;

: postpone-word ( word -- )
    dup compiling? not over compound? and
    [ dup compile-words get push ] when drop ;
