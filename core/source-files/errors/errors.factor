! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math.order sorting ;
IN: source-files.errors

TUPLE: source-file-error error file line# ;

: sort-errors ( assoc -- alist )
    [ [ [ line#>> ] compare ] sort ] { } assoc-map-as sort-keys ;

: group-by-source-file ( errors -- assoc )
    H{ } clone [ [ push-at ] curry [ nip dup file>> ] prepose assoc-each ] keep ;
