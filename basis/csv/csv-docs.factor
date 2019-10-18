USING: help.markup help.syntax io.pathnames quotations strings ;
IN: csv

HELP: read-row
{ $values { "row" "an array of fields" } }
{ $description "parses a row from a csv stream" } ;

HELP: read-csv
{ $values { "rows" "an array of arrays of fields" } }
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

HELP: string>csv
{ $values
    { "string" string }
    { "csv" "csv" }
}
{ $description "Parses a string into a sequence of comma-separated-value fields." } ;

HELP: csv>string
{ $values
    { "csv" "csv" }
    { "string" string }
}
{ $description "Writes a comma-separated-value structure to a string." } ;

HELP: write-row
{ $values { "row" "an array of fields" } }
{ $description "writes a row to the output stream" } ;

HELP: write-csv
{ $values { "rows" "a sequence of sequences of strings" } }
{ $description "Writes a sequence of sequences of comma-separated-values to the output stream, escaping where necessary." } ;

HELP: with-delimiter
{ $values { "ch" "field delimiter (e.g. CHAR: \\t)" }
          { "quot" quotation } }
{ $description "Sets the field delimiter for read-csv, read-row, write-csv, or write-row words." } ;

ARTICLE: "csv" "Comma-separated-values parsing and writing"
"The " { $vocab-link "csv" } " vocabulary can read and write CSV (comma-separated-value) files." $nl
"Working with CSV files:"
{ $subsections file>csv csv>file }
"Working with CSV strings:"
{ $subsections string>csv csv>string }
"Changing the delimiter from a comma:"
{ $subsections with-delimiter }
"Reading from a stream:"
{ $subsections read-csv read-row }
"Writing to a stream:"
{ $subsections write-csv write-row } ;

ABOUT: "csv"
