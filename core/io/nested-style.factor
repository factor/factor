! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: arrays generic assocs kernel namespaces strings
quotations ;

TUPLE: style-stream style ;

: do-nested-style ( style stream -- style delegate )
    [ style-stream-style swap union ] keep
    delegate ;

: collapse-nested-style ( style stream -- style steam )
    dup style-stream? [ do-nested-style ] when ;

: (with-stream-style) ( quot style stream -- )
    collapse-nested-style <style-stream> swap with-stream* ;
    inline

C: style-stream ( style delegate -- stream )
    [ set-delegate ] keep
    [ set-style-stream-style ] keep ;

M: style-stream stream-format
    do-nested-style stream-format ;

M: style-stream stream-write
    H{ } swap stream-format ;

M: style-stream stream-write1
    >r 1string H{ } r> stream-format ;

M: style-stream with-stream-style
    do-nested-style with-stream-style ;

: do-nested-quot ( quot style stream -- quot style stream )
    tuck >r >r
    style-stream-style swap \ with-style
    3array >quotation
    r> r> do-nested-style ;

M: style-stream with-nested-stream
    do-nested-quot with-nested-stream ;

M: style-stream make-table-cell
    do-nested-quot make-table-cell ;
