USING: help.markup help.syntax sequences ;
IN: columns

HELP: column
{ $class-description "A virtual sequence which presents a fixed column of a matrix represented as a sequence of rows. New instances can be created by calling " { $link <column> } "." } ;

HELP: <column>
{ $values { "seq" sequence } { "col" "a non-negative integer" } { "column" column } }
{ $description "Outputs a new virtual sequence which presents a fixed column of a matrix represented as a sequence of rows." "The " { $snippet "i" } "th element of a column is the " { $snippet "n" } "th element of the " { $snippet "i" } "th element of " { $snippet "seq" } ". Every element of " { $snippet "seq" } " must be a sequence, and all sequences must have equal length." }
{ $examples
    { $example
        "USING: arrays prettyprint columns ;"
        "{ { 1 2 3 } { 4 5 6 } { 7 8 9 } } 0 <column> >array ."
        "{ 1 4 7 }"
    }
}
{ $notes
    "In the same sense that " { $link <reversed> } " is a virtual variant of " { $link reverse } ", " { $link <column> } " is a virtual variant of " { $snippet "swap [ nth ] curry map" } "."
} ;

HELP: <flipped>
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Outputs a new virtual sequence which presents the transpose of " { $snippet "seq" } "." }
{ $notes "This is the virtual sequence equivalent of " { $link flip } "." } ;

ARTICLE: "columns" "Column sequences"
"A " { $emphasis "column" } " presents a column of a matrix represented as a sequence of rows:"
{ $subsections
    column
    <column>
}
"A utility word:"
{ $subsections <flipped> } ;

ABOUT: "columns"
