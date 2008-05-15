USING: help.markup help.syntax libc kernel continuations ;
IN: destructors

HELP: with-destructors
{ $values { "quot" "a quotation" } }
{ $description "Calls a quotation within a new dynamic scope. This quotation may register destructors, on any object, by wrapping the object in a destructor and implementing " { $link dispose } " on that object type.  After the quotation finishes, if an error was thrown, all destructors are called and the error is then rethrown.  However, if the quotation was successful, only those destructors created with an 'always cleanup' flag will be destroyed." }
{ $notes
    "Destructors generalize " { $link with-disposal } ". The following two lines are equivalent:"
    { $code
        "[ X ] with-disposal"
        "[ &dispose X ] with-destructors"
    }
}
{ $examples
    { $code "[ 10 malloc &free ] with-destructors" }
} ;
