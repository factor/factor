IN: classes.tuple.parser
USING: strings help.markup help.syntax ;

HELP: invalid-slot-name
{ $values { "name" string } }
{ $description "Throws an " { $link invalid-slot-name } " error." }
{ $error-description "Thrown by " { $link POSTPONE: TUPLE: } " and " { $link POSTPONE: ERROR: } " if a suspect token appears as a slot name." }
{ $notes "The suspect tokens are chosen so that the following code raises this parse error, instead of silently creating a tuple with garbage slots:"
    { $code
        "TUPLE: my-mistaken-tuple slot-a slot-b"
        ""
        ": some-word ( a b c -- ) ... ;"
    }
} ;
