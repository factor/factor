! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help-lint
USING: sequences parser kernel errors help words modules strings
namespaces io prettyprint tools definitions generic ;

! A quick and dirty tool to check documentation in an automated
! fashion.

! - ensures examples run and produce stated output
! - ensures $see-also elements don't contain duplicate entries
!   (I always make this mistake!)
! - ensures $module-link elements point to modules which
!   actually exist
! - ensures that $values match the stack effect declaration
! - ensures that word help articles render (this catches broken
!   links, improper nesting, etc)

: check-example ( element -- )
    1 tail
    [ 1 head* "\n" join eval>string "\n" ?tail drop ] keep
    peek assert= ;

: check-examples ( word element -- )
    nip \ $example swap elements [ check-example ] each ;

: extract-values ( element -- seq )
    \ $values swap elements dup empty? [
        drop { }
    ] [
        first 1 tail [ first ] map prune natural-sort
    ] if ;

: effect-values ( word -- seq )
    stack-effect dup effect-in swap effect-out
    append [ string? ] subset prune natural-sort ;

: check-values ( word element -- )
    \ $shuffle over elements empty?
    \ $values-x/y over elements empty? not and
    pick "declared-effect" word-prop and [
        extract-values >r effect-values r> assert=
    ] [
        2drop
    ] if ;

: check-see-also ( word element -- )
    nip \ $see-also swap elements [
        1 tail dup prune [ length ] 2apply assert=
    ] each ;

: check-modules ( word element -- )
    nip \ $module-link swap elements [
        second
        \ available-modules get member?
        [ "Missing module" throw ] unless
    ] each ;

: check-rendering ( word element -- )
    drop [ help ] string-out drop ;

: all-word-help ( -- seq )
    all-words [ word-help ] subset ;

TUPLE: word-help-error word ;

C: word-help-error
    [ set-delegate ] keep
    [ set-word-help-error-word ] keep ;

DEFER: check-help

: fix-help ( error -- )
    dup delegate error.
    word-help-error-word <link> edit
    "Press ENTER when done." print flush readln drop
    reload-modules
    check-help ;

: check-1 ( word -- )
    [
        dup word-help [
            2dup check-examples
            2dup check-values
            2dup check-see-also
            2dup check-modules
            2dup check-rendering
        ] assert-depth 2drop
    ] [
        <word-help-error> throw
    ] recover ;

: check-help ( -- )
    [
        [
            available-modules [ module-name ] map
            \ available-modules set
            all-word-help [ check-1 ] each
        ] with-scope
    ] [
        fix-help check-help
    ] recover ;

: unlinked-words ( -- seq )
    all-word-help [ parents empty? ] subset ;

: linked-undocumented-words ( -- seq )
    all-words
    [ word-help not ] subset
    [ parents empty? not ] subset
    [ "predicating" word-prop not ] subset ;

PROVIDE: apps/help-lint ;

MAIN: apps/help-lint check-help ;
