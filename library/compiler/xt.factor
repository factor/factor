! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler errors kernel lists math namespaces strings
vectors words ;

! To support saving compiled code to disk, generator words
! append relocation instructions to this vector.
SYMBOL: relocation-table

: rel, ( n -- ) relocation-table get vector-push ;

: relocating compiled-offset cell - rel, ;

: rel-primitive ( word rel/abs -- )
    #! If flag is true; relative.
    0 1 ? rel, relocating word-primitive rel, ;

: rel-dlsym ( name dll rel/abs -- )
    #! If flag is true; relative.
    2 3 ? rel, relocating cons intern-literal rel, ;

: rel-address ( rel/abs -- )
    #! Relocate address just compiled. If flag is true,
    #! relative, and there is nothing to do.
    [ 4 rel, relocating 0 rel, ] unless ;

: rel-word ( word rel/abs -- )
    #! If flag is true; relative.
    over primitive? [ rel-primitive ] [ nip rel-address ] ifte ;

! We use a hashtable "compiled-xts" that maps words to
! xt's that are currently being compiled. The commit-xt's word
! sets the xt of each word in the hashtable to the value in the
! hastable.
!
! This has the advantage that we can compile a word before the
! words it depends on and perform a fixup later; among other
! things this enables mutually recursive words.

SYMBOL: compiled-xts

: save-xt ( word -- )
    compiled-offset swap compiled-xts [ acons ] change ;

: commit-xt ( xt word -- )
    dup t "compiled" set-word-prop  set-word-xt ;

: commit-xts ( -- )
    #! We must flush the instruction cache on PowerPC.
    flush-icache
    compiled-xts get [ unswons commit-xt ] each
    compiled-xts off ;

: compiled-xt ( word -- xt )
    dup compiled-xts get assoc [ word-xt ] ?unless ;

! "deferred-xts" is a list of [ where word relative ] pairs; the
! xt of word when its done compiling will be written to the
! offset, relative to the offset.

SYMBOL: deferred-xts

! Words being compiled are consed onto this list. When a word
! is encountered that has not been previously compiled, it is
! consed onto this list. Compilation stops when the list is
! empty.

SYMBOL: compile-words

: defer-xt ( word where rel/abs -- )
    #! After word is compiled, put its XT at where. If rel/abs
    #! is true, this is a relative jump.
    3dup compiled-offset 0 ? 3list deferred-xts cons@
    nip rel-word ;

: compiling? ( word -- ? )
    #! A word that is compiling or already compiled will not be
    #! added to the list of words to be compiled.
    dup compiled? [
        drop t
    ] [
        dup compile-words get contains? [
            drop t
        ] [
            compiled-xts get assoc
        ] ifte
    ] ifte ;

: fixup-deferred-xt ( word where relative -- )
    rot dup compiling? [
        compiled-xt swap - swap set-compiled-cell
    ] [
        "Not compiled: " swap word-name cat2 throw
    ] ifte ;

: fixup-deferred-xts ( -- )
    deferred-xts get [
        uncons uncons car fixup-deferred-xt
    ] each
    deferred-xts off ;

: with-compiler ( quot -- )
    [ call  fixup-deferred-xts  commit-xts ] with-scope ;

: postpone-word ( word -- )
    dup compiling? [ drop ] [ compile-words unique@ ] ifte ;
