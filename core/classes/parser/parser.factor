! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser vocabs.parser words kernel classes compiler.units lexer ;
IN: classes.parser

: save-class-location ( class -- )
    location remember-class ;

: create-class-in ( string -- word )
    current-vocab create
    dup save-class-location
    dup create-predicate-word dup set-word save-location ;

: CREATE-CLASS ( -- word )
    scan create-class-in ;
