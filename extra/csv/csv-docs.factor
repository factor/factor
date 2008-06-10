USING: help.syntax help.markup kernel prettyprint sequences ;
IN: csv

HELP: csv
{ $values { "stream" "a stream" }
          { "rows" "an array of arrays of fields" } } 
{ $description "parses a csv stream into an array of row arrays"
} ;

HELP: csv-row
{ $values { "stream" "a stream" }
          { "row" "an array of fields" } } 
{ $description "parses a row from a csv stream"
} ;


HELP: with-delimiter
{ $values { "char" "field delimiter (e.g. CHAR: \t)" }
          { "quot" "a quotation" } }
{ $description "Sets the field delimiter for csv or csv-row words "
} ;
