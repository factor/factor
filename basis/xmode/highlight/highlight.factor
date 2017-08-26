! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs colors.hex io io.encodings.utf8 io.files
io.pathnames io.streams.string io.styles kernel locals see
sequences splitting strings vocabs vocabs.loader words
xmode.catalog xmode.marker ;

IN: xmode.highlight

<PRIVATE

CONSTANT: STYLES H{
    { "NULL"     H{ { foreground hexcolor: 000000 } } }
    { "COMMENT1" H{ { foreground hexcolor: cc0000 } } }
    { "COMMENT2" H{ { foreground hexcolor: ff8400 } } }
    { "COMMENT3" H{ { foreground hexcolor: 6600cc } } }
    { "COMMENT4" H{ { foreground hexcolor: cc6600 } } }
    { "DIGIT"    H{ { foreground hexcolor: ff0000 } } }
    { "FUNCTION" H{ { foreground hexcolor: 9966ff } } }
    { "INVALID"  H{ { background hexcolor: ffffcc }
                    { foreground hexcolor: ff0066 } } }
    { "KEYWORD1" H{ { foreground hexcolor: 006699 }
                    { font-style bold } } }
    { "KEYWORD2" H{ { foreground hexcolor: 009966 }
                    { font-style bold } } }
    { "KEYWORD3" H{ { foreground hexcolor: 0099ff }
                    { font-style bold } } }
    { "KEYWORD4" H{ { foreground hexcolor: 66ccff }
                    { font-style bold } } }
    { "LABEL"    H{ { foreground hexcolor: 02b902 } } }
    { "LITERAL1" H{ { foreground hexcolor: ff00cc } } }
    { "LITERAL2" H{ { foreground hexcolor: cc00cc } } }
    { "LITERAL3" H{ { foreground hexcolor: 9900cc } } }
    { "LITERAL4" H{ { foreground hexcolor: 6600cc } } }
    { "MARKUP"   H{ { foreground hexcolor: 0000ff } } }
    { "OPERATOR" H{ { foreground hexcolor: 000000 }
                    { font-style bold } } }
}

CONSTANT: BASE H{
    { font-name "monospace" }
}

PRIVATE>

: highlight-tokens ( tokens -- )
    [
        [ str>> ] [ id>> ] bi
        [ name>> STYLES at BASE assoc-union ] [ BASE ] if*
        format
    ] each nl ;

: highlight-lines ( lines mode -- )
    [ f ] 2dip load-mode [
        tokenize-line highlight-tokens
    ] curry each drop ;

GENERIC: highlight. ( obj -- )

M:: string highlight. ( path -- )
    path utf8 file-lines [
        path over first find-mode highlight-lines
    ] unless-empty ;

M: pathname highlight.
    string>> highlight. ;

M: vocab highlight.
    vocab-source-path highlight. ;

M: word highlight.
    [ see ] with-string-writer string-lines
    "factor" highlight-lines ;
