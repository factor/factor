! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel io.ports io.unix.backend
bit-arrays sequences assocs unix math namespaces structs
accessors math.order locals ;
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

:: check-fd ( fd fdset mx quot -- )
    fd munge fdset clear-nth [ fd mx quot call ] when ; inline

: check-fdset ( fds fdset mx quot -- )
    [ check-fd ] 3curry each ; inline

: init-fdset ( fds fdset -- )
    [ >r t swap munge r> set-nth ] curry each ;

: read-fdset/tasks ( mx -- seq fdset )
    [ reads>> keys ] [ read-fdset>> ] bi ;

: write-fdset/tasks ( mx -- seq fdset )
    [ writes>> keys ] [ write-fdset>> ] bi ;

: max-fd ( assoc -- n )
    dup assoc-empty? [ drop 0 ] [ keys supremum ] if ;

: num-fds ( mx -- n )
    [ reads>> max-fd ] [ writes>> max-fd ] bi max 1+ ;

: init-fdsets ( mx -- nfds read write except )
    [ num-fds ]
    [ read-fdset/tasks [ init-fdset ] keep ]
    [ write-fdset/tasks [ init-fdset ] keep ] tri
    f ;

M:: select-mx wait-for-events ( ms mx -- )
    mx
    [ init-fdsets ms dup [ make-timeval ] when select multiplexer-error ]
    [ [ read-fdset/tasks ] keep [ input-available ] check-fdset ]
    [ [ write-fdset/tasks ] keep [ output-available ] check-fdset ]
    tri ;
