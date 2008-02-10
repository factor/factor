! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel io.nonblocking io.unix.backend
bit-arrays sequences assocs unix math namespaces structs ;
IN: io.unix.select

TUPLE: select-mx read-fdset write-fdset ;

! Factor's bit-arrays are an array of bytes, OS X expects
! FD_SET to be an array of cells, so we have to account for
! byte order differences on big endian platforms
: munge ( i -- i' )
    little-endian? [ BIN: 11000 bitxor ] unless ; inline

: <select-mx> ( -- mx )
    select-mx construct-mx
    FD_SETSIZE 8 * <bit-array> over set-select-mx-read-fdset
    FD_SETSIZE 8 * <bit-array> over set-select-mx-write-fdset ;

: handle-fd ( fd task fdset mx -- )
    roll munge rot nth [ swap handle-io-task ] [ 2drop ] if ;

: handle-fdset ( tasks fdset mx -- )
    [ handle-fd ] 2curry assoc-each ;

: init-fdset ( tasks fdset -- )
    dup clear-bits
    [ >r drop t swap munge r> set-nth ] curry assoc-each ;

: read-fdset/tasks
    { mx-reads select-mx-read-fdset } get-slots ;

: write-fdset/tasks
    { mx-writes select-mx-write-fdset } get-slots ;

: init-fdsets ( mx -- read write except )
    [ read-fdset/tasks tuck init-fdset ] keep
    write-fdset/tasks tuck init-fdset
    f ;

M: select-mx wait-for-events ( ms mx -- )
    swap >r FD_SETSIZE over init-fdsets r> make-timeval
    select multiplexer-error
    dup read-fdset/tasks pick handle-fdset
    dup write-fdset/tasks rot handle-fdset ;
