USING: continuations.private help.markup help.syntax kernel
kernel.private lexer namespaces quotations sequences vectors ;
IN: continuations

ARTICLE: "errors-restartable" "Restartable errors"
"Support for restartable errors is built on top of the basic error handling facility. The following words signals recoverable errors:"
{ $subsections
    throw-restarts
    rethrow-restarts
}
"A utility word using the above:"
{ $subsections
    throw-continue
}
"The list of restarts from the most recently-thrown error is stored in a global variable:"
{ $subsections restarts }
"To invoke restarts, use " { $link "debugger" } "." ;

ARTICLE: "errors-post-mortem" "Post-mortem error inspection"
"The most recently thrown error, together with the continuation at that point, are stored in a pair of global variables:"
{ $subsections
    error
    error-continuation
}
"Developer tools for inspecting these values are found in " { $link "debugger" } "." ;

ARTICLE: "errors-anti-examples" "Common error handling pitfalls"
"When used correctly, exception handling can lead to more robust code with less duplication of error handling logic. However, there are some pitfalls to keep in mind."
{ $heading "Anti-pattern #1: Ignoring errors" }
"The " { $link ignore-errors } " word should almost never be used. Ignoring errors does not make code more robust and in fact makes it much harder to debug if an intermittent error does show up when the code is run under previously unforseen circumstances. Never ignore unexpected errors; always report them to the user."
{ $heading "Anti-pattern #2: Catching errors too early" }
"A less severe form of the previous anti-pattern is code that makes overly zealous use of " { $link recover } ". It is almost always a mistake to catch an error, log a message, and keep going. The only exception is network servers and other long-running processes that must remain running even if individual tasks fail. In these cases, place the " { $link recover } " as high up in the call stack as possible."
$nl
"In most other cases, " { $link cleanup } " should be used instead to handle an error and rethrow it automatically."
{ $heading "Anti-pattern #3: Dropping and rethrowing" }
"Do not use " { $link recover } " to handle an error by dropping it and throwing a new error. By losing the original error data and execution context, you signal to the user that something failed without leaving any indication of what actually went wrong. Either wrap the error in a new error containing additional information, or rethrow the original error. A more subtle form of this is using " { $link throw } " instead of " { $link rethrow } ". The " { $link throw } " word should only be used when throwing new errors, and never when rethrowing errors that have been caught."
{ $heading "Anti-pattern #4: Logging and rethrowing" }
"If you are going to rethrow an error, do not log a message. If you do so, the user will see two log messages for the same error, which will clutter logs without adding any useful information." ;

ARTICLE: "errors" "Exception handling"
"Support for handling exceptional situations such as bad user input, implementation bugs, and input/output errors is provided by a set of words built using continuations."
$nl
"Two words raise an error in the innermost error handler for the current dynamic extent:"
{ $subsections
    throw
    rethrow
}
"Words for establishing an error handler:"
{ $subsections
    cleanup
    recover
    ignore-errors
}
"Syntax sugar for defining errors:"
{ $subsections POSTPONE: ERROR: }
"Unhandled errors are reported in the listener and can be debugged using various tools. See " { $link "debugger" } "."
{ $subsections
    "errors-restartable"
    "debugger"
    "errors-post-mortem"
    "errors-anti-examples"
}
"When Factor encounters a critical error, it calls the following word:"
{ $subsections die } ;

ARTICLE: "continuations.private" "Continuation implementation details"
"A continuation is simply a tuple holding the contents of the five stacks:"
{ $subsections
    continuation
    >continuation<
}
"The five stacks can be read and written:"
{ $subsections
    get-datastack
    set-datastack
    get-retainstack
    set-retainstack
    get-callstack
    set-callstack
    get-namestack
    set-namestack
    get-catchstack
    set-catchstack
} ;

ARTICLE: "continuations" "Continuations"
"At any point in the execution of a program, the " { $emphasis "current continuation" } " represents the future of the computation of this execution context."
$nl
"Words for working with continuations are found in the " { $vocab-link "continuations" } " vocabulary; implementation details are in " { $vocab-link "continuations.private" } "."
$nl
"The general form to reify a continuation and handle resumes is:"
{ $subsections
    ifcc
}
"When resumes don't need special handling, continuations can be more simply reified with the following two words, depending on whether the future of the computation expects data or not:"
{ $subsections
    callcc0
    callcc1
}
"The two following respective words resume these reified continuations:"
{ $subsections
    continue
    continue-with
}
"Resumed continuations can have at most one value passed to them, so passed data must be packed in a single object. In practice this is not a strong limitation. Additionallty, the words for working with continuations without data are in fact just shortcuts for convenience as they actually do pass an empty value and automatically drop it when resuming."
"Reified continuations can be resumed at any time: before or after the capture quotation has returned. And reified continuations can be resumed any number of times: zero, one or arbitrarily many times."
$nl
"In the simplest cases, the reified continuation doesn't escape the initial capture quotation execution. This sufficient for example to implement the non-local exceptional behavior handling of errors where the happy path doesn't resume the continuation at all, but any error immediately resumes the continuation with this error passed in, effectively jumping to were it will be handled from point of execution in the capture quotation. Another example is the short-circuiting nature of early returns (including returns from nested calls in the capture quotation)."
$nl
"And so as a higher abstraction, continuations can also be used as control-flow:"
{ $subsections
    attempt-all
    with-return
}
"Continuations serve as the building block for a number of higher-level abstractions, such as " { $link "errors" } " and " { $link "threads" } "."
{ $subsections "continuations.private" }
"Continuations reach their peak expressive power when resumed multiple many times, and for this to be possible it must be after the capture quotation has initially returned."
"Since resuming a reified continuation after the initial capture quotation returned can only work as long as the program is still running, the rest of the program must be designed accordingly. For example the rest of the program can be some kind of long-running process and resuming the continuation works in a way like restarting this process. Or the rest of the program knows that it must wait for resumes and so acts in a way like receiving commands from the initial capture quotation. Or the rest of the program itself resumes the continuation, behaving like non-deterministic backtracking system that can explore a search space by returning to an earlier execution point, restarting the computation with different branching decisions (a pattern known as " { $emphasis "amb" } ")."
;

ABOUT: "continuations"

HELP: (get-catchstack)
{ $values { "catchstack" "a vector of continuations" } }
{ $description "Outputs the current catchstack." } ;

HELP: get-catchstack
{ $values { "catchstack" "a vector of continuations" } }
{ $description "Outputs a copy of the current catchstack." } ;

HELP: current-continuation
{ $values { "continuation" continuation } }
{ $description "Reifies the current execution context representing the future of the computation into a continuation object." } ;

HELP: set-catchstack
{ $values { "catchstack" "a vector of continuations" } }
{ $description "Replaces the catchstack with a copy of the given vector." } ;

HELP: continuation
{ $class-description "The class of reified continuation objects." } ;

HELP: >continuation<
{ $values { "continuation" continuation } { "data" vector } { "call" vector } { "retain" vector } { "name" vector } { "catch" vector } }
{ $description "Takes a continuation apart into its constituents." } ;

HELP: ifcc
{ $values { "capture" { $quotation ( continuation -- initial ) } } { "restore" { $quotation ( obj -- obj' ) } } { "obj" "an object provided when resuming the continuation or initial" } }
{ $description "Reifies a continuation from the point immediately after which this word would return, and passes it to " { $snippet "capture" } ". Every time the continuation is resumed using " { $link continue-with } " and a new " { $snippet "obj" } " , " { $snippet "restore" } " is called first with " { $snippet "obj" } " on the stack, and then execution continues. If " { $snippet "capture" } " returns, execution continues with " { $snippet "initial" } " on the stack." } ;

{ callcc0 continue callcc1 continue-with ifcc } related-words

HELP: callcc0
{ $values { "quot" { $quotation ( continuation -- ) } } }
{ $description "Applies the quotation to the current continuation, which is reified from the point immediately after which this word would return. Every time the continuation is resumed, execution continues. The " { $link continue } " word is usually used to resume the continuation because any new value is actually just dropped. If " { $snippet "quot" } " returns, execution also continues." } ;

HELP: callcc1
{ $values { "quot" { $quotation ( continuation -- initial ) } } { "obj" "an object provided when resuming the continuation or initial" } }
{ $description "Applies the quotation to the current continuation, which is reified from the point immediately after which this word would return. Every time the continuation is resumed using " { $link continue-with } " and a new " { $snippet "obj" } ", execution continues with " { $snippet "obj" } " on the stack. If " { $snippet "quot" } " returns, execution continues with " { $snippet "initial" } " on the stack." } ;

HELP: continue
{ $values { "continuation" continuation } }
{ $description "Resumes a continuation usually reified by " { $link callcc0 } "." }
{ $notes "This actually resumes the continuation with " { $snippet "f" } "placed on the data stack." } ;

HELP: continue-with
{ $values { "obj" "an object to pass to the resumed continuation's execution context" } { "continuation" continuation } }
{ $description "Resumes a continuation usually reified by " { $link callcc1 } ". The object " { $snippet "obj" } " will be placed on the data stack when the continuation resumes." } ;

HELP: error
{ $description "Global variable holding most recently thrown error." }
{ $notes "Only updated by " { $link throw } ", not " { $link rethrow } "." } ;

HELP: error-continuation
{ $description "Global variable holding current continuation of most recently thrown error." }
{ $notes "Only updated by " { $link throw } ", not " { $link rethrow } "." } ;

HELP: restarts
{ $var-description "Global variable holding the set of possible restarts for the most recently thrown error." }
{ $notes "Only updated by " { $link throw } ", not " { $link rethrow } "." } ;

HELP: throw
{ $values { "error" object } }
{ $description "Reifies and saves the current continuation in the " { $link error-continuation } " global variable and throws an error. Execution does not continue at the point after the " { $link throw } " call. Rather, the innermost catch block is invoked, and execution continues at that point." } ;

{ cleanup recover finally } related-words

HELP: cleanup
{ $values { "try" { $quotation ( ..a -- ..a ) } } { "cleanup-always" { $quotation ( ..a -- ..b ) } } { "cleanup-error" { $quotation ( ..b -- ..b ) } } }
{ $description "Calls the " { $snippet "try" } " quotation. If no error is thrown, calls " { $snippet "cleanup-always" } " without restoring the data stack. If an error is thrown, restores the data stack, calls " { $snippet "cleanup-always" } " followed by " { $snippet "cleanup-error" } ", and rethrows the error." } ;

HELP: finally
{ $values { "try" { $quotation ( ..a -- ..a ) } } { "cleanup-always" { $quotation ( ..a -- ..b ) } } }
{ $description "Same as " { $link cleanup } ", but with empty " { $snippet "cleanup-error" } " quotation. Useful when some cleanup code needs to be run after the " { $snippet "try" } " quotation whether an error was thrown or not, but when nothing specific needs to be done about any errors." } ;

HELP: recover
{ $values { "try" { $quotation ( ..a -- ..b ) } } { "recovery" { $quotation ( ..a error -- ..b ) } } }
{ $description "Calls the " { $snippet "try" } " quotation. If an exception is thrown in the dynamic extent of the " { $snippet "try" } " quotation, restores the data stack and calls the " { $snippet "recovery" } " quotation to handle the error." } ;

HELP: ignore-error
{ $values { "quot" quotation } { "check" quotation } }
{ $description "Calls the quotation. If an exception is thrown which is matched by the 'check' quotation it is ignored. Otherwise the error is rethrown." } ;

HELP: ignore-error/f
{ $values { "quot" quotation } { "check" quotation } { "x/f" { $maybe object } } }
{ $description "Like " { $link ignore-error } ", but if a matched exception is thrown " { $link f } " is put on the stack." } ;

HELP: ignore-errors
{ $values { "quot" quotation } }
{ $description "Calls the quotation. If an exception is thrown in the dynamic extent of the quotation, restores the data stack and returns." }
{ $notes "For safer alternatives to this word see " { $link ignore-error } " and " { $link ignore-error/f } "." } ;

HELP: in-callback?
{ $values { "?" boolean } }
{ $description "t if Factor is currently executing a callback." } ;

HELP: rethrow
{ $values { "error" object } }
{ $description "Throws an error without saving the current continuation in the " { $link error-continuation } " global variable. This is done so that inspecting the error stacks sheds light on the original cause of the exception, rather than the point where it was rethrown." }
{ $notes
    "This word is intended to be used in conjunction with " { $link recover } " to implement error handlers which perform an action and pass the error to the next outermost error handler."
}
{ $examples
    "The " { $link with-lexer } " word catches errors, annotates them with the current line and column number, and rethrows them:"
    { $see with-lexer }
} ;

HELP: throw-restarts
{ $values { "error" object } { "restarts" { $sequence { { $snippet "{ string object }" } " pairs" } } } { "restart" object } }
{ $description "Throws a restartable error using " { $link throw } ". The " { $snippet "restarts" } " parameter is a sequence of pairs where the first element in each pair is a human-readable description and the second is an arbitrary object. If the error reaches the top-level error handler, the user will be presented with the list of possible restarts, and upon invoking one, execution will continue after the call to " { $link throw-restarts } " with the object associated to the chosen restart on the stack." }
{ $examples
    "Try invoking one of the two restarts which are offered after the below code throws an error:"
    { $code
        ": restart-test ( -- )"
        "    \"Oops!\" { { \"One\" 1 } { \"Two\" 2 } } throw-restarts"
        "    \"You restarted: \" write . ;"
        "restart-test"
    }
} ;

HELP: rethrow-restarts
{ $values { "error" object } { "restarts" { $sequence { { $snippet "{ string object }" } " pairs" } } } { "restart" object } }
{ $description "Throws a restartable error using " { $link rethrow } ". Otherwise, this word is identical to " { $link throw-restarts } "." } ;

{ throw rethrow throw-restarts rethrow-restarts throw-continue } related-words

HELP: throw-continue
{ $values { "error" object } }
{ $description "Throws a resumable error. If the user elects to continue execution, this word returns normally." } ;

HELP: compute-restarts
{ $values { "error" object } { "seq" sequence } }
{ $description "Outputs a sequence of triples, where each triple consists of a human-readable string, an object, and a continuation. Resuming a continuation with the corresponding object continues execution immediately after the corresponding call to " { $link condition } "."
$nl
"This word recursively travels up the delegation chain to collate restarts from nested and wrapped conditions." } ;

HELP: save-error
{ $values { "error" "an error" } }
{ $description "Called by the error handler to set the " { $link error } " and " { $link restarts } " global variables after an error was thrown." }
$low-level-note ;

HELP: with-datastack
{ $values { "stack" sequence } { "quot" quotation } { "new-stack" sequence } }
{ $description "Executes the quotation with the given data stack contents, and outputs the new data stack after the word returns. The input sequence is not modified; a new sequence is produced. Does not affect the data stack in surrounding code, other than consuming the two inputs and pushing the output." }
{ $examples
    { $example "USING: continuations math prettyprint ;" "{ 3 7 } [ + ] with-datastack ." "{ 10 }" }
} ;

HELP: attempt-all
{ $values
    { "seq" sequence } { "quot" quotation }
    { "obj" object } }
{ $description "Applies the quotation to elements in a sequence and returns the value from the first quotation that does not throw an error. If all quotations throw an error, returns the last error thrown." }
{ $examples "The first two numbers throw, the last one doesn't:"
    { $example
    "USING: prettyprint continuations kernel math ;"
    "{ 1 3 6 } [ dup odd? [ \"Odd\" throw ] when ] attempt-all ."
    "6" }
    "All quotations throw, the last exception is rethrown:"
    { $example
    "USING: prettyprint continuations kernel math ;"
    "[ { 1 3 5 } [ dup odd? [ throw ] when ] attempt-all ] [ ] recover ."
    "5"
    }
} ;

HELP: return
{ $description "Returns early from a quotation by resuming the continuation reified by " { $link with-return } " ; execution is continued starting immediately after " { $link with-return } "." } ;

HELP: with-return
{ $values
    { "quot" { $quotation ( obj -- obj' ) } } }
{ $description "Reifies a continuation from the point immediately after which this word would return and allows calling the " { $link return } " in " { $snippet "quot" } " to easily resume the continuation and continue execution. If " { $link return } " is not called and " { $snippet "quot" } " returns, then execution continues (as if this word were simply " { $link call } ")." }
{ $examples
    "Only \"Hi\" will print:"
    { $example
    "USING: prettyprint continuations io ;"
    "[ \"Hi\" print return \"Bye\" print ] with-return"
    "Hi"
} } ;

{ return with-return } related-words

HELP: restart
{ $values { "restart" restart } }
{ $description "Invokes a restart." }
{ $class-description "The class of restarts." } ;
