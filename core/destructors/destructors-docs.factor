USING: help.markup help.syntax libc kernel continuations io
sequences ;
IN: destructors

HELP: dispose
{ $values { "disposable" "a disposable object" } }
{ $contract "Releases operating system resources associated with a disposable object. Disposable objects include streams, memory mapped files, and so on."
$nl
"No further operations can be performed on a disposable object after this call."
$nl
"Disposing an object which has already been disposed should have no effect, and in particular it should not fail with an error. To help implement this pattern, add a " { $slot "disposed" } " slot to your object and implement the " { $link dispose* } " method instead." }
{ $notes "You must close disposable objects after you are finished working with them, to avoid leaking operating system resources. A convenient way to automate this is by using the " { $link with-disposal } " word."
$nl
"The default implementation assumes the object has a " { $snippet "disposed" } " slot. If the slot is set to " { $link f } ", it calls " { $link dispose* } " and sets the slot to " { $link t } "." } ;

HELP: dispose*
{ $values { "disposable" "a disposable object" } }
{ $contract "Releases operating system resources associated with a disposable object. Disposable objects include streams, memory mapped files, and so on." }
{ $notes
    "This word should not be called directly. It can be implemented on objects with a " { $slot "disposed" } " slot to ensure that the object is only disposed once."
} ;

HELP: with-disposal
{ $values { "object" "a disposable object" } { "quot" { $quotation "( object -- )" } } }
{ $description "Calls the quotation, disposing the object with " { $link dispose } " after the quotation returns or if it throws an error." } ;

HELP: with-destructors
{ $values { "quot" "a quotation" } }
{ $description "Calls a quotation within a new dynamic scope. This quotation may register destructors using " { $link &dispose } " or " { $link |dispose } ". The former registers a destructor that will always run whether or not the quotation threw an error, and the latter registers a destructor that only runs if the quotation throws an error. Destructors are run in reverse order from the order in which they were registered." }
{ $notes
    "Destructors generalize " { $link with-disposal } ". The following two lines are equivalent, except that the second line establishes a new dynamic scope:"
    { $code
        "[ X ] with-disposal"
        "[ &dispose X ] with-destructors"
    }
}
{ $examples
    { $code "[ 10 malloc &free ] with-destructors" }
} ;

HELP: &dispose
{ $values { "disposable" "a disposable object" } }
{ $description "Marks the object for unconditional disposal at the end of the current " { $link with-destructors } " scope." } ;

HELP: |dispose
{ $values { "disposable" "a disposable object" } }
{ $description "Marks the object for disposal in the event of an error at the end of the current " { $link with-destructors } " scope." } ;

HELP: dispose-each
{ $values
     { "seq" sequence } }
{ $description "Attempts to dispose of each element of a sequence and collects all of the errors into a sequence. If any errors are thrown during disposal, the last error is rethrown after all objects have been disposed." } ;

ARTICLE: "destructors-anti-patterns" "Resource disposal anti-patterns"
"Words which create objects corresponding to external resources should always be used with " { $link with-disposal } ". The following code is wrong:"
{ $code
    "<external-resource> ... do stuff ... dispose"
}
"The reason being that if " { $snippet "do stuff" } " throws an error, the resource will not be disposed of. The most important case where this can occur is with I/O streams, and the correct solution is to always use " { $link with-input-stream } " and " { $link with-output-stream } "; see " { $link "stdio" } " for details." ;

ARTICLE: "destructors" "Deterministic resource disposal"
"Operating system resources such as streams, memory mapped files, and so on are not managed by Factor's garbage collector and must be released when you are done with them. Failing to release a resource can lead to reduced performance and instability."
$nl
"Disposable object protocol:"
{ $subsection dispose }
{ $subsection dispose* }
"Utility word for scoped disposal:"
{ $subsection with-disposal }
"Utility word for disposing multiple objects:"
{ $subsection dispose-each }
"Utility words for more complex disposal patterns:"
{ $subsection with-destructors }
{ $subsection &dispose }
{ $subsection |dispose }
{ $subsection "destructors-anti-patterns" } ;

ABOUT: "destructors"
