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
    compiled-xts get [ swap set-word-xt ] hash-each
    compiled-xts off ;

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

: relocating compiled-offset cell - rel, ;

: rel-type, ( rel/abs 16/16 type -- )
    swap 8 shift bitor swap 16 shift bitor rel, ;

: rel-primitive ( word relative 16/16 -- )
    0 rel-type, relocating word-primitive rel, ;

: rel-dlsym ( name dll rel/abs 16/16 -- )
    1 rel-type, relocating cons add-literal rel, ;

: rel-address ( rel/abs 16/16 -- )
    #! Relocate address just compiled.
    over 1 = [ 2drop ] [ 2 rel-type, relocating 0 rel, ] if ;

: rel-word ( word rel/abs 16/16 -- )
    pick primitive? [ rel-primitive ] [ rel-address drop ] if ;

: rel-userenv ( n 16/16 -- )
    0 swap 3 rel-type, relocating rel, ;

: rel-cards ( 16/16 -- )
    0 swap 4 rel-type, compiled-offset cell 2 * - rel, 0 rel, ;

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
    dup 1 0 rel-word
    compiled-offset <relative>
    compiled-offset 4 - <fixup-4> deferred-xt ;

: absolute-cell ( word -- )
    dup 0 0 rel-word
    <absolute> compiled-offset cell - <fixup-cell> deferred-xt ;

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
    deferred-xts get [ fixup ] each  deferred-xts off ;

: with-compiler ( quot -- )
    [
        V{ } deferred-xts set
        H{ } clone compiled-xts set
        V{ } clone compile-words set
        call
        fixup-xts
        commit-xts
    ] with-scope ;

: postpone-word ( word -- )
    dup compiling? not over compound? and
    [ dup compile-words get push ] when drop ;
