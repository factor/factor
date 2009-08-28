USING: libc.private ;
IN: libc

: malloc ( size -- newalien ) (malloc) check-ptr ;

: realloc ( alien size -- newalien ) (realloc) check-ptr ;

: calloc ( size count -- newalien ) (calloc) check-ptr ;

: free ( alien -- ) (free) ;

FORGET: malloc-ptr

FORGET: <malloc-ptr>
