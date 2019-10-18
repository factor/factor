USING: help.syntax help.markup kernel prettyprint sequences
io.pathnames ;
IN: csv

HELP: csv
{ $values { "stream" "an input stream" }
          { "rows" "an array of arrays of fields" } } 
{ $description "Parses a csv stream into an array of row arrays." } ;

HELP: file>csv
{ $values
    { "path" pathname } { "encoding" "an encoding descriptor" }
    { "csv" "csv" }
}
{ $description "Opens a file and parses it into a sequence of comma-separated-value fields." } ;

HELP: csv>file
{ $values
    { "rows" "a sequence of sequences of strings" }
    { "path" pathname } { "encoding" "an encoding descriptor" }
}
{ $description "Writes a comma-separated-value structure to a file." } ;

HELP: csv-row
{ $values { "stream" "an input stream" }
          { "row" "an array of fields" } } 
{ $description "parses a row from a csv stream" } ;

HELP: write-csv
{ $values { "rows" "a sequence of sequences of strings" }
          { "stream" "an output stream" } } 
{ $description "Writes a sequence of sequences of comma-separated-values to the output stream, escaping where necessary." } ;

HELP: with-delimiter
{ $values { "ch" "field delimiter (e.g. CHAR: \t)" }
          { "quot" "a quotation" } }
{ $description "Sets the field delimiter for csv or csv-row words." } ;

ARTICLE: "csv" "Comma-separated-values parsing and writing"
"The " { $vocab-link "csv" } " vocabulary can read and write CSV (comma-separated-value) files." $nl
"Reading a csv file:"
{ $subsections file>csv }
"Writing a csv file:"
{ $subsections csv>file }
"Changing the delimiter from a comma:"
{ $subsections with-delimiter }
"Reading from a stream:"
{ $subsections csv }
"Writing to a stream:"
{ $subsections write-csv } ;

ABOUT: "csv"
