! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs definitions io io.styles kernel prettyprint
sorting see ;
IN: tools.crossref

: synopsis-alist ( definitions -- alist )
    [ [ synopsis ] keep ] { } map>assoc ;

: definitions. ( alist -- )
    [ write-object nl ] assoc-each ;

: sorted-definitions. ( definitions -- )
    synopsis-alist sort-keys definitions. ;

: usage. ( word -- )
    smart-usage sorted-definitions. ;
