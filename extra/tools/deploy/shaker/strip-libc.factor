USING: libc.private ;
IN: libc

: malloc (malloc) check-ptr ;

: realloc (realloc) check-ptr ;

: calloc (calloc) check-ptr ;

: free (free) ;
