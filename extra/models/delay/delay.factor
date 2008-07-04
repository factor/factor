USING: kernel models alarms ;
IN: models.delay

TUPLE: delay model timeout alarm ;

: update-delay-model ( delay -- )
    dup delay-model model-value swap set-model ;

: <delay> ( model timeout -- delay )
    f delay construct-model
    [ set-delay-timeout ] keep
    [ set-delay-model ] 2keep
    [ add-dependency ] keep ;

: cancel-delay ( delay -- )
    delay-alarm [ cancel-alarm ] when* ;

: start-delay ( delay -- )
    dup [ f over set-delay-alarm update-delay-model ] curry
    over delay-timeout later
    swap set-delay-alarm ;

M: delay model-changed nip dup cancel-delay start-delay ;

M: delay model-activated update-delay-model ;
