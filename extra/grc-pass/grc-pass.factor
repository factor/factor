! Copyright (C) 2019 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors http.client kernel math sequences splitting ;

IN: grc-pass

<PRIVATE

: get-pass ( key -- string )
    "https://www.grc.com/passwords.htm" http-get swap code>> 200 assert=
    string-lines [ dupd subseq? ] find 2nip
    "</font></td></tr></table>" over subseq-start head
    dup [ CHAR: > = ] find-last drop 1 + tail ;

: replace-& ( string -- string' )
    "&gt;" ">" replace "&lt;" "<" replace "&amp;" "&" replace ;

! Replace &amp; last to avoid side-effects. For example, "&amp;lt;" should
! become "&lt;", not "<".

PRIVATE>

: hex-pass ( -- string )
    "64 random hexadecimal characters (0-9 and A-F):" get-pass
    dup length 64 assert= ;

: ascii-pass ( -- string )
    "63 random printable ASCII characters:" get-pass replace-&
    dup length 63 assert= ;

: alnum-pass ( -- string )
    "63 random alpha-numeric characters (a-z, A-Z, 0-9):" get-pass
    dup length 63 assert= ;
