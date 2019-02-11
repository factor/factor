! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel models timers ;
IN: models.delay

TUPLE: delay < model model timeout timer ;

: update-delay-model ( delay -- )
    [ model>> value>> ] keep set-model ;

: <delay> ( model timeout -- delay )
    f delay new-model
        dup '[ _ update-delay-model ] pick f <timer> >>timer
        swap >>timeout
        over >>model
    [ add-dependency ] keep ;

M: delay model-changed
    ! BUG: timer can't be "restart-timer" inside of its quotation?
    ! nip timer>> restart-timer ;
    nip timer>> [ stop-timer ] [ start-timer ] bi ;


M: delay model-activated update-delay-model ;
