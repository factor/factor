! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs kernel namespaces strings
quotations io continuations destructors accessors sequences ;
IN: io.streams.nested

TUPLE: filter-writer stream ;

M: filter-writer stream-format
    stream>> stream-format ;

M: filter-writer stream-write
    stream>> stream-write ;

M: filter-writer stream-write1
    stream>> stream-write1 ;

M: filter-writer make-span-stream
    stream>> make-span-stream ;

M: filter-writer make-block-stream
    stream>> make-block-stream ;

M: filter-writer make-cell-stream
    stream>> make-cell-stream ;

M: filter-writer stream-flush
    stream>> stream-flush ;

M: filter-writer stream-nl
    stream>> stream-nl ;

M: filter-writer stream-write-table
    stream>> stream-write-table ;

M: filter-writer dispose
    stream>> dispose ;

TUPLE: ignore-close-stream < filter-writer ;

M: ignore-close-stream dispose drop ;

C: <ignore-close-stream> ignore-close-stream

TUPLE: style-stream < filter-writer style ;

: do-nested-style ( style style-stream -- style stream )
    [ style>> swap assoc-union ] [ stream>> ] bi ; inline

C: <style-stream> style-stream

M: style-stream stream-format
    do-nested-style stream-format ;

M: style-stream stream-write
    [ style>> ] [ stream>> ] bi stream-format ;

M: style-stream stream-write1
    >r 1string r> stream-write ;

M: style-stream make-span-stream
    do-nested-style make-span-stream ;

M: style-stream make-block-stream
    [ do-nested-style make-block-stream ] [ style>> ] bi
    <style-stream> ;

M: style-stream make-cell-stream
    [ do-nested-style make-cell-stream ] [ style>> ] bi
    <style-stream> ;

M: style-stream stream-write-table
    [ [ [ stream>> ] map ] map ] [ ] [ stream>> ] tri*
    stream-write-table ;
