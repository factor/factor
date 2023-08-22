! Copyright (C) 2005, 2010 Slava Pestov, Alex Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.enums alien.libraries
alien.parser kernel lexer namespaces parser sequences
strings.parser vocabs words ;
<< "alien.arrays" require >> ! needed for bootstrap
IN: alien.syntax

SYNTAX: DLL" lexer get skip-blank parse-string dlopen suffix! ;

SYNTAX: ALIEN: 16 scan-base <alien> suffix! ;

SYNTAX: BAD-ALIEN <bad-alien> suffix! ;

SYNTAX: LIBRARY: scan-token current-library set ;

SYNTAX: FUNCTION:
    (FUNCTION:) make-function define-inline ;

SYNTAX: FUNCTION-ALIAS:
    scan-token create-function
    (FUNCTION:) (make-function) define-inline ;

SYNTAX: CALLBACK:
    (CALLBACK:) define-inline ;

SYNTAX: TYPEDEF:
    scan-c-type CREATE-C-TYPE dup save-location typedef ;

SYNTAX: ENUM:
    parse-enum (define-enum) ;

SYNTAX: C-TYPE:
    void CREATE-C-TYPE typedef ;

SYNTAX: &:
    scan-token current-library get '[ _ _ address-of ] append! ;

SYNTAX: C-GLOBAL: scan-c-type scan-new-word define-global ;

SYNTAX: pointer:
    scan-c-type <pointer> suffix! ;

SYNTAX: INITIALIZE-ALIEN:
    scan-word parse-definition '[ _ _ initialize-alien ] append! ;
