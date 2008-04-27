USING: help.markup help.syntax ;
IN: symbols

HELP: SYMBOLS:
{ $syntax "SYMBOLS: words... ;" }
{ $values { "words" "a sequence of new words to define" } }
{ $description "Creates a new word for every token until the ';'." }
{ $examples { $example "USING: prettyprint symbols ;" "IN: scratchpad" "SYMBOLS: foo bar baz ;\nfoo . bar . baz ." "foo\nbar\nbaz" } }
{ $see-also POSTPONE: SYMBOL: } ;
