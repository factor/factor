USING: help.markup help.syntax io.streams.plain io strings
hashtables ;
IN: io.styles

ARTICLE: "character-styles" "Character styles"
"Character styles for " { $link stream-format } " and " { $link with-style } ":"
{ $subsection foreground }
{ $subsection background }
{ $subsection font }
{ $subsection font-size }
{ $subsection font-style }
{ $subsection presented } ;

ARTICLE: "paragraph-styles" "Paragraph styles"
"Paragraph styles for " { $link with-nesting } ":"
{ $subsection page-color }
{ $subsection border-color }
{ $subsection border-width }
{ $subsection wrap-margin }
{ $subsection presented } ;

ARTICLE: "table-styles" "Table styles"
"Table styles for " { $link tabular-output } ":"
{ $subsection table-gap }
{ $subsection table-border } ;

ARTICLE: "presentations" "Presentations"
"The " { $link presented } " style can be used to emit clickable objects. The " { $link write-object } " word should be used instead of setting this directly." ;

ARTICLE: "styles" "Formatted output"
"The " { $link stream-format } ", " { $link with-style } ", " { $link with-nesting } " and " { $link tabular-output } " words take a hashtable of style attributes. Output stream implementations are free to ignore style information."
$nl
"Style hashtables are keyed by symbols from the " { $vocab-link "styles" } " vocabulary."
{ $subsection "character-styles" }
{ $subsection "paragraph-styles" }
{ $subsection "table-styles" }
{ $subsection "presentations" } ;

ABOUT: "styles"

HELP: plain
{ $description "A value for the " { $link font-style } " character style denoting plain text." } ;

HELP: bold
{ $description "A value for the " { $link font-style } " character style denoting boldface text." } ;

HELP: italic
{ $description "A value for the " { $link font-style } " character style denoting italicized text." } ;

HELP: bold-italic
{ $description "A value for the " { $link font-style } " character style denoting boldface italicized text." } ;

HELP: foreground
{ $description "Character style. Text color, denoted by a sequence of four numbers between 0 and 1 (red, green, blue and alpha)." } 
{ $examples
    { $code
        "10 ["
            "    \"Hello world\" swap"
            "    { 0.1 0.1 0.2 1 } n*v { 1 1 1 1 } vmin"
            "    foreground associate format nl"
        "] each"
    }
} ;

HELP: background
{ $description "Character style. Background color, denoted by a sequence of four numbers between 0 and 1 (red, green, blue and alpha)." }
{ $examples
    { $code
        "10 ["
            "    \"Hello world\" swap"
            "    { 0.1 0.4 0.1 } n*v { 1 1 1 } vmin { 1 } append"
            "    background associate format nl"
        "] each"
    }
} ;

HELP: font
{ $description "Character style. Font family named by a string." }
{ $examples
    "This example outputs some different font sizes:"
    { $code "{ \"monospace\" \"serif\" \"sans-serif\" }\n[ dup font associate format nl ] each" }
} ;

HELP: font-size
{ $description "Character style. Font size, an integer." }
{ $examples
    "This example outputs some different font sizes:"
    { $code "{ 12 18 24 72 }"
        "[ \"Bigger\" swap font-size associate format nl ] each"
    }
}  ;

HELP: font-style
{ $description "Character style. Font style, one of " { $link plain } ", " { $link bold } ", " { $link italic } ", or " { $link bold-italic } "." }
{ $examples
    "This example outputs text in all three styles:"
    { $code "{ plain bold italic bold-italic }\n[ [ word-name ] keep font-style associate format nl ] each" }
}  ;

HELP: presented
{ $description "Character and paragraph style. An object associated with the text. In the Factor UI, this is shown as a clickable presentation of the object; left-clicking invokes a default command, and right-clicking shows a menu of commands." } ;

HELP: presented-path
{ $description "Character and paragraph style. An editable object associated with the text. In the Factor UI, this is shown as a clickable presentation of the object path together with an expander button which displays an object editor; left-clicking invokes a default command, and right-clicking shows a menu of commands." } ;

HELP: presented-printer
{ $description "Character and paragraph style. A quotation with stack effect " { $snippet "( obj -- )" } " which is applied to the value at the " { $link presented-path } " if the presentation needs to be re-displayed after the object has been edited." } ;

HELP: highlight
{ $description "Character style. Used to mark up text on streams that otherwise do not support different colors or font styles." }
{ $examples "Instances of " { $link plain-writer } " uppercases highlighted text." } ;

HELP: page-color
{ $description "Paragraph style. Background color of the paragraph block, denoted by a sequence of four numbers between 0 and 1 (red, green, blue and alpha)." } 
{ $examples
    { $code "H{ { page-color { 1 0.8 0.5 1 } } }\n[ \"A background\" write ] with-nesting nl" }
} ;

HELP: border-color
{ $description "Paragraph style. Border color of the paragraph block, denoted by a sequence of four numbers between 0 and 1 (red, green, blue and alpha)." } 
{ $examples
    { $code "H{ { border-color { 1 0 0 1 } } }\n[ \"A border\" write ] with-nesting nl" }
} ;

HELP: border-width
{ $description "Paragraph style. Pixels between edge of text and border color, an integer." } 
{ $examples
    { $code "H{ { border-width 10 } }\n[ \"Some inset text\" write ] with-nesting nl" }
} ;

HELP: wrap-margin
{ $description "Paragraph style. Pixels between left margin and right margin where text is wrapped, an integer." } ;

{ wrap-margin bl } related-words

HELP: table-gap
{ $description "Table style. Horizontal and vertical gap between table cells, denoted by a pair of integers." } ;

{ table-gap table-border stream-write-table tabular-output } related-words

HELP: table-border
{ $description "Table style. Color of the border drawn between cells, denoted by a sequence of four numbers between 0 and 1 (red, green, blue and alpha)." } ;

HELP: input
{ $class-description "Class of input text presentations. Instances can be used passed to " { $link write-object } " to output a clickable piece of input. Input text presentations are created by calling " { $link <input> } "." }
{ $examples
    "This presentation class is used for the code examples you see in the online help:"
    { $code "\"2 3 + .\" dup <input> write-object nl" }
} ;

HELP: <input> ( string -- input )
{ $values { "string" string } { "input" input } }
{ $description "Creates a new " { $link input } "." } ;

HELP: standard-table-style
{ $values { "style" hashtable } }
{ $description "Outputs a table style where cells are separated by 5-pixel gaps and framed by a light gray border. This style can be passed to " { $link tabular-output } "." } ;
