USING: help.markup help.syntax sequences splitting strings ;
IN: splitting.extras

HELP: split*-when
{ $values { "seq" "a sequence" } { "quot" { $quotation "( ... elt -- ... ? )" } } { "pieces" "a new array" } }
{ $description "A variant of " { $link split-when } " that includes the elements along which the sequence was split." }
{ $examples { $example "USING: ascii kernel prettyprint splitting.extras ;" "\"hello,world-how.are:you\" [ letter? not ] split*-when ." "{ \"hello\" \",\" \"world\" \"-\" \"how\" \".\" \"are\" \":\" \"you\" }" } } ;

HELP: split*
{ $values { "seq" "a sequence" } { "separators" "a sequence" } { "pieces" "a new array" } }
{ $description "A variant of " { $link split } " that includes the elements along which the sequence was split." }
{ $examples { $example "USING: prettyprint splitting.extras ;" "\"hello world-how are you?\" \" -\" split* ." "{ \"hello\" \" \" \"world\" \"-\" \"how\" \" \" \"are\" \" \" \"you?\" }" } } ;

HELP: split-find
{ $values { "seq" "a sequence" } { "quot" { $quotation "( seq -- i )" } } { "pieces" "a new array" } }
{ $description "Splits a sequence into slices using the provided quotation to find split points." } ;
