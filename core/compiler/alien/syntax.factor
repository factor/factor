! Copyright (C) 2005, 2007 Slava Pestov, Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
IN: !syntax
USING: alien compiler kernel math namespaces parser
sequences syntax words quotations ;

: !DLL" skip-blank parse-string dlopen parsed ; parsing

: !ALIEN: scan string>number <alien> parsed ; parsing

: !LIBRARY: scan "c-library" set ; parsing

: !FUNCTION:
    scan "c-library" get scan ";" parse-tokens
    [ "()" subseq? not ] subset
    define-function ; parsing

: !TYPEDEF:
    scan scan [ typedef ] curry curry in-target ; parsing

: !C-STRUCT:
    scan in get
    parse-definition
    >r 2dup r> define-struct-early
    [ define-struct ] curry curry curry
    in-target ; parsing

: !C-UNION:
    scan in get
    ";" parse-tokens
    [ define-union ] curry curry curry
    in-target ; parsing

: !C-ENUM:
    ";" parse-tokens
    dup length
    [ >r create-in r> 1quotation define-compound ] 2each ;
    parsing
