! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: namespaces
USING: arrays hashtables kernel kernel-internals lists math
sequences strings vectors words ;

: namestack* 3 getenv ; inline
: namestack namestack* clone ; inline
: set-namestack clone 3 setenv ; inline
: namespace namestack* peek ; inline
: >n namestack* push ; inline
: n> namestack* pop ; inline
: global 4 getenv ; inline
: get namestack* hash-stack ; flushable
: set namespace set-hash ;
: on t swap set ; inline
: off f swap set ; inline
: set-global global set-hash ; inline
: nest dup namespace hash [ ] [ >r H{ } clone dup r> set ] ?if ;
: change >r dup get r> rot slip set ; inline
: inc [ 1+ ] change ; inline
: dec [ 1- ] change ; inline
: bind swap >n call n> drop ; inline
: make-hash H{ } clone >n call n> ; inline
: with-scope make-hash drop ; inline

! Building sequences
SYMBOL: building
: make
    [
        dup thaw building set >r call building get r> like
    ] with-scope ; inline
: , building get push ;
: ?, [ , ] [ drop ] if ;
: % building get swap nappend ;
: # number>string % ;

! Building hashtables, and computing a transitive closure.
SYMBOL: hash-buffer

: closure, ( value key -- old )
    hash-buffer get [ hash swap ] 2keep set-hash ;

: (closure) ( key hash -- )
    tuck hash dup [
        [
            drop dup dup closure,
            [ 2drop ] [ swap (closure) ] if
        ] hash-each-with
    ] [
        2drop
    ] if ;

: closure ( key hash -- list )
    [
        H{ } clone hash-buffer set
        (closure)
        hash-buffer get hash-keys
    ] with-scope ;

IN: lists

: alist>quot ( default alist -- quot )
    [ [ first2 swap % , , \ if , ] [ ] make ] each ;

IN: kernel-internals

: init-namespaces ( -- ) global 1array >vector set-namestack ;
