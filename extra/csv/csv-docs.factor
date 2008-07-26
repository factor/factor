USING: help.syntax help.markup kernel prettyprint sequences ;
IN: csv

HELP: csv
{ $values { "stream" "an input stream" }
          { "rows" "an array of arrays of fields" } } 
{ $description "parses a csv stream into an array of row arrays"
} ;

HELP: csv-row
{ $values { "stream" "an input stream" }
          { "row" "an array of fields" } } 
{ $description "parses a row from a csv stream"
} ;

HELP: write-csv
{ $values { "rows" "an sequence of sequences of strings" }
          { "stream" "an output stream" } } 
{ $description "writes csv to the output stream, escaping where necessary"
} ;


HELP: with-delimiter
{ $values { "char" "field delimiter (e.g. CHAR: \t)" }
          { "quot" "a quotation" } }
{ $description "Sets the field delimiter for csv or csv-row words "
} ;

