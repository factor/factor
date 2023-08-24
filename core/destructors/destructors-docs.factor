USING: classes help.markup help.syntax io quotations sequences ;
IN: destructors

HELP: debug-leaks?
{ $var-description "When this variable is on, " { $link new-disposable } " stores the current continuation in the " { $link disposable } "'s " { $slot "continuation" } " slot." }
{ $see-also "tools.destructors" } ;

HELP: disposable
{ $class-description "Parent class for disposable resources. This class has two slots:"
    { $slots
        { "disposed" { "A boolean value, set to true by " { $link dispose } ". Assert that it is false with " { $link check-disposed } "." } }
        { "continuation" { "The current continuation at construction time, for debugging. Set by " { $link new-disposable } " if " { $link debug-leaks? } " is on." } }
    }
"New instances must be constructed with " { $link new-disposable } " and subclasses must implement " { $link dispose* } "." } ;

HELP: new-disposable
{ $values { "class" class } { "disposable" disposable } }
{ $description "Constructs a new instance of a subclass of " { $link disposable } ". This sets the " { $slot "id" } " slot, registers the new object with the global " { $link disposables } " set, and if " { $link debug-leaks? } " is on, stores the current continuation in the " { $slot "continuation" } " slot." } ;

HELP: dispose
{ $values { "disposable" "a disposable object" } }
{ $contract "Releases operating system resources associated with a disposable object. Disposable objects include streams, memory mapped files, and so on."
$nl
"No further operations can be performed on a disposable object after this call."
$nl
"Disposing an object which has already been disposed should have no effect, and in particular it should not fail with an error. To help implement this pattern, inherit from the " { $link disposable } " class and implement the " { $link dispose* } " method instead." }
{ $notes "You must dispose of disposable objects after you are finished working with them, to avoid leaking operating system resources. A convenient way to automate this is by using the " { $link with-disposal } " word."
$nl
"The default implementation assumes the object has a " { $snippet "disposed" } " slot. If the slot is set to " { $link f } ", it calls " { $link dispose* } " and sets the slot to " { $link t } "." } ;

HELP: dispose*
{ $values { "disposable" "a disposable object" } }
{ $contract "Releases operating system resources associated with a disposable object. Disposable objects include streams, memory mapped files, and so on." }
{ $notes
    "This word should not be called directly. It can be implemented on objects with a " { $slot "disposed" } " slot to ensure that the object is only disposed once."
} ;

HELP: with-disposal
{ $values { "object" "a disposable object" } { "quot" { $quotation ( object -- ) } } }
{ $description "Calls the quotation, disposing the object with " { $link dispose } " after the quotation returns or if it throws an error." } ;

HELP: with-destructors
{ $values { "quot" quotation } }
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

HELP: disposables
{ $var-description "Global variable holding all disposable objects which have not been disposed of yet. The " { $link new-disposable } " word adds objects here, and the " { $link dispose } " method on disposables removes them. The " { $link "tools.destructors" } " vocabulary provides some words for working with this data." }
{ $see-also "tools.destructors" } ;

ARTICLE: "destructors-anti-patterns" "Resource disposal anti-patterns"
"Words which create objects corresponding to external resources should always be used with " { $link with-disposal } ". The following code is wrong:"
{ $code
    "<external-resource> ... do stuff ... dispose"
}
"The reason being that if " { $snippet "do stuff" } " throws an error, the resource will not be disposed of. The most important case where this can occur is with I/O streams, and the correct solution is to always use " { $link with-input-stream } " and " { $link with-output-stream } "; see " { $link "stdio" } " for details." ;

ARTICLE: "destructors-using" "Using destructors"
"Disposing of an object:"
{ $subsections dispose }
"Utility word for scoped disposal:"
{ $subsections with-disposal }
"Utility word for disposing multiple objects:"
{ $subsections dispose-each }
"Utility words for more complex disposal patterns:"
{ $subsections
    with-destructors
    &dispose
    |dispose
} ;

ARTICLE: "destructors-extending" "Writing new destructors"
"Superclass for disposable objects:"
{ $subsections disposable }
"Parameterized constructor for disposable objects:"
{ $subsections new-disposable }
"Generic disposal word:"
{ $subsections dispose* }
"Global set of disposable objects:"
{ $subsections disposables } ;

ARTICLE: "destructors" "Deterministic resource disposal"
"Operating system resources such as streams, memory mapped files, and so on are not managed by Factor's garbage collector and must be released when you are done with them. Failing to release a resource can lead to reduced performance and instability."
{ $subsections
    "destructors-using"
    "destructors-extending"
    "destructors-anti-patterns"
}
{ $see-also "tools.destructors" } ;

ABOUT: "destructors"
