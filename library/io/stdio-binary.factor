! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: stdio
USING: kernel math ;

: read-le32 ( -- word )
    read1
    read1 8  shift bitor
    read1 16 shift bitor
    read1 24 shift bitor ;

: read-be32 ( -- word )
    read1 24 shift
    read1 16 shift bitor
    read1 8  shift bitor
    read1          bitor ;

: byte7 ( num -- byte ) -56 shift HEX: ff bitand ;
: byte6 ( num -- byte ) -48 shift HEX: ff bitand ;
: byte5 ( num -- byte ) -40 shift HEX: ff bitand ;
: byte4 ( num -- byte ) -32 shift HEX: ff bitand ;
: byte3 ( num -- byte ) -24 shift HEX: ff bitand ;
: byte2 ( num -- byte ) -16 shift HEX: ff bitand ;
: byte1 ( num -- byte )  -8 shift HEX: ff bitand ;
: byte0 ( num -- byte )           HEX: ff bitand ;

: write-le64 ( word -- )
    dup byte0 write
    dup byte1 write
    dup byte2 write
    dup byte3 write
    dup byte4 write
    dup byte5 write
    dup byte6 write
        byte7 write ;

: write-be64 ( word -- )
    dup byte7 write
    dup byte6 write
    dup byte5 write
    dup byte4 write
    dup byte3 write
    dup byte2 write
    dup byte1 write
        byte0 write ;

: write-le32 ( word -- )
    dup byte0 write
    dup byte1 write
    dup byte2 write
        byte3 write ;

: write-be32 ( word -- )
    dup byte3 write
    dup byte2 write
    dup byte1 write
        byte0 write ;

: write-le16 ( char -- )
    dup byte0 write
        byte1 write ;

: write-be16 ( char -- )
    dup byte1 write
        byte0 write ;
