USING: kernel math sql:utils ;
IN: sql

: save ( tuple -- )
    dup "id" tuple-slot [
        ! update
    ] [
        ! insert
    ] if ;

: restore ( tuple -- )
    ;


