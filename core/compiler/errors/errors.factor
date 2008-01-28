! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces assocs prettyprint io sequences
sorting continuations debugger math math.parser ;
IN: compiler.errors

SYMBOL: compiler-errors

SYMBOL: with-compiler-errors?

: compiler-error ( error word -- )
    with-compiler-errors? get [
        compiler-errors get pick
        [ set-at ] [ delete-at drop ] if
    ] [ 2drop ] if ;

: compiler-error. ( error word -- )
    nl
    "While compiling " write pprint ": " print
    nl
    print-error ;

: compiler-errors. ( assoc -- )
    >alist sort-keys [ swap compiler-error. ] assoc-each ;

GENERIC: compiler-warning? ( error -- ? )

M: object compiler-warning? drop f ;

: (:errors) ( -- assoc )
    compiler-errors get-global
    [ nip compiler-warning? not ] assoc-subset ;

: :errors (:errors) compiler-errors. ;

: (:warnings) ( -- seq )
    compiler-errors get-global
    [ nip compiler-warning? ] assoc-subset ;

: :warnings (:warnings) compiler-errors. ;

: (compiler-report) ( what assoc -- )
    length dup zero? [ 2drop ] [
        [
            ":" % over % " - print " % # " compiler " % % "." %
        ] "" make print
    ] if ;

: compiler-report ( -- )
    "errors" (:errors) (compiler-report)
    "warnings" (:warnings) (compiler-report) ;

: with-compiler-errors ( quot -- )
    with-compiler-errors? get "quiet" get or [ call ] [
        [
            with-compiler-errors? on
            V{ } clone compiler-errors set-global
            [ compiler-report ] [ ] cleanup
        ] with-scope
    ] if ; inline
