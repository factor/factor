USING: help.markup help.syntax kernel generic
math hashtables quotations classes continuations ;
IN: tools.interpreter

ARTICLE: "meta-interp-step" "Single-stepping words"
"Breakpoints can be inserted in user code:"
{ $subsection break }
"Breakpoints invoke a hook:"
{ $subsection break-hook }
"Single stepping with the meta-circular interpreter:"
{ $subsection step }
{ $subsection step-into }
{ $subsection step-out }
{ $subsection step-all } ;

ARTICLE: "meta-interp-travel" "Backwards time travel"
"Backwards time travel is implemented by capturing the continuation after every step. Since this consumes additional memory, it must be explicitly enabled by storing an empty vector into a variable:"
{ $subsection history }
"If this variable holds a vector, the interpreter state is automatically saved after every step. It can be saved at other points manually:"
{ $subsection save-interpreter }
"Or restore the most recently saved state:"
{ $subsection step-back } ;

ARTICLE: "meta-interpreter" "Meta-circular interpreter"
"The meta-circular interpreter is used to implement the walker tool in the UI. If you are simply interested in single stepping through a piece of code, use the " { $link "ui-walker" } "."
$nl
"On the other hand, if you want to implement a similar tool yourself, then you can use the words described in this section."
$nl
"Meta-circular interpreter words are found in the " { $vocab-link "tools.interpreter" } " vocabulary."
$nl
"The current interpreter state is stored in the " { $link interpreter } " variable."
{ $subsection "meta-interp-step" }
{ $subsection "meta-interp-travel" } ;

ABOUT: "meta-interpreter"

HELP: interpreter
{ $var-description "Variable holding a " { $link continuation } " instance for the single-stepper." } ;

HELP: break
{ $description "Suspends execution of the current thread and starts the single stepper by calling " { $link break-hook } "." } ;

HELP: history
{ $var-description "A sequence of continuations, captured at every stage of single-stepping. Used by " { $link step-back } " to implement backwards time travel." } ;

HELP: save-interpreter
{ $description "Snapshots the single stepper state and saves it in " { $link history } "." } ;

HELP: step
{ $description "Evaluates the object in the single stepper using Factor evaluation semantics:"
    { $list
        { "If the object is a " { $link wrapper } ", then the wrapped object is pushed on the single stepper's data stack" }
        { "If the object is a word, then the word is executed in the single stepper's continuation atomically" }
        { "Otherwise, the object is pushed on the single stepper's data stack" }
    }
} ;

HELP: step-into
{ $description "Evaluates the object in the single stepper using Factor evaluation semantics:"
    { $list
        { "If the object is a " { $link wrapper } ", then the wrapped object is pushed on the single stepper's data stack" }
        { "If the object is a compound word, then the single stepper enters the word definition" }
        { "If the object is a primitive word or a word with special single stepper behavior, it is executed in the single stepper's continuation atomically" }
        { "Otherwise, the object is pushed on the single stepper's data stack" }
    }
} ;

HELP: step-out
{ $description "Evaluates the remainder of the current quotation in the single stepper." } ;

HELP: step-back
{ $description "Steps back to the most recently saved snapshot of the single stepper continuation in " { $link history } "." } ;

HELP: step-all
{ $description "Executes the remainder of the single stepper's continuation. This effectively ends single stepping unless the continuation invokes " { $link break } " at a later point in time." } ;
