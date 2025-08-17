! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

USING: accessors assocs combinators destructors formatting
html.streams io io.styles kernel math sequences splitting
strings ;

IN: io.streams.farkup

TUPLE: farkup-writer < disposable data ;

INSTANCE: farkup-writer output-stream

<PRIVATE

: new-farkup-writer ( class -- farkup-writer )
    new-disposable V{ } clone >>data ; inline

TUPLE: farkup-sub-stream < farkup-writer style parent ;

: new-farkup-sub-stream ( style stream class -- stream )
    new-farkup-writer
        swap >>parent
        swap >>style ; inline

: end-sub-stream ( substream -- string style stream )
    [ data>> "" concat-as ] [ style>> ] [ parent>> ] tri ;

: emit-farkup ( stream quot -- )
    dip data>> push ; inline

: object-link-tag ( str style -- str' )
    presented of [
        url-of [
            swap [ "|" prepend ] [ f ] if* "[[%s%s]]" sprintf
        ] when*
    ] when* ;

: href-link-tag ( str' style -- str' )
    href of [ swap "[[%s|%s]]" sprintf ] when* ;

: span-tag ( str style -- str' )
    {
        [ font-name of "monospace" = [ "%" dup surround ] when ]
        [ font-style of italic = [ "_" dup surround ] when ]
        [ font-style of bold = [ "*" dup surround ] when ]
    } cleave ;

: img-tag ( str style -- str' )
    image-style of [ nip "[[image:%s]]" sprintf ] when* ;

: format-farkup-span ( string style stream -- )
    [
        {
            [ span-tag ]
            [ href-link-tag ]
            [ object-link-tag ]
            [ img-tag ]
        } cleave
    ] emit-farkup ;

TUPLE: farkup-span-stream < farkup-sub-stream ;

M: farkup-span-stream dispose*
    end-sub-stream format-farkup-span ;

: div-tag ( str style -- str' )
    {
        [
            font-name of "monospace" =
            [ "\n\n" "\n" replace "[{" "}]" surround ] when
        ]
        [
            font-size of {
                { [ dup not ] [ drop ] }
                { [ dup 18 >= ] [ drop "= " " =" surround ] }
                { [ dup 16 >= ] [ drop "== " " ==" surround ] }
                { [ dup 14 >= ] [ drop "=== " " ===" surround ] }
                [ drop ]
            } cond
        ]
    } cleave ;

: format-farkup-div ( str style stream -- )
    [ [ div-tag ] [ object-link-tag ] bi ] emit-farkup ;

TUPLE: farkup-block-stream < farkup-sub-stream ;

M: farkup-block-stream dispose*
    end-sub-stream format-farkup-div ;

PRIVATE>

! Stream protocol
M: farkup-writer stream-flush drop ;

M: farkup-writer stream-write1
    [ 1string ] emit-farkup ;

M: farkup-writer stream-write
    [ ] emit-farkup ;

M: farkup-writer stream-format
    format-farkup-span ;

M: farkup-writer stream-nl
    [ "\n\n" ] emit-farkup ;

M: farkup-writer make-span-stream
    farkup-span-stream new-farkup-sub-stream ;

M: farkup-writer make-block-stream
    farkup-block-stream new-farkup-sub-stream ;

M: farkup-writer make-cell-stream
    farkup-sub-stream new-farkup-sub-stream ;

M: farkup-writer stream-write-table
    nip [
        {
            [ first length 1 + "|" <repetition> " " join "\n" dup surround ]
            [ first length "| - " <repetition> concat "|\n" append ]
            [
                [
                    [ data>> concat { { CHAR: \n CHAR: \s } } substitute ] map
                    " | " join "| " " |" surround
                ] map "\n" join "\n" append
            ]
        } cleave 3append
    ] emit-farkup ;

M: farkup-writer dispose* drop ;

: <farkup-writer> ( -- farkup-writer )
    farkup-writer new-farkup-writer ;

: with-farkup-writer ( quot -- str )
    <farkup-writer> [ swap with-output-stream ] keep data>> "" concat-as ; inline
