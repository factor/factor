! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations definitions init io
kernel math math.parser namespaces sequences sorting ;
IN: source-files.errors

GENERIC: error-file ( error -- file )
GENERIC: error-line ( error -- line )

M: object error-file drop f ;
M: object error-line drop f ;

M: condition error-file error>> error-file ;
M: condition error-line error>> error-line ;

TUPLE: source-file-error error asset file line# ;

M: source-file-error error-file [ error>> error-file ] [ file>> ] bi or ;
M: source-file-error error-line [ error>> error-line ] [ line#>> ] bi or ;
M: source-file-error compute-restarts error>> compute-restarts ;

: sort-errors ( errors -- alist )
    [ [ line#>> 0 or ] sort-with ] { } assoc-map-as sort-keys ;

: group-by-source-file ( errors -- assoc )
    H{ } clone [ [ push-at ] curry [ dup file>> ] prepose each ] keep ;

TUPLE: error-type-holder type word plural icon quot forget-quot { fatal? initial: t } ;

TUPLE: error-type type word plural icon quot forget-quot { fatal? initial: t } ;

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
    error-types get
    [ nip dup quot>> call( -- seq ) length ] assoc-map
    [ [ fatal?>> ] [ 0 > ] bi* and ] assoc-filter ;

: error-summary ( -- )
    error-counts [
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

[ V{ } clone error-observers set-global ] "source-files.errors" add-startup-hook

: add-error-observer ( observer -- ) error-observers get push ;

: remove-error-observer ( observer -- ) error-observers get remove-eq! drop ;

: notify-error-observers ( -- ) error-observers get [ errors-changed ] each ;

: delete-file-errors ( seq file type -- )
    [
        [ swap file>> = ] [ swap error-type = ]
        bi-curry* bi and not
    ] 2curry filter! drop
    notify-error-observers ;

: delete-definition-errors ( definition -- )
    error-types get [
        second forget-quot>> dup
        [ call( definition -- ) ] [ 2drop ] if
    ] with each ;
