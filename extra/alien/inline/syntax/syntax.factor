! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.inline lexer multiline namespaces parser ;
IN: alien.inline.syntax


SYNTAX: C-LIBRARY: scan define-c-library ;

SYNTAX: COMPILE-AS-C++ t library-is-c++ set ;

SYNTAX: C-LINK: scan c-link-to ;

SYNTAX: C-FRAMEWORK: scan c-use-framework ;

SYNTAX: C-LINK/FRAMEWORK: scan c-link-to/use-framework ;

SYNTAX: C-INCLUDE: scan c-include ;

SYNTAX: C-FUNCTION:
    function-types-effect parse-here define-c-function ;

SYNTAX: C-TYPEDEF: scan scan define-c-typedef ;

SYNTAX: C-STRUCTURE:
    scan parse-definition define-c-struct ;

SYNTAX: ;C-LIBRARY compile-c-library ;

SYNTAX: DELETE-C-LIBRARY: scan delete-inline-library ;

SYNTAX: <RAW-C "RAW-C>" parse-multiline-string raw-c ;
