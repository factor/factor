USING: kernel math sql:utils ;
IN: sql

: save-tuple ( tuple -- )
    dup "id" tuple-slot [
        update-tuple
    ] [
        insert-tuple
    ] if ;

: restore-tuple ( tuple -- )
    ;


