! Copyright (C) 2005, 2009 Slava Pestov, Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays alien alien.c-types alien.structs
alien.arrays alien.strings kernel math namespaces parser
sequences words quotations math.parser splitting grouping
effects assocs combinators lexer strings.parser alien.parser 
fry vocabs.parser words.constant alien.libraries ;
IN: alien.syntax

SYNTAX: DLL" lexer get skip-blank parse-string dlopen parsed ;

SYNTAX: ALIEN: scan string>number <alien> parsed ;

SYNTAX: BAD-ALIEN <bad-alien> parsed ;

SYNTAX: LIBRARY: scan "c-library" set ;

SYNTAX: FUNCTION:
    scan "c-library" get scan ";" parse-tokens
    [ "()" subseq? not ] filter
    define-function ;

SYNTAX: TYPEDEF:
    scan scan typedef ;

SYNTAX: C-STRUCT:
    scan in get parse-definition define-struct ;

SYNTAX: C-UNION:
    scan parse-definition define-union ;

SYNTAX: C-ENUM:
    ";" parse-tokens
    [ [ create-in ] dip define-constant ] each-index ;

: address-of ( name library -- value )
    load-library dlsym [ "No such symbol" throw ] unless* ;

SYNTAX: &:
    scan "c-library" get '[ _ _ address-of ] over push-all ;
