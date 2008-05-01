! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel io.nonblocking io.unix.backend
bit-arrays sequences assocs unix math namespaces structs
accessors math.order ;
IN: io.unix.select

TUPLE: select-mx < mx read-fdset write-fdset ;

! Factor's bit-arrays are an array of bytes, OS X expects
! FD_SET to be an array of cells, so we have to account for
! byte order differences on big endian platforms
: munge ( i -- i' )
    little-endian? [ BIN: 11000 bitxor ] unless ; inline

: <select-mx> ( -- mx )
    select-mx new-mx
        FD_SETSIZE 8 * <bit-array> >>read-fdset
        FD_SETSIZE 8 * <bit-array> >>write-fdset ;

: clear-nth ( n seq -- ? )
    [ nth ] [ f -rot set-nth ] 2bi ;

: handle-fd ( fd task fdset mx -- )
    roll munge rot clear-nth
    [ swap handle-io-task ] [ 2drop ] if ;

: handle-fdset ( tasks fdset mx -- )
    [ handle-fd ] 2curry assoc-each ;

: init-fdset ( tasks fdset -- )
    [ >r drop t swap munge r> set-nth ] curry assoc-each ;

: read-fdset/tasks
    [ reads>> ] [ read-fdset>> ] bi ;

: write-fdset/tasks
    [ writes>> ] [ write-fdset>> ] bi ;

: max-fd ( assoc -- n )
    dup assoc-empty? [ drop 0 ] [ keys supremum ] if ;

: num-fds ( mx -- n )
    [ reads>> max-fd ] [ writes>> max-fd ] bi max 1+ ;

: init-fdsets ( mx -- nfds read write except )
    [ num-fds ]
    [ read-fdset/tasks tuck init-fdset ]
    [ write-fdset/tasks tuck init-fdset ] tri
    f ;

M: select-mx wait-for-events ( ms mx -- )
    swap >r dup init-fdsets r> dup [ make-timeval ] when
    select multiplexer-error
    dup read-fdset/tasks pick handle-fdset
    dup write-fdset/tasks rot handle-fdset ;
