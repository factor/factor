USING: alien.c-types alien.syntax kernel math ;
IN: structs

C-STRUCT: timeval
    { "long" "sec" }
    { "long" "usec" } ;

: make-timeval ( ms -- timeval )
    1000 /mod 1000 *
    "timeval" <c-object>
    [ set-timeval-usec ] keep
    [ set-timeval-sec ] keep ;

C-STRUCT: timespec
    { "time_t" "sec" }
    { "long" "nsec" } ;

: make-timespec ( ms -- timespec )
    1000 /mod 1000000 *
    "timespec" <c-object>
    [ set-timespec-nsec ] keep
    [ set-timespec-sec ] keep ;
