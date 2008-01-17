USING: help.markup help.syntax ;
IN: tuple-syntax

HELP: TUPLE{
{ $syntax "TUPLE{ class slot-name: value... }" }
{ $values { "class" "a tuple class word" } { "slot-name" "the name of a slot, without the tuple class name" } { "value" "the value for a slot" } }
{ $description "Marks the beginning of a literal tuple. Literal tuples are terminated by " { $link POSTPONE: } } ". The class word must be specified. Slots which aren't specified are set to f. If slot names are duplicated, the latest one is used." }
{ $see-also POSTPONE: T{ } ;

IN: tuple-syntax
ABOUT: POSTPONE: TUPLE{
