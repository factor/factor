
USING: alien.syntax ;

IN: unix.ffi

FUNCTION: int open ( char* path, int flags, int prot ) ;

C-STRUCT: utimbuf
    { "time_t" "actime"  }
    { "time_t" "modtime" } ;

FUNCTION: int utime ( char* path, utimebuf* buf ) ;

FUNCTION: int err_no ( ) ;
FUNCTION: char* strerror ( int errno ) ;