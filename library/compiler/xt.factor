! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler errors generic kernel lists math namespaces
strings vectors words ;

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

! Words being compiled are consed onto this list. When a word
! is encountered that has not been previously compiled, it is
! consed onto this list. Compilation stops when the list is
! empty.

SYMBOL: compile-words

! deferred-xts is a list of objects responding to the fixup
! generic.
SYMBOL: deferred-xts

! Some machinery to allow forward references
GENERIC: fixup ( object -- )

TUPLE: relative word where to ;

: just-compiled compiled-offset 4 - ;

C: relative ( word -- )
    dup t rel-word
    [ set-relative-word ] keep
    [ just-compiled swap set-relative-where ] keep
    [ compiled-offset swap set-relative-to ] keep ;

: relative ( word -- ) <relative> deferred-xts cons@ ;

: relative-fixup ( relative -- addr where )
    dup relative-word compiled-xt over relative-to -
    swap relative-where ;

M: relative fixup ( relative -- )
    relative-fixup set-compiled-cell ;

TUPLE: absolute word where ;

C: absolute ( word -- )
    dup f rel-word
    [ set-absolute-word ] keep
    [ just-compiled swap set-absolute-where ] keep ;

: absolute ( word -- ) <absolute> deferred-xts cons@ ;

M: absolute fixup ( absolute -- )
    dup absolute-word compiled-xt
    swap absolute-where set-compiled-cell ;

TUPLE: relative-24 ;

C: relative-24 ( word -- )
    [ >r <relative> r> set-delegate ] keep
    [ just-compiled swap set-relative-to ] keep ;

: relative-24 ( word -- ) <relative-24> deferred-xts cons@ ;

: check-24 ( addr -- )
    #! Check that the address can fit in a 24-bit wide address
    #! field, used by PowerPC instructions.
    dup BIN: 11111111111111111111111100 bitand = [
        "Cannot jump further than 64 megabytes" throw
    ] unless ;

M: relative-24 fixup
    relative-fixup over check-24 [ compiled-cell bitor ] keep
    set-compiled-cell ;

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

: fixup-xts ( -- )
    deferred-xts get [ fixup ] each  deferred-xts off ;

: with-compiler ( quot -- )
    [ call  fixup-xts  commit-xts ] with-scope ;

: postpone-word ( word -- )
    dup compiling? [ drop ] [ compile-words unique@ ] ifte ;
