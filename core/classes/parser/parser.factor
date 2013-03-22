! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes compiler.units kernel parser vocabs.parser words ;
IN: classes.parser

: save-class-location ( class -- )
    location remember-class ;

: create-class-in ( string -- word )
    current-vocab create
    dup t "defining-class" set-word-prop
    dup set-word
    dup save-class-location
    dup create-predicate-word save-location ;

: scan-new-class ( -- word )
    scan-word-name create-class-in ;
