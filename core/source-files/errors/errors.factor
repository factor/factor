! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math.order sorting sequences definitions
namespaces arrays ;
IN: source-files.errors

TUPLE: source-file-error error asset file line# ;

: sort-errors ( errors -- alist )
    [ [ [ line#>> ] compare ] sort ] { } assoc-map-as sort-keys ;

: group-by-source-file ( errors -- assoc )
    H{ } clone [ [ push-at ] curry [ dup file>> ] prepose each ] keep ;

GENERIC: source-file-error-type ( error -- type )

: <definition-error> ( error definition class -- source-file-error )
    new
        swap
        [ >>asset ]
        [
            where [ first2 ] [ "<unknown file>" 0 ] if*
            [ >>file ] [ >>line# ] bi*
        ] bi
        swap >>error ; inline

: delete-file-errors ( seq file type -- )
    [
        [ swap file>> = ] [ swap source-file-error-type = ]
        bi-curry* bi and not
    ] 2curry filter-here ;

SYMBOL: source-file-error-types

source-file-error-types [ V{ } clone ] initialize

: error-types ( -- seq ) source-file-error-types get keys ;

: define-error-type ( type icon quot -- )
    2array swap source-file-error-types get set-at ;

: error-icon-path ( type -- icon )
    source-file-error-types get at first ;

: all-errors ( -- errors )
    source-file-error-types get
    [ second second call( -- seq ) ] map
    concat ;