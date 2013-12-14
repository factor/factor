USING: help.markup help.syntax sequences splitting strings ;

IN: grouping.extras

HELP: group-by
{ $values { "seq" "a sequence" } { "quot" { $quotation "( ... elt -- ... key )" } } { "groups" "a new assoc" } }
{ $description "Groups the elements by the key received by applying quot to each element in the sequence." }
{ $examples
  { $example
    "USING: grouping.extras unicode.data ;"
    "\"THis String Has  CasE!\" [ category ] group-by [ last >string ] map ."
    "{ \"TH\" \"is\" \" \" \"S\" \"tring\" \" \" \"H\" \"as\" \"  \" \"C\" \"as\" \"E\" \"!\" }"
  }
} ;
