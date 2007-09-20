! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.nested
USING: arrays generic assocs kernel namespaces strings
quotations io ;

TUPLE: ignore-close-stream ;

: <ignore-close-stream> ignore-close-stream construct-delegate ;

M: ignore-close-stream stream-close drop ;

TUPLE: style-stream style ;

: do-nested-style ( style stream -- style delegate )
    [ style-stream-style swap union ] keep
    delegate ; inline

: <style-stream> ( style delegate -- stream )
    { set-style-stream-style set-delegate }
    style-stream construct ;

M: style-stream stream-format
    do-nested-style stream-format ;

M: style-stream stream-write
    dup style-stream-style swap delegate stream-format ;

M: style-stream stream-write1
    >r 1string r> stream-write ;

M: style-stream make-span-stream
    do-nested-style make-span-stream ;

M: style-stream make-block-stream
    [ do-nested-style make-block-stream ] keep
    style-stream-style swap <style-stream> ;

M: style-stream make-cell-stream
    [ do-nested-style make-cell-stream ] keep
    style-stream-style swap <style-stream> ;

TUPLE: block-stream ;

: <block-stream> block-stream construct-delegate ;

M: block-stream stream-close drop ;
