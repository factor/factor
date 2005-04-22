! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io-internals
USING: kernel kernel-internals strings threads ;

BUILTIN: port 14 ;

: stdin 0 getenv ;
: stdout 1 getenv ;

: blocking-flush ( port -- )
    [ add-write-io-task stop ] callcc0 drop ;

: wait-to-write ( len port -- )
    tuck can-write? [ drop ] [ blocking-flush ] ifte ;

: blocking-write ( str port -- )
    over
    dup string? [ string-length ] [ drop 1 ] ifte
    over wait-to-write write-fd-8 ;

: blocking-fill ( port -- )
    [ add-read-line-io-task stop ] callcc0 drop ;

: wait-to-read-line ( port -- )
    dup can-read-line? [ drop ] [ blocking-fill ] ifte ;

: blocking-read-line ( port -- line )
    dup wait-to-read-line read-line-fd-8 dup [ sbuf>string ] when ;

: fill-fd ( count port -- )
    [ add-read-count-io-task stop ] callcc0 2drop ;

: wait-to-read ( count port -- )
    2dup can-read-count? [ 2drop ] [ fill-fd ] ifte ;

: blocking-read ( count port -- str )
    2dup wait-to-read read-count-fd-8 dup [ sbuf>string ] when ;

: wait-to-accept ( socket -- )
    [ add-accept-io-task stop ] callcc0 drop ;

: blocking-accept ( socket -- host port in out )
    dup wait-to-accept accept-fd ;

: blocking-copy ( in out -- )
    [ add-copy-io-task stop ] callcc0
    pending-io-error pending-io-error ;
