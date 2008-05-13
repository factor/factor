USING: help.markup help.syntax libc kernel continuations ;
IN: destructors

HELP: free-always
{ $values { "alien" "alien returned by malloc" } }
{ $description "Adds a destructor that will " { $link free } " the alien.  The free will happen whenever the quotation passed to " { $link with-destructors } " ends." }
{ $see-also free-later } ;

HELP: free-later
{ $values { "alien" "alien returned by malloc" } }
{ $description "Adds a destructor that will " { $link free } " the alien.  The free will happen whenever the quotation passed to " { $link with-destructors } " errors or else the object will persist and manual cleanup is required later." }
{ $see-also free-always } ;

HELP: with-destructors
{ $values { "quot" "a quotation" } }
{ $description "Calls a quotation within a new dynamic scope.  This quotation may register destructors, on any object, by wrapping the object in a destructor and implementing " { $link dispose } " on that object type.  After the quotation finishes, if an error was thrown, all destructors are called and the error is then rethrown.  However, if the quotation was successful, only those destructors created with an 'always cleanup' flag will be destroyed." }
{ $notes "Destructors are not allowed to throw exceptions.  No exceptions." }
{ $examples
    { $code "[ 10 malloc free-always ] with-destructors" }
} ;
