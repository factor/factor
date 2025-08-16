! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

USING: accessors assocs combinators destructors formatting
html.streams io io.styles kernel math sequences splitting
strings ;

IN: markdown.streams

TUPLE: markdown-writer < disposable data ;

INSTANCE: markdown-writer output-stream

<PRIVATE

: new-markdown-writer ( class -- markdown-writer )
    new-disposable V{ } clone >>data ; inline

TUPLE: markdown-sub-stream < markdown-writer style parent ;

: new-markdown-sub-stream ( style stream class -- stream )
    new-markdown-writer
        swap >>parent
        swap >>style ; inline

: end-sub-stream ( substream -- string style stream )
    [ data>> "" concat-as ] [ style>> ] [ parent>> ] tri ;

: emit-markdown ( stream quot -- )
    dip data>> push ; inline

: object-link-tag ( str style -- str' )
    presented of [ url-of [ "[%s](%s)" sprintf ] when* ] when* ;

: href-link-tag ( str' style -- str' )
    href of [ "[%s](%s)" sprintf ] when* ;

: span-tag ( str style -- str' )
    {
        [ font-name of "monospace" = [ "`" dup surround ] when ]
        [ font-style of italic = [ "*" dup surround ] when ]
        [ font-style of bold = [ "**" dup surround ] when ]
    } cleave ;

: img-tag ( str style -- str' )
    image-style of [ nip "![](%s)" sprintf ] when* ;

: format-markdown-span ( string style stream -- )
    [
        {
            [ span-tag ]
            [ href-link-tag ]
            [ object-link-tag ]
            [ img-tag ]
        } cleave
    ] emit-markdown ;

TUPLE: markdown-span-stream < markdown-sub-stream ;

M: markdown-span-stream dispose*
    end-sub-stream format-markdown-span ;

: div-tag ( str style -- str' )
    {
        [
            font-name of "monospace" =
            [ "\n\n" "\n" replace "```\n" "\n```" surround ] when
        ]
        [
            font-size of {
                { [ dup not ] [ drop ] }
                { [ dup 18 >= ] [ drop "# " prepend ] }
                { [ dup 16 >= ] [ drop "## " prepend ] }
                { [ dup 14 >= ] [ drop "### " prepend ] }
                [ drop ]
            } cond
        ]
    } cleave ;

: format-markdown-div ( str style stream -- )
    [ [ div-tag ] [ object-link-tag ] bi ] emit-markdown ;

TUPLE: markdown-block-stream < markdown-sub-stream ;

M: markdown-block-stream dispose*
    end-sub-stream format-markdown-div ;

PRIVATE>

! Stream protocol
M: markdown-writer stream-flush drop ;

M: markdown-writer stream-write1
    [ 1string ] emit-markdown ;

M: markdown-writer stream-write
    [ ] emit-markdown ;

M: markdown-writer stream-format
    format-markdown-span ;

M: markdown-writer stream-nl
    [ "\n\n" ] emit-markdown ;

M: markdown-writer make-span-stream
    markdown-span-stream new-markdown-sub-stream ;

M: markdown-writer make-block-stream
    markdown-block-stream new-markdown-sub-stream ;

M: markdown-writer make-cell-stream
    markdown-sub-stream new-markdown-sub-stream ;

M: markdown-writer stream-write-table
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
    ] emit-markdown ;

M: markdown-writer dispose* drop ;

: <markdown-writer> ( -- markdown-writer )
    markdown-writer new-markdown-writer ;

: with-markdown-writer ( quot -- str )
    <markdown-writer> [ swap with-output-stream ] keep data>> "" concat-as ; inline
