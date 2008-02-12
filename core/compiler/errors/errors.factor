! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces assocs prettyprint io sequences
sorting continuations debugger math math.parser ;
IN: compiler.errors

SYMBOL: +error+
SYMBOL: +warning+
SYMBOL: +linkage+

GENERIC: compiler-error-type ( error -- ? )

M: object compiler-error-type drop +error+ ;

<PRIVATE

SYMBOL: compiler-errors

SYMBOL: with-compiler-errors?

: compiler-error. ( error word -- )
    nl
    "While compiling " write pprint ": " print
    nl
    print-error ;

: errors-of-type ( type -- assoc )
    compiler-errors get-global
    swap [ >r nip compiler-error-type r> eq? ] curry
    assoc-subset ;

: compiler-errors. ( type -- )
    errors-of-type >alist sort-keys
    [ swap compiler-error. ] assoc-each ;

: (compiler-report) ( what type word -- )
    over errors-of-type assoc-empty? [ 3drop ] [
        [
            ":" %
            %
            " - print " %
            errors-of-type assoc-size #
            " " %
            %
            "." %
        ] "" make print
    ] if ;

: compiler-report ( -- )
    "semantic errors" +error+ "errors" (compiler-report)
    "semantic warnings" +warning+ "warnings" (compiler-report)
    "linkage errors" +linkage+ "linkage" (compiler-report) ;

PRIVATE>

: compiler-error ( error word -- )
    with-compiler-errors? get [
        compiler-errors get pick
        [ set-at ] [ delete-at drop ] if
    ] [ 2drop ] if ;

: :errors +error+ compiler-errors. ;

: :warnings +warning+ compiler-errors. ;

: :linkage +linkage+ compiler-errors. ;

: with-compiler-errors ( quot -- )
    with-compiler-errors? get "quiet" get or [ call ] [
        [
            with-compiler-errors? on
            V{ } clone compiler-errors set-global
            [ compiler-report ] [ ] cleanup
        ] with-scope
    ] if ; inline
