USING: help.markup help.syntax io.streams.plain io strings
hashtables kernel quotations colors assocs ;
IN: io.styles

HELP: stream-format
{ $values { "str" string } { "style" assoc } { "stream" "an output stream" } }
{ $contract "Writes formatted text to the stream. If the stream does buffering, output may not be performed immediately; use " { $link stream-flush } " to force output."
$nl
"The " { $snippet "style" } " assoc holds character style information. See " { $link "character-styles" } "." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link format } "; see " { $link "stdio" } "." }
$io-error ;

HELP: make-block-stream
{ $values { "style" assoc } { "stream" "an output stream" } { "stream'" "an output stream" } }
{ $contract "Creates an output stream which wraps " { $snippet "stream" } " and adds " { $snippet "style" } " on calls to " { $link stream-write } " and " { $link stream-format } "."
$nl
"Unlike " { $link make-span-stream } ", this creates a new paragraph block in the output."
$nl
"The " { $snippet "style" } " hashtable holds paragraph style information. See " { $link "paragraph-styles" } "." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link with-nesting } "; see " { $link "stdio" } "." }
$io-error ;

HELP: stream-write-table
{ $values { "table-cells" "a sequence of sequences of table cells" } { "style" assoc } { "stream" "an output stream" } }
{ $contract "Prints a table of cells produced by " { $link with-cell } "."
$nl
"The " { $snippet "style" } " hashtable holds table style information. See " { $link "table-styles" } "." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link tabular-output } "; see " { $link "stdio" } "." }
$io-error ;

HELP: make-cell-stream
{ $values { "style" assoc } { "stream" "an output stream" } { "stream'" object } }
{ $contract "Creates an output stream which writes to a table cell object." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link with-cell } "; see " { $link "stdio" } "." }
$io-error ;

HELP: make-span-stream
{ $values { "style" assoc } { "stream" "an output stream" } { "stream'" "an output stream" } }
{ $contract "Creates an output stream which wraps " { $snippet "stream" } " and adds " { $snippet "style" } " on calls to " { $link stream-write } " and " { $link stream-format } "."
$nl
"Unlike " { $link make-block-stream } ", the stream output is inline, and not nested in a paragraph block." }
{ $notes "Most code only works on one stream at a time and should instead use " { $link with-style } "; see " { $link "stdio" } "." }
$io-error ;

HELP: format
{ $values { "str" string } { "style" assoc } }
{ $description "Writes formatted text to " { $link output-stream } ". If the stream does buffering, output may not be performed immediately; use " { $link flush } " to force output." }
{ $notes "Details are in the documentation for " { $link stream-format } "." }
$io-error ;

HELP: with-nesting
{ $values { "style" assoc } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope with " { $link output-stream } " rebound to a nested paragraph stream, with formatting information applied." }
{ $notes "Details are in the documentation for " { $link make-block-stream } "." }
$io-error ;

HELP: tabular-output
{ $values { "style" assoc } { "quot" quotation } }
{ $description "Calls a quotation which emits a series of equal-length table rows using " { $link with-row } ". The results are laid out in a tabular fashion on " { $link output-stream } "."
$nl
"The " { $snippet "style" } " hashtable holds table style information. See " { $link "table-styles" } "." }
{ $examples
    { $code
        "USING: io.styles prettyprint sequences ;"
        "{ { 1 2 } { 3 4 } }"
        "H{ { table-gap { 10 10 } } } ["
        "    [ [ [ [ . ] with-cell ] each ] with-row ] each"
        "] tabular-output"
    }
}
$io-error ;

HELP: with-row
{ $values { "quot" quotation } }
{ $description "Calls a quotation which emits a series of table cells using " { $link with-cell } ". This word can only be called inside the quotation given to " { $link tabular-output } "." }
$io-error ;

HELP: with-cell
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new scope with " { $link output-stream } " rebound. Output performed by the quotation is displayed in a table cell. This word can only be called inside the quotation given to " { $link with-row } "." }
$io-error ;

HELP: write-cell
{ $values { "str" string } }
{ $description "Outputs a table cell containing a single string. This word can only be called inside the quotation given to " { $link with-row } "." }
$io-error ;

HELP: with-style
{ $values { "style" assoc } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope where calls to " { $link write } ", " { $link format } " and other stream output words automatically inherit style settings from " { $snippet "style" } "." }
{ $notes "Details are in the documentation for " { $link make-span-stream } "." }
$io-error ;

ARTICLE: "formatted-stream-protocol" "Formatted stream protocol"
"The " { $vocab-link "io.styles" } " vocabulary defines a protocol for output streams that support rich text."
{ $subsections
    stream-format
    make-span-stream
    make-block-stream
    make-cell-stream
    stream-write-table
} ;

ARTICLE: "formatted-stdout" "Formatted output on the default stream"
"The below words perform formatted output on " { $link output-stream } "."
$nl
"Formatted output:"
{ $subsections
    format
    with-style
    with-nesting
}
"Tabular output:"
{ $subsections
    tabular-output
    with-row
    with-cell
    write-cell
} ;

HELP: href
{ $description "Character style. A URL string that the text links to." } ;

HELP: image-style
{ $description "Character style. A pathname string for an image file to display in place of the printed text. If this style is specified, the printed text serves the same role as the " { $snippet "alt" } " attribute of an HTML " { $snippet "img" } " tag -- the text is only displayed if the output medium does not support images." } ;

ARTICLE: "character-styles" "Character styles"
"Character styles for " { $link stream-format } " and " { $link with-style } ":"
{ $subsections
    foreground
    background
    font-name
    font-size
    font-style
}
"Special styles:"
{ $subsections
    href
    image-style
}
{ $see-also "presentations" } ;

ARTICLE: "paragraph-styles" "Paragraph styles"
"Paragraph styles for " { $link with-nesting } ":"
{ $subsections
    page-color
    border-color
    inset
    wrap-margin
    presented
} ;

ARTICLE: "table-styles" "Table styles"
"Table styles for " { $link tabular-output } ":"
{ $subsections
    table-gap
    table-border
} ;

HELP: write-object
{ $values { "str" string } { "obj" object } }
{ $description "Writes a string to " { $link output-stream } ", associating it with the object. If formatted output is supported, the string will become a clickable presentation of the object, otherwise this word behaves like a call to " { $link write } "." }
$io-error ;

ARTICLE: "presentations" "Presentations"
"A special style for " { $link format } " and " { $link with-nesting } ":"
{ $subsections presented }
"The " { $link presented } " style can be used to emit clickable objects. A utility word for outputting this style:"
{ $subsections write-object } ;

ARTICLE: "styles" "Text styles"
"The " { $link stream-format } ", " { $link with-style } ", " { $link with-nesting } " and " { $link tabular-output } " words take a hashtable of style attributes. Output stream implementations are free to ignore style information."
$nl
"Style hashtables are keyed by symbols from the " { $vocab-link "io.styles" } " vocabulary."
{ $subsections
    "character-styles"
    "paragraph-styles"
    "table-styles"
    "presentations"
} ;

ARTICLE: "io.styles" "Formatted output"
"The " { $vocab-link "io.styles" } " vocabulary defines a protocol for formatted output. This is used by the prettyprinter, help system, and various developer tools. Implementations include " { $vocab-link "ui.gadgets.panes" } ", " { $vocab-link "io.streams.html" } ", and " { $vocab-link "io.streams.plain" } "."
{ $subsections
    "formatted-stream-protocol"
    "formatted-stdout"
    "styles"
} ;

ABOUT: "io.styles"

HELP: plain
{ $description "A value for the " { $link font-style } " character style denoting plain text." } ;

HELP: bold
{ $description "A value for the " { $link font-style } " character style denoting boldface text." } ;

HELP: italic
{ $description "A value for the " { $link font-style } " character style denoting italicized text." } ;

HELP: bold-italic
{ $description "A value for the " { $link font-style } " character style denoting boldface italicized text." } ;

HELP: foreground
{ $description "Character style. An instance of " { $link color } ". See " { $link "colors" } "." }
{ $examples
    { $code
        "USING: colors.gray io.styles hashtables sequences kernel math ;"
        "10 <iota> ["
        "    \"Hello world\\n\""
        "    swap 10 / 1 <gray> foreground associate format"
        "] each"
    }
} ;

HELP: background
{ $description "Character style. An instance of " { $link color } ". See " { $link "colors" } "." }
{ $examples
    { $code
        "USING: colors hashtables io io.styles kernel math sequences ;"
        "10 <iota> ["
        "    \"Hello world\\n\""
        "    swap 10 / 1 over - over 1 <rgba>"
        "    background associate format"
        "] each"
    }
} ;

HELP: font-name
{ $description "Character style. Font family named by a string." }
{ $examples
    "This example outputs some different font sizes:"
    { $code
        "USING: hashtables io io.styles kernel sequences ;"
        "{ \"monospace\" \"serif\" \"sans-serif\" }"
        "[ dup font-name associate format nl ] each"
    }
} ;

HELP: font-size
{ $description "Character style. Font size, an integer." }
{ $examples
    "This example outputs some different font sizes:"
    { $code
        "USING: hashtables io io.styles kernel sequences ;"
        "{ 12 18 24 72 }"
        "[ \"Bigger\" swap font-size associate format nl ] each"
    }
} ;

HELP: font-style
{ $description "Character style. Font style, one of " { $link plain } ", " { $link bold } ", " { $link italic } ", or " { $link bold-italic } "." }
{ $examples
    "This example outputs text in all three styles:"
    { $code
        "USING: accessors hashtables io io.styles kernel sequences ;"
        "{ plain bold italic bold-italic }"
        "[ [ name>> ] keep font-style associate format nl ] each"
    }
} ;

HELP: presented
{ $description "Character and paragraph style. An object associated with the text. In the Factor UI, this is shown as a clickable presentation of the object; left-clicking invokes a default command, and right-clicking shows a menu of commands." } ;

HELP: page-color
{ $description "Paragraph style. An instance of " { $link color } ". See " { $link "colors" } "." }
{ $examples
    { $code
        "USING: colors io io.styles ;"
        "H{ { page-color T{ rgba f 1 0.8 0.5 1 } } }"
        "[ \"A background\" write ] with-nesting nl"
    }
} ;

HELP: border-color
{ $description "Paragraph style. An instance of " { $link color } ". See " { $link "colors" } "." }
{ $examples
    { $code
        "USING: colors io io.styles ;"
        "H{ { border-color T{ rgba f 1 0 0 1 } } }"
        "[ \"A border\" write ] with-nesting nl"
    }
} ;

HELP: inset
{ $description "Paragraph style. A pair of integers representing the number of pixels that the content should be inset from the border. The first number is the horizontal inset, and the second is the vertical inset." }
{ $examples
    { $code
        "USING: io io.styles ;"
        "H{ { inset { 10 10 } } }"
        "[ \"Some inset text\" write ] with-nesting nl"
    }
} ;

HELP: wrap-margin
{ $description "Paragraph style. Pixels between left margin and right margin where text is wrapped, an integer." } ;

{ wrap-margin bl } related-words

HELP: table-gap
{ $description "Table style. Horizontal and vertical gap between table cells, denoted by a pair of integers." } ;

{ table-gap table-border stream-write-table tabular-output } related-words

HELP: table-border
{ $description "Table style. An instance of " { $link color } ". See " { $link "colors" } "." } ;

HELP: input
{ $class-description "Class of input text presentations. Instances can be used passed to " { $link write-object } " to output a clickable piece of input. Input text presentations are created by calling " { $link <input> } "." }
{ $examples
    "This presentation class is used for the code examples you see in the online help:"
    { $code
        "USING: io io.styles kernel ;"
        "\"2 3 + .\" dup <input> write-object nl"
    }
} ;

HELP: <input>
{ $values { "string" string } { "input" input } }
{ $description "Creates a new " { $link input } "." } ;

HELP: standard-table-style
{ $values { "value" hashtable } }
{ $description "Outputs a table style where cells are separated by 5-pixel gaps and framed by a light gray border. This style can be passed to " { $link tabular-output } "." } ;

ARTICLE: "io.streams.plain" "Plain writer streams"
"Plain writer streams wrap an underlying stream and provide a default implementation of "
{ $link stream-nl } ", "
{ $link stream-format } ", "
{ $link make-span-stream } ", "
{ $link make-block-stream } " and "
{ $link make-cell-stream } "."
{ $subsections plain-writer } ;
