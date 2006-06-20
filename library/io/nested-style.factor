! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: arrays generic hashtables kernel namespaces strings ;

TUPLE: nested-style-stream style ;

: (with-stream-style) ( quot style stream -- )
    <nested-style-stream> swap with-stream* ; inline

: do-nested-style ( style stream -- style delegate )
    [ nested-style-stream-style swap hash-union ] keep
    delegate ;

C: nested-style-stream ( style delegate -- stream )
    [ set-delegate ] keep
    [ set-nested-style-stream-style ] keep ;

M: nested-style-stream stream-format
    do-nested-style stream-format ;

M: nested-style-stream stream-write
    H{ } swap do-nested-style stream-format ;

M: nested-style-stream stream-write1
    >r ch>string r> H{ } swap do-nested-style stream-format ;

: do-nested-quot ( quot style stream -- quot style stream )
    tuck >r >r
    nested-style-stream-style swap \ with-style
    3array >quotation
    r> r> do-nested-style ;

M: nested-style-stream with-stream-style ( quot style stream -- )
    do-nested-style with-stream-style ;

M: nested-style-stream with-nested-stream
    do-nested-quot with-nested-stream ;

M: nested-style-stream with-stream-table
    do-nested-quot with-stream-table ;
