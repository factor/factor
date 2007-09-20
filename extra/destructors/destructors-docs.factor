USING: help.markup help.syntax kernel destructors ;
IN: destructors

HELP: add-destructor
{ $values { "obj" "an object" }
          { "quot" "a quotation" }
          { "always?" "always cleanup?" }
} { $description "Adds a destructor to be invoked by the " { $link call-destructors } " word to the current dynamic scope.  Setting the 'always cleanup?' flag to f allows for keeping resources, such as a successfully opened file descriptor, open after a call to " { $link with-destructors } "." }
{ $notes "The use of the " { $link with-destructors } " word is preferred over calling " { $link call-destructors } " manually." $nl
"Destructors are not allowed to throw exceptions.  No exceptions." }
{ $see-also call-destructors with-destructors } ;

HELP: call-destructors
{ $description "Iterates through a sequence of destructor tuples, calling the destructor quotation on each one." }
{ $notes "The use of the " { $link with-destructors } " word is preferred over calling " { $link call-destructors } " manually." }
{ $see-also add-destructor with-destructors } ;

HELP: with-destructors
{ $values { "quot" "a quotation" } }
{ $description "Calls a quotation within a new dynamic scope.  This quotation may register destructors, on any object, by calling " { $link add-destructor } ".  After the quotation finishes, if an error was thrown, all destructors are called and the error is then rethrown.  However, if the quotation was successful, only those destructors created with an 'always cleanup' flag will be destroyed." } 
{ $notes "Destructors are not allowed to throw exceptions.  No exceptions." }
{ $examples
    { $code "[ 10 malloc dup [ free \"free 10 bytes\" print ] t add-destructor drop ] with-destructors" }
}
{ $see-also add-destructor call-destructors } ;
