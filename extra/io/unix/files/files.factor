! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend io.nonblocking io.unix.backend io.files io
unix kernel math ;

: open-read ( path -- fd )
    O_RDONLY file-mode open dup io-error ;

M: unix-io <file-reader> ( path -- stream )
    open-read <reader> ;

: open-write ( path -- fd )
    O_WRONLY O_CREAT O_TRUNC bitor bitor file-mode open
    dup io-error ;

M: unix-io <file-writer> ( path -- stream )
    open-write <writer> ;

: open-append ( path -- fd )
    O_WRONLY O_APPEND O_CREAT bitor bitor file-mode open
    dup io-error
    dup 0 SEEK_END lseek io-error ;

M: unix-io <file-appender> ( path -- stream )
    open-append <writer> ;

M: unix-io delete-file ( path -- )
    unlink io-error ;

M: unix-io make-directory ( path -- )
    OCT: 777 mkdir io-error ;

M: unix-io delete-directory ( path -- )
    rmdir io-error ;
