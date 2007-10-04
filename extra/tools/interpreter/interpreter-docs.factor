USING: help.markup help.syntax kernel generic
math hashtables quotations classes continuations ;
IN: tools.interpreter

ARTICLE: "meta-interpreter" "Meta-circular interpreter"
"The meta-circular interpreter is used to implement the walker tool in the UI. If you are simply interested in single stepping through a piece of code, use the " { $link "ui-walker" } "."
$nl
"On the other hand, if you want to implement a similar tool yourself, then you can use the words described in this section."
$nl
"Meta-circular interpreter words are found in the " { $vocab-link "tools.interpreter" } " vocabulary."
$nl
"Breakpoints can be inserted in user code:"
{ $subsection break }
"Breakpoints invoke a hook:"
{ $subsection break-hook }
"Single stepping with the meta-circular interpreter:"
{ $subsection step }
{ $subsection step-into }
{ $subsection step-out }
{ $subsection step-all } ;

ABOUT: "meta-interpreter"

HELP: interpreter
{ $class-description "An interpreter instance." } ;

HELP: break
{ $description "Suspends execution of the current thread and starts the single stepper by calling " { $link break-hook } "." } ;

HELP: step
{ $values { "interpreter" interpreter } }
{ $description "Evaluates the object in the single stepper using Factor evaluation semantics:"
    { $list
        { "If the object is a " { $link wrapper } ", then the wrapped object is pushed on the single stepper's data stack" }
        { "If the object is a word, then the word is executed in the single stepper's continuation atomically" }
        { "Otherwise, the object is pushed on the single stepper's data stack" }
    }
} ;

HELP: step-into
{ $values { "interpreter" interpreter } }
{ $description "Evaluates the object in the single stepper using Factor evaluation semantics:"
    { $list
        { "If the object is a " { $link wrapper } ", then the wrapped object is pushed on the single stepper's data stack" }
        { "If the object is a compound word, then the single stepper enters the word definition" }
        { "If the object is a primitive word or a word with special single stepper behavior, it is executed in the single stepper's continuation atomically" }
        { "Otherwise, the object is pushed on the single stepper's data stack" }
    }
} ;

HELP: step-out
{ $values { "interpreter" interpreter } }
{ $description "Evaluates the remainder of the current quotation in the single stepper." } ;

HELP: step-all
{ $values { "interpreter" interpreter } }
{ $description "Executes the remainder of the single stepper's continuation. This effectively ends single stepping unless the continuation invokes " { $link break } " at a later point in time." } ;
