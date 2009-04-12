! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces make assocs io sequences
continuations math math.parser accessors definitions
source-files.errors ;
IN: compiler.errors

SYMBOLS: +compiler-error+ +compiler-warning+ +linkage-error+ ;

TUPLE: compiler-error < source-file-error ;

M: compiler-error source-file-error-type error>> source-file-error-type ;

SYMBOL: compiler-errors

compiler-errors [ H{ } clone ] initialize

SYMBOL: with-compiler-errors?

: errors-of-type ( type -- assoc )
    compiler-errors get-global
    swap [ [ nip source-file-error-type ] dip eq? ] curry
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
    "compiler errors" +compiler-error+ "errors" (compiler-report)
    "compiler warnings" +compiler-warning+ "warnings" (compiler-report)
    "linkage errors" +linkage-error+ "linkage" (compiler-report) ;

: <compiler-error> ( error word -- compiler-error )
    \ compiler-error <definition-error> ;

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
