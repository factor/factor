USING: help.markup help.syntax kernel generic
math hashtables quotations classes continuations ;
IN: tools.interpreter

ARTICLE: "meta-interp-state" "Interpreter state"
"The current interpreter state is stored in a number of variables:"
{ $subsection meta-interp }
{ $subsection callframe }
{ $subsection callframe-scan }
"A set of utility words for inspecting and modifying interpreter state is provided:"
{ $subsection meta-d }
{ $subsection push-d }
{ $subsection pop-d }
{ $subsection peek-d }
{ $subsection meta-r }
{ $subsection push-r }
{ $subsection pop-r }
{ $subsection peek-r }
{ $subsection meta-c }
{ $subsection push-c }
{ $subsection pop-c }
{ $subsection peek-c }
"Calling a quotation in the meta-circular interpreter:"
{ $subsection meta-call } ;

ARTICLE: "meta-interp-step" "Single-stepping words"
"Breakpoints can be inserted in user code:"
{ $subsection break }
"Breakpoints invoke a hook:"
{ $subsection break-hook }
"Single stepping with the meta-circular interpreter:"
{ $subsection step }
{ $subsection step-in }
{ $subsection step-out }
{ $subsection step-all }
{ $subsection abandon } ;

ARTICLE: "meta-interp-travel" "Backwards time travel"
"Backwards time travel is implemented by capturing the continuation after every step. Since this consumes additional memory, it must be explicitly enabled by storing an empty vector into a variable:"
{ $subsection meta-history }
"If this variable holds a vector, the interpreter state is automatically saved after every step. It can be saved at other points manually:"
{ $subsection save-interp }
"You can also restore any prior state:"
{ $subsection restore-interp }
"Or restore the most recently saved state:"
{ $subsection step-back } ;

ARTICLE: "meta-interp-impl" "Interpreter implementation"
"Custom single stepping behavior can be implemented by calling the common factor shared by " { $link step } " and " { $link step-in } ":"
{ $subsection next }
"The meta-circular interpreter executes most words much like the Factor interpreter; primitives are executed atomically and compound words are descended into. These semantics can be customized by setting the " { $snippet "\"meta-word\"" } " word property to a quotation. This quotation is run in the host interpreter and can make use of the words in " { $link "meta-interp-state" } "."
$nl
"Additionally, the " { $snippet "\"no-meta-word\"" } " word property can be set to " { $link t } " to instruct the meta-circular interpreter to always execute the word atomically, even if " { $link step-in } " is called." ;

ARTICLE: "meta-interpreter" "Meta-circular interpreter"
"The meta-circular interpreter is used to implement the walker tool in the UI. If you are simply interested in single stepping through a piece of code, use the " { $link "ui-walker" } "."
$nl
"On the other hand, if you want to implement a similar tool yourself, then you can use the words described in this section."
$nl
"Meta-circular interpreter words are found in the " { $vocab-link "tools.interpreter" } " vocabulary."
{ $subsection "meta-interp-state" }
{ $subsection "meta-interp-step" }
{ $subsection "meta-interp-travel" }
{ $subsection "meta-interp-impl" } ;

ABOUT: "meta-interpreter"

HELP: meta-interp
{ $var-description "Variable holding a " { $link continuation } " instance for the single-stepper." } ;

HELP: meta-d
{ $values { "seq" "a sequence" } }
{ $description "Pushes the data stack from the single stepper." } ;

HELP: push-d
{ $values { "obj" object } }
{ $description "Pushes an object on the single stepper's data stack." } ;

HELP: pop-d
{ $values { "obj" object } }
{ $description "Pops an object from the single stepper's data stack." }
{ $errors "Throws an error if the single stepper's data stack is empty." } ;

HELP: peek-d
{ $values { "obj" object } }
{ $description "Outputs the object at the top of the single stepper's data stack." }
{ $errors "Throws an error if the single stepper's data stack is empty." } ;

HELP: meta-r
{ $values { "seq" "a sequence" } }
{ $description "Pushes the retain stack from the single stepper." } ;

HELP: push-r
{ $values { "obj" object } }
{ $description "Pushes an object on the single stepper's retain stack." } ;

HELP: pop-r
{ $values { "obj" object } }
{ $description "Pops an object from the single stepper's retain stack." }
{ $errors "Throws an error if the single stepper's retain stack is empty." } ;

HELP: peek-r
{ $values { "obj" object } }
{ $description "Outputs the object at the top of the single stepper's retain stack." }
{ $errors "Throws an error if the single stepper's retain stack is empty." } ;

HELP: meta-c
{ $values { "seq" "a sequence" } }
{ $description "Pushes the call stack from the single stepper." } ;

HELP: push-c
{ $values { "obj" object } }
{ $description "Pushes an object on the single stepper's call stack." } ;

HELP: pop-c
{ $values { "obj" object } }
{ $description "Pops an object from the single stepper's call stack." }
{ $errors "Throws an error if the single stepper's call stack is empty." } ;

HELP: peek-c
{ $values { "obj" object } }
{ $description "Outputs the object at the top of the single stepper's call stack." }
{ $errors "Throws an error if the single stepper's call stack is empty." } ;

HELP: break-hook
{ $var-description "A quotation called by the " { $link break } " word. The default value invokes the " { $link "ui-walker" } "." } ;

HELP: callframe
{ $var-description "The quotation currently being stepped through by the single stepper." } ;

HELP: callframe-scan
{ $var-description "The index of the next object to be evaluated by the single stepper." } ;

HELP: break
{ $description "Suspends execution of the current thread and starts the single stepper by calling " { $link break-hook } "." } ;

HELP: up
{ $description "Returns from the current quotation in the single stepper." } ;

HELP: done-cf?
{ $values { "?" "a boolean" } }
{ $description "Outputs whether the current quotation has finished evaluating in the single stepper." } ;

HELP: done?
{ $values { "?" "a boolean" } }
{ $description "Outputs whether the current continuation has finished evaluating in the single stepper." }
;

HELP: reset-interpreter
{ $description "Resets the single stepper, discarding any prior state." } ;

HELP: save-callframe
{ $description "Saves the currently evaluating quotation on the single stepper's call stack." } ;

HELP: meta-call
{ $values { "quot" quotation } }
{ $description "Begins evaluating a quotation in the single stepper, performing tail call optimization if the prior quotation has finished evaluating." } ;

HELP: step-to
{ $values { "n" integer } }
{ $description "Evaluates the single stepper's continuation until the " { $snippet "n" } "th index in the current quotation." } ;

HELP: meta-history
{ $var-description "A sequence of continuations, captured at every stage of single-stepping. Used by " { $link step-back } " to implement backwards time travel." } ;

HELP: save-interp
{ $description "Snapshots the single stepper state and saves it in " { $link meta-history } "." } ;

HELP: restore-interp
{ $values { "ns" hashtable } }
{ $description "Restores the single stepper to a former state, which must have been saved by a call to " { $link save-interp } "." } ;

HELP: next
{ $values { "quot" quotation } }
{ $description "Applies the quotation to the next object evaluated by the single stepper. If the single stepper's current quotation has finished evaluating, this will return to the caller quotation." }
{ $notes "This word is used to implement " { $link step } " and " { $link step-in } "." } ;

HELP: step
{ $description "Evaluates the object in the single stepper using Factor evaluation semantics:"
    { $list
        { "If the object is a " { $link wrapper } ", then the wrapped object is pushed on the single stepper's data stack" }
        { "If the object is a word, then the word is executed in the single stepper's continuation atomically" }
        { "Otherwise, the object is pushed on the single stepper's data stack" }
    }
} ;

HELP: step-in
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
{ $description "Steps back to the most recently saved snapshot of the single stepper continuation in " { $link meta-history } "." } ;

HELP: step-all
{ $description "Executes the remainder of the single stepper's continuation. This effectively ends single stepping unless the continuation invokes " { $link break } " at a later point in time." } ;

HELP: abandon
{ $description "Raises an error in the single stepper's continuation then executes the remainder of the continuation starting from the error handler." } ;
