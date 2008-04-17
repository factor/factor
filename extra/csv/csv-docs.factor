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
