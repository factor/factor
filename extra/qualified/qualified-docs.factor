USING: help.markup help.syntax ;
IN: qualified

HELP: QUALIFIED:
{ $syntax "QUALIFIED: vocab" }
{ $description "Similar to " { $link POSTPONE: USE: } " but loads vocabulary with prefix." }
{ $examples { $code
    "QUALIFIED: math\n1 2 math:+ ! ==> 3" } } ;
