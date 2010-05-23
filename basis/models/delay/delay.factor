! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms fry kernel models ;
IN: models.delay

TUPLE: delay < model model timeout alarm ;

: update-delay-model ( delay -- )
    [ model>> value>> ] keep set-model ;

: <delay> ( model timeout -- delay )
    f delay new-model
        swap >>timeout
        over >>model
        [ add-dependency ] keep ;

: stop-delay ( delay -- )
    alarm>> [ stop-alarm ] when* ;

: start-delay ( delay -- )
    dup
    [ '[ _ f >>alarm update-delay-model ] ] [ timeout>> ] bi
    later
    >>alarm drop ;

M: delay model-changed nip dup stop-delay start-delay ;

M: delay model-activated update-delay-model ;
