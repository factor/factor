! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math.order sorting sequences definitions
namespaces arrays splitting io math.parser math init ;
IN: source-files.errors

TUPLE: source-file-error error asset file line# ;

: sort-errors ( errors -- alist )
    [ [ [ line#>> ] compare ] sort ] { } assoc-map-as sort-keys ;

: group-by-source-file ( errors -- assoc )
    H{ } clone [ [ push-at ] curry [ dup file>> ] prepose each ] keep ;

TUPLE: error-type type word plural icon quot forget-quot ;

GENERIC: error-type ( error -- type )

: <definition-error> ( error definition class -- source-file-error )
    new
        swap
        [ >>asset ]
        [ where [ first2 [ >>file ] [ >>line# ] bi* ] when* ] bi
        swap >>error ; inline

SYMBOL: error-types

error-types [ V{ } clone ] initialize

: define-error-type ( error-type -- )
    dup type>> error-types get set-at ;

: error-icon-path ( type -- icon )
    error-types get at icon>> ;

: error-counts ( -- alist )
    error-types get [ nip dup quot>> call( -- seq ) length ] assoc-map ;

: error-summary ( -- )
    error-counts
    [ nip 0 > ] assoc-filter
    [
        over
        [ word>> write ]
        [ " - show " write number>string write bl ]
        [ plural>> print ] tri*
    ] assoc-each ;

: all-errors ( -- errors )
    error-types get values
    [ quot>> call( -- seq ) ] map
    concat ;

GENERIC: errors-changed ( observer -- )

SYMBOL: error-observers

[ V{ } clone error-observers set-global ] "source-files.errors" add-init-hook

: add-error-observer ( observer -- ) error-observers get push ;

: remove-error-observer ( observer -- ) error-observers get delq ;

: notify-error-observers ( -- ) error-observers get [ errors-changed ] each ;

: delete-file-errors ( seq file type -- )
    [
        [ swap file>> = ] [ swap error-type = ]
        bi-curry* bi and not
    ] 2curry filter-here
    notify-error-observers ;

: delete-definition-errors ( definition -- )
    error-types get [
        second forget-quot>> dup
        [ call( definition -- ) ] [ 2drop ] if
    ] with each ;