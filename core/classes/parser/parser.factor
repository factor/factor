! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: classes compiler.units kernel parser vocabs.parser words ;
IN: classes.parser

: save-class-location ( class -- )
    location remember-class ;

: create-class ( string vocab -- word )
    create-word
    dup t "defining-class" set-word-prop
    dup set-last-word
    dup save-class-location
    dup create-predicate-word save-location ;

: create-class-in ( string -- word )
    current-vocab create-class ;

: scan-new-class ( -- word )
    scan-word-name create-class-in ;
