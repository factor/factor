! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: generic hashtables kernel namespaces strings ;

TUPLE: nested-style-stream style ;

: do-nested-style ( style stream -- style delegate )
    [ nested-style-stream-style hash-union ] keep delegate ;

: collapse-nested-style ( style delegate -- style delegate )
    dup nested-style-stream? [ do-nested-style ] when ;

C: nested-style-stream ( style delegate -- stream )
    >r collapse-nested-style r>
    [ set-delegate ] keep
    [ set-nested-style-stream-style ] keep ;

M: nested-style-stream stream-format
    do-nested-style stream-format ;

M: nested-style-stream stream-write
    H{ } swap do-nested-style stream-format ;

M: nested-style-stream stream-write1
    >r ch>string r> H{ } swap do-nested-style stream-format ;

M: nested-style-stream with-nested-stream
    do-nested-style with-nested-stream ;

M: nested-style-stream with-stream-table
    do-nested-style with-stream-table ;

: with-style ( style quot -- )
    >r stdio get <nested-style-stream> r> with-stream* ; inline
