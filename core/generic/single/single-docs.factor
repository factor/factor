USING: help.markup help.syntax kernel math math.parser ;
IN: generic.single

HELP: no-method
{ $values { "object" object } { "generic" "a generic word" } }
{ $description "Throws a " { $link no-method } " error." }
{ $error-description "Thrown by the " { $snippet "generic" } " word to indicate it does not have a method for the class of " { $snippet "object" } "." } ;

HELP: inconsistent-next-method
{ $error-description "Thrown by " { $link POSTPONE: call-next-method } " if the values on the stack are not compatible with the current method." }
{ $examples
    "The following code throws this error:"
    { $code
        "GENERIC: error-test ( object -- )"
        ""
        "M: string error-test print ;"
        ""
        "M: integer error-test number>string call-next-method ;"
        ""
        "123 error-test"
    }
    "This results in the method on " { $link integer } " being called, which then passes a string to " { $link POSTPONE: call-next-method } ". However, this fails because the string is not compatible with the current method."
    $nl
    "This usually indicates programmer error; if the intention above was to call the string method on the result of " { $link number>string } ", the code should be rewritten as follows:"
    { $code "M: integer error-test number>string error-test ;" }
} ;
