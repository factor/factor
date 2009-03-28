! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces make assocs io sequences
sorting continuations math math.order math.parser accessors
definitions ;
IN: compiler.errors

SYMBOL: +error+
SYMBOL: +warning+
SYMBOL: +linkage+

TUPLE: compiler-error error word file line# ;

GENERIC: compiler-error-type ( error -- ? )

M: object compiler-error-type drop +error+ ;

M: compiler-error compiler-error-type error>> compiler-error-type ;

GENERIC: compiler-error. ( error -- )

SYMBOL: compiler-errors

compiler-errors [ H{ } clone ] initialize

SYMBOL: with-compiler-errors?

: errors-of-type ( type -- assoc )
    compiler-errors get-global
    swap [ [ nip compiler-error-type ] dip eq? ] curry
    assoc-filter ;

: sort-compile-errors ( assoc -- alist )
    [ [ [ line#>> ] compare ] sort ] { } assoc-map-as sort-keys ;

: group-by-source-file ( errors -- assoc )
    H{ } clone [ [ push-at ] curry [ nip dup file>> ] prepose assoc-each ] keep ;

: compiler-errors. ( type -- )
    errors-of-type group-by-source-file sort-compile-errors
    [
        [ nl "==== " write print nl ]
        [ [ nl ] [ compiler-error. ] interleave ]
        bi*
    ] assoc-each ;

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

: :errors ( -- ) +error+ compiler-errors. ;

: :warnings ( -- ) +warning+ compiler-errors. ;

: :linkage ( -- ) +linkage+ compiler-errors. ;

: <compiler-error> ( error word -- compiler-error )
    dup where [ first2 ] [ "<unknown file>" 0 ] if* \ compiler-error boa ;

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
