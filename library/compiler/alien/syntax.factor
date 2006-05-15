! Copyright (C) 2005 Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
IN: !syntax
USING: alien compiler kernel math namespaces parser
sequences syntax words ;

: DLL" skip-blank parse-string dlopen parsed ; parsing

: ALIEN: scan-word <alien> parsed ; parsing

: LIBRARY: scan "c-library" set ; parsing

: FUNCTION:
    scan "c-library" get scan string-mode on
    [ string-mode off define-c-word ] [ ] ; parsing

: TYPEDEF: scan scan typedef ; parsing

: BEGIN-STRUCT: ( -- offset )
    scan "struct-name" set  0 ; parsing

: FIELD: ( offset -- offset )
    scan scan define-field ; parsing

: END-STRUCT ( length -- )
    define-struct-type ; parsing

: C-UNION:
    scan "struct-name" set
    string-mode on [
        string-mode off
        0 [ define-member ] reduce define-struct-type
    ] [ ] ; parsing

: C-ENUM:
    string-mode on [
        string-mode off 0 [
            create-in swap [ unit define-compound ] keep 1+
        ] reduce drop
    ] [ ] ; parsing
