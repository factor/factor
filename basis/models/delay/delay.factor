! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel models timers ;
IN: models.delay

TUPLE: delay < model model timeout timer ;

: update-delay-model ( delay -- )
    [ model>> value>> ] keep set-model ;

: <delay> ( model timeout -- delay )
    f delay new-model
        swap >>timeout
        over >>model
    [ add-dependency ] keep ;

: stop-delay ( delay -- )
    timer>> [ stop-timer ] when* ;

: start-delay ( delay -- )
    [ '[ _ f >>timer update-delay-model ] ]
    [ timeout>> later ]
    [ timer<< ] tri ;

M: delay model-changed nip dup stop-delay start-delay ;

M: delay model-activated update-delay-model ;
