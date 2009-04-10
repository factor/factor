! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math.order sorting sequences ;
IN: source-files.errors

TUPLE: source-file-error error asset file line# ;

: sort-errors ( errors -- alerrors'ist )
    [ [ [ line#>> ] compare ] sort ] { } assoc-map-as sort-keys ;

: group-by-source-file ( errors -- assoc )
    H{ } clone [ [ push-at ] curry [ dup file>> ] prepose each ] keep ;

GENERIC: source-file-error-type ( error -- type )
