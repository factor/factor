! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces make assocs io sequences
continuations math math.parser accessors definitions
source-files.errors ;
IN: compiler.errors

SYMBOLS: +error+ +warning+ +linkage+ ;

TUPLE: compiler-error < source-file-error word ;

GENERIC: compiler-error-type ( error -- ? )

M: object compiler-error-type drop +error+ ;

M: compiler-error compiler-error-type error>> compiler-error-type ;

SYMBOL: compiler-errors

compiler-errors [ H{ } clone ] initialize

SYMBOL: with-compiler-errors?

: errors-of-type ( type -- assoc )
    compiler-errors get-global
    swap [ [ nip compiler-error-type ] dip eq? ] curry
    assoc-filter ;

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

: <compiler-error> ( error word -- compiler-error )
    \ compiler-error new
        swap
        [ >>word ]
        [ where [ first2 ] [ "<unknown file>" 0 ] if* [ >>file ] [ >>line# ] bi* ] bi
        swap >>error ;

: compiler-error ( error word -- )
    compiler-errors get-global pick
    [ [ [ <compiler-error> ] keep ] dip set-at ] [ delete-at drop ] if ;

: with-compiler-errors ( quot -- )
    with-compiler-errors? get "quiet" get or [ call ] [
        [
            with-compiler-errors? on
            [ compiler-report ] [ ] cleanup
        ] with-scope
    ] if ; inline
