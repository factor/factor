! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel models alarms ;
IN: models.delay

TUPLE: delay < model model timeout alarm ;

: update-delay-model ( delay -- )
    [ model>> value>> ] keep set-model ;

: <delay> ( model timeout -- delay )
    f delay new-model
        swap >>timeout
        over >>model
        [ add-dependency ] keep ;

: cancel-delay ( delay -- )
    alarm>> [ cancel-alarm ] when* ;

: start-delay ( delay -- )
    dup
    [ [ f >>alarm update-delay-model ] curry ] [ timeout>> ] bi later
    >>alarm drop ;

M: delay model-changed nip dup cancel-delay start-delay ;

M: delay model-activated update-delay-model ;
