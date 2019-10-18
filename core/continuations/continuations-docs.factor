USING: help.markup help.syntax kernel kernel.private
continuations.private parser vectors arrays namespaces
threads assocs words ;
IN: continuations

ARTICLE: "errors-restartable" "Restartable error handling"
"Support for restartable errors is built on top of the basic error handling facility. The following words signals recoverable errors:"
{ $subsection throw-restarts }
{ $subsection rethrow-restarts }
"The list of restarts from the most recently-thrown error is stored in a global variable:"
{ $subsection restarts }
"To invoke restarts, see " { $link "debugger" } "." ;

ARTICLE: "errors-post-mortem" "Post-mortem error inspection"
"The most recently thrown error, together with the continuation at that point, are stored in a pair of global variables:"
{ $subsection error }
{ $subsection error-continuation }
"Developer tools for inspecting these values are found in " { $link "debugger" } "." ;

ARTICLE: "errors" "Error handling"
"Support for handling exceptional situations such as bad user input, implementation bugs, and input/output errors is provided by a set of words built using continuations."
$nl
"Two words raise an error in the innermost error handler for the current dynamic extent:"
{ $subsection throw }
{ $subsection rethrow }
"A set of words establish an error handler:"
{ $subsection cleanup }
{ $subsection recover }
{ $subsection catch }
"Unhandled errors are reported in the listener and can be debugged using various tools. See " { $link "debugger" } "."
{ $subsection "errors-restartable" }
{ $subsection "errors-post-mortem" } ;

ARTICLE: "continuations.private" "Continuation implementation details"
"A continuation is simply a tuple holding the contents of the five stacks:"
{ $subsection continuation }
{ $subsection >continuation< }
"The five stacks can be read and written:"
{ $subsection datastack }
{ $subsection set-datastack }
{ $subsection retainstack }
{ $subsection set-retainstack }
{ $subsection callstack }
{ $subsection set-callstack }
{ $subsection namestack }
{ $subsection set-namestack }
{ $subsection catchstack }
{ $subsection set-catchstack }
"The continuations implementation has hooks for single-steppers:"
{ $subsection walker-hook }
{ $subsection set-walker-hook }
{ $subsection (continue) }
{ $subsection (continue-with) } ;

ARTICLE: "continuations" "Continuations"
"At any point in the execution of a program, the " { $emphasis "current continuation" } " represents the future of the computation."
$nl
"Words for working with continuations are found in the " { $vocab-link "continuations" } " vocabulary; implementation details are in " { $vocab-link "continuations.private" } "."
$nl
"Continuations can be reified with the following two words:"
{ $subsection callcc0 }
{ $subsection callcc1 }
"Another two words resume continuations:"
{ $subsection continue }
{ $subsection continue-with }
"Continuations serve as the building block for a number of higher-level abstractions."
{ $subsection "errors" }
{ $subsection "continuations.private" } ;

ABOUT: "continuations"

HELP: catchstack*
{ $values { "catchstack" "a vector of continuations" } }
{ $description "Outputs the current catchstack." } ;

HELP: catchstack
{ $values { "catchstack" "a vector of continuations" } }
{ $description "Outputs a copy of the current catchstack." } ;

HELP: set-catchstack
{ $values { "catchstack" "a vector of continuations" } }
{ $description "Replaces the catchstack with a copy of the given vector." } ;

HELP: continuation
{ $values { "continuation" continuation } }
{ $description "Reifies the current continuation from the point immediately after which the caller returns." } ;

HELP: >continuation<
{ $values { "continuation" continuation } { "data" vector } { "retain" vector } { "call" vector } { "name" vector } { "catch" vector } { "c" array } }
{ $description "Takes a continuation apart into its constituents." } ;

HELP: ifcc
{ $values { "terminator" "a quotation with stack effect " { $snippet "( continuation -- )" } } { "balance" "a quotation" } }
{ $description "Reifies a continuation from the point immediately after which this word returns, and passes it to " { $snippet "terminator" } ". When the continuation is restored, execution resumes and "{ $snippet "balance" } " is called." } ;

{ callcc0 continue callcc1 continue-with ifcc } related-words

HELP: callcc0
{ $values { "quot" "a quotation with stack effect " { $snippet "( continuation -- )" } } }
{ $description "Applies the quotation to the current continuation, which is reified from the point immediately after which the caller returns. The " { $link continue } " word resumes the continuation." } ;

HELP: callcc1
{ $values { "quot" "a quotation with stack effect " { $snippet "( continuation -- )" } } { "obj" "an object provided when resuming the continuation" } }
{ $description "Applies the quotation to the current continuation, which is reified from the point immediately after which the caller returns. The " { $link continue-with } " word resumes the continuation, passing a value back to the original execution context." } ;

HELP: set-walker-hook
{ $values { "quot" "a quotation with stack effect " { $snippet "( continuation -- )" } ", or " { $link f } } }
{ $description "Sets a quotation to be called when a continuation is resumed." }
{ $notes "The single-stepper uses this hook to support single-stepping through code which makes use of continuations." } ;

HELP: walker-hook
{ $values { "quot" "a quotation with stack effect " { $snippet "( obj -- )" } ", or " { $link f } } }
{ $description "Outputs a quotation to be called when a continuation is resumed, or " { $link f } " if no hook is set. If a hook was set prior to this word being called, it will be reset to " { $link f } "."
$nl
"The following words do not perform their usual action and instead just call the walker hook if one is set:"
    { $list
        { { $link callcc0 } " will call the hook, passing it the continuation to resume." }
        { { $link callcc1 } " will call the hook, passing it a " { $snippet "{ obj continuation }" } " pair." }
        { { $link stop } " will call the hook, passing it " { $link f } "." }
    }
"The walker hook must take appropriate action so that the callers of these words see the behavior that they expect." }
{ $notes "The single-stepper uses this hook to support single-stepping through code which makes use of continuations." } ;

HELP: (continue)
{ $values { "continuation" continuation } }
{ $description "Resumes a continuation reified by " { $link callcc0 } " without invoking " { $link walker-hook } "." } ;

HELP: (continue-with)
{ $values { "obj" "an object to pass to the continuation's execution context" } { "continuation" continuation } }
{ $description "Resumes a continuation reified by " { $link callcc1 } " without invoking " { $link walker-hook } ". The object will be placed on the data stack when the continuation resumes." } ;

HELP: continue
{ $values { "continuation" continuation } }
{ $description "Resumes a continuation reified by " { $link callcc0 } "." } ;

HELP: continue-with
{ $values { "obj" "an object to pass to the continuation's execution context" } { "continuation" continuation } }
{ $description "Resumes a continuation reified by " { $link callcc1 } ". The object will be placed on the data stack when the continuation resumes." } ;

HELP: error
{ $description "Global variable holding most recently thrown error." }
{ $notes "Only updated by " { $link throw } ", not " { $link rethrow } "." } ;

HELP: error-continuation
{ $description "Global variable holding current continuation of most recently thrown error." }
{ $notes "Only updated by " { $link throw } ", not " { $link rethrow } "." } ;

HELP: restarts
{ $var-description "Global variable holding the set of possible restarts for the most recently thrown error." }
{ $notes "Only updated by " { $link throw } ", not " { $link rethrow } "." } ;

HELP: >c
{ $values { "continuation" continuation } }
{ $description "Pushes an exception handler continuation on the catch stack. The continuation must have been reified by " { $link callcc1 } "." } ;

HELP: c>
{ $values { "continuation" continuation } }
{ $description "Pops an exception handler continuation from the catch stack." } ;

HELP: throw ( error -- * )
{ $values { "error" "an object" } }
{ $description "Saves the current continuation in the " { $link error-continuation } " global variable and throws an error. Execution does not continue at the point after the " { $link throw } " call. Rather, the innermost catch block is invoked, and execution continues at that point." } ;

HELP: catch
{ $values { "try" "a quotation" } { "error/f" "an object" } }
{ $description "Calls the " { $snippet "try" } " quotation. If an error is thrown in the dynamic extent of the quotation, restores the data stack and pushes the error. If the quotation returns successfully, outputs " { $link f } " without restoring the data stack." }
{ $notes "This word cannot differentiate between the case of " { $link f } " being thrown, and no error being thrown. You should never throw " { $link f } ", and you should also use other error handling combinators where possible." } ;

{ catch cleanup recover } related-words

HELP: cleanup
{ $values { "try" "a quotation" } { "cleanup" "a quotation" } }
{ $description "Calls the " { $snippet "try" } " quotation. If an exception is thrown in the dynamic extent of the " { $snippet "try" } " quotation, restores the data stack, calls the " { $snippet "cleanup" } " quotation, and rethrows the error. If the " { $snippet "try" } " quotation returns successfully, calls the " { $snippet "cleanup" } " quotation without restoring the data stack." } ;

HELP: recover
{ $values { "try" "a quotation" } { "recovery" "a quotation with stack effect " { $snippet "( error -- )" } } }
{ $description "Calls the " { $snippet "try" } " quotation. If an exception is thrown in the dynamic extent of the " { $snippet "try" } " quotation, restores the data stack and calls the " { $snippet "recovery" } " quotation to handle the error." } ;

HELP: rethrow
{ $values { "error" "an object" } }
{ $description "Throws an error without saving the current continuation in the " { $link error-continuation } " global variable. This is done so that inspecting the error stacks sheds light on the original cause of the exception, rather than the point where it was rethrown." }
{ $notes
    "This word is intended to be used in conjunction with " { $link recover } " or " { $link catch } " to implement error handlers which perform an action and pass the error to the next outermost error handler."
}
{ $examples
    "The " { $link with-parser } " catches errors, annotates them with file name and line number information, and rethrows them:"
    { $see with-parser }
} ;

HELP: throw-restarts
{ $values { "error" "an object" } { "restarts" "a sequence of " { $snippet "{ string object }" } " pairs" } { "restart" "an object" } }
{ $description "Throws a restartable error using " { $link throw } ". The " { $snippet "restarts" } " parameter is a sequence of pairs where the first element in each pair is a human-readable description and the second is an arbitrary object. If the error reaches the top-level error handler, the user will be presented with the list of possible restarts, and upon invoking one, execution will continue after the call to " { $link condition } " with the object associated to the chosen restart on the stack." }
{ $examples
    "Try invoking one of the two restarts which are offered after the below code throws an error:"
    { $code
        ": restart-test"
        "    \"Oops!\" { { \"One\" 1 } { \"Two\" 2 } } condition"
        "    \"You restarted: \" write . ;"
        "restart-test"
    }
} ;

HELP: rethrow-restarts
{ $values { "error" "an object" } { "restarts" "a sequence of " { $snippet "{ string object }" } " pairs" } { "restart" "an object" } }
{ $description "Throws a restartable error using " { $link rethrow } ". Otherwise, this word is identical to " { $link throw-restarts } "." } ;

{ throw rethrow throw-restarts rethrow-restarts } related-words

HELP: compute-restarts
{ $values { "error" "an object" } { "seq" "a sequence" } }
{ $description "Outputs a sequence of triples, where each triple consists of a human-readable string, an object, and a continuation. Resuming a continuation with the corresponding object restarts execution immediately after the corresponding call to " { $link condition } "."
$nl
"This word recursively travels up the delegation chain to collate restarts from nested and wrapped conditions." } ;

HELP: save-error
{ $values { "error" "an error" } }
{ $description "Called by the error handler to set the " { $link error } " and " { $link restarts } " global variables after an error was thrown." }
$low-level-note ;

HELP: error-handler
{ $values { "error" "an error" } { "trace" "a sequence of XTs" } }
{ $description "Called by the Factor VM when an error is thrown, either from an explicit call to " { $link throw } " or an error occurring inside the VM. This word saves the error in a global variable and passes it on to the innermost " { $link catch } " handler." }
$low-level-note ;

HELP: init-error-handler
{ $description "Called on startup to initialize the catch stack and set a pair of hooks which allow the Factor VM to signal errors to library code." } ;

HELP: xt-map ( -- xt-map )
{ $values { "xt-map" "an association list mapping words to XTs" } }
{ $description "Outputs an association list of all compiled words in the code heap, mapping words to XTs, sorted by XT (for binary search). Since one word can generate multiple compiled code blocks, this association list may have duplicate keys." }
;

HELP: find-xt
{ $values { "xt" "an XT" } { "xtmap" "an association list mapping words to XTs" } { "word" word } }
{ $description "Look up the word containing the specified code heap address." } ;

HELP: find-xts
{ $values { "seq" "a sequence of XTs" } { "newseq" "a sequence of words" } }
{ $description "Translates a sequence of return addresses captured from the call stack to a sequence of words." } ;
