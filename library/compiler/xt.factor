! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler errors kernel lists math namespaces strings
words ;

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

: defer-xt ( word where relative -- )
    #! After word is compiled, put its XT at where, relative.
    3list deferred-xts cons@ ;

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
