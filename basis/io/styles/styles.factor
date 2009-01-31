! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables io io.streams.plain io.streams.string
colors summary make accessors splitting math.order
kernel namespaces assocs destructors strings sequences ;
IN: io.styles

GENERIC: stream-format ( str style stream -- )
GENERIC: make-span-stream ( style stream -- stream' )
GENERIC: make-block-stream ( style stream -- stream' )
GENERIC: make-cell-stream ( style stream -- stream' )
GENERIC: stream-write-table ( table-cells style stream -- )

: format ( str style -- ) output-stream get stream-format ;

: tabular-output ( style quot -- )
    swap [ { } make ] dip output-stream get stream-write-table ; inline

: with-row ( quot -- )
    { } make , ; inline

: with-cell ( quot -- )
    H{ } output-stream get make-cell-stream
    [ swap with-output-stream ] keep , ; inline

: write-cell ( str -- )
    [ write ] with-cell ; inline

: with-style ( style quot -- )
    swap dup assoc-empty? [
        drop call
    ] [
        output-stream get make-span-stream swap with-output-stream
    ] if ; inline

: with-nesting ( style quot -- )
    [ output-stream get make-block-stream ] dip
    with-output-stream ; inline

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
    [ 1string ] dip stream-write ;

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

M: plain-writer stream-format
    nip stream-write ;

M: plain-writer make-span-stream
    swap <style-stream> <ignore-close-stream> ;

M: plain-writer make-block-stream
    nip <ignore-close-stream> ;

: format-column ( seq ? -- seq )
    [
        [ 0 [ length max ] reduce ] keep
        swap [ CHAR: \s pad-tail ] curry map
    ] unless ;

: map-last ( seq quot -- seq )
    [ dup length <reversed> ] dip [ 0 = ] prepose 2map ; inline

: format-table ( table -- seq )
    flip [ format-column ] map-last
    flip [ " " join ] map ;

M: plain-writer stream-write-table
    [ drop format-table [ print ] each ] with-output-stream* ;

M: plain-writer make-cell-stream 2drop <string-writer> ;

! Font styles
SYMBOL: plain
SYMBOL: bold
SYMBOL: italic
SYMBOL: bold-italic

! Character styles
SYMBOL: foreground
SYMBOL: background
SYMBOL: font
SYMBOL: font-size
SYMBOL: font-style

! Presentation
SYMBOL: presented
SYMBOL: presented-path
SYMBOL: presented-printer

SYMBOL: href

! Paragraph styles
SYMBOL: page-color
SYMBOL: border-color
SYMBOL: border-width
SYMBOL: wrap-margin

! Table styles
SYMBOL: table-gap
SYMBOL: table-border

: standard-table-style ( -- style )
    H{
        { table-gap { 5 5 } }
        { table-border T{ rgba f 0.8 0.8 0.8 1.0 } }
    } ;

! Input history
TUPLE: input string ;

C: <input> input

M: input summary
    [
        "Input: " %
        string>> "\n" split1 swap %
        "..." "" ? %
    ] "" make ;

: write-object ( str obj -- ) presented associate format ;
