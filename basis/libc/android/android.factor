USING: alien.c-types alien.strings alien.syntax destructors kernel
libc.linux locals system ;
IN: libc

FUNCTION: int strerror_r ( int errno, char* buf, size_t buflen )

M:: android strerror ( errno -- str )
    [
        1024 malloc &free :> buffer
        errno buffer 1024 strerror_r drop
        buffer alien>native-string
    ] with-destructors ;
