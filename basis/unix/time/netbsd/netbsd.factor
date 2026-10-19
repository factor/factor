USING: alien.c-types alien.syntax unix.types ;
IN: unix.time

FUNCTION-ALIAS: time time_t __time50 ( time_t* t )
FUNCTION-ALIAS: localtime tm* __locatime50 ( time_t* clock )
FUNCTION-ALIAS: gettimeofday int __gettimeofday50 ( timeval* TP, void* TZP )
FUNCTION-ALIAS: settimeofday int __settimeofday50 ( timeval* TP, timezone* TZP )
FUNCTION-ALIAS: adjtime int __adjtime50 ( timeval* delta, timeval* olddelta )
