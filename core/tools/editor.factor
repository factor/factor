! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: tools
USING: parser errors kernel namespaces sequences definitions
io ;

TUPLE: no-edit-hook ;

SYMBOL: edit-hook

: edit-location ( file line -- )
    >r ?resource-path r>
    edit-hook get [ call ] [ <no-edit-hook> throw ] if* ;

: edit ( defspec -- )
    where [ first2 edit-location ] when* ;
