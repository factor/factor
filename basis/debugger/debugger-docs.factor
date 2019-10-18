USING: alien alien.libraries arrays continuations generic.math
generic.single help help.markup help.syntax io kernel math
quotations sbufs strings vectors ;
IN: debugger

ARTICLE: "debugger" "The debugger"
"Caught errors can be logged in human-readable form:"
{ $subsections
    print-error
    try
}
"User-defined errors can have customized printed representation by implementing a generic word:"
{ $subsections error. }
"A number of words facilitate interactive debugging of errors:"
{ $subsections
    :error
    :s
    :r
    :c
    :get
}
"Most types of errors are documented, and the documentation is instantly accessible:"
{ $subsections :help }
"If the error was restartable, a list of restarts is also printed, and a numbered restart can be invoked:"
{ $subsections
    :1
    :2
    :3
    :res
}
"You can read more about error handling in " { $link "errors" } "."
$nl
"Note that in Factor, the debugger is a tool for printing and inspecting errors, not for walking through code. For the latter, see " { $link "ui-walker" } "." ;

ABOUT: "debugger"

HELP: :error
{ $description "Prints the most recent error. Used for interactive debugging." } ;

HELP: :s
{ $description "Prints the data stack at the time of the most recent error. Used for interactive debugging." } ;

HELP: :r
{ $description "Prints the retain stack at the time of the most recent error. Used for interactive debugging." } ;

HELP: :c
{ $description "Prints the call stack at the time of the most recent error. Used for interactive debugging." } ;

HELP: :get
{ $values { "variable" object } { "value" { $maybe "value" } } }
{ $description "Looks up the value of a variable at the time of the most recent error." } ;

HELP: :res
{ $values { "n" "a positive integer" } }
{ $description "Continues executing the " { $snippet "n" } "th restart. Since restarts may only be invoked once, this resets the " { $link restarts } " global variable." } ;

HELP: :1
{ $description "A shortcut for invoking the first restart." } ;

HELP: :2
{ $description "A shortcut for invoking the second restart." } ;

HELP: :3
{ $description "A shortcut for invoking the third restart." } ;

HELP: error.
{ $values { "error" "an error" } }
{ $contract "Print an error to " { $link output-stream } ". You can define methods on this generic word to print human-readable messages for custom errors." }
{ $notes "Code should call " { $link print-error } " instead, which handles the case where the printing of the error itself throws an error." } ;

HELP: error-help
{ $values { "error" "an error" } { "topic" "an article name or word" } }
{ $contract "Outputs a help article which explains the error." } ;

{ error-help :help } related-words

HELP: print-error
{ $values { "error" "an error" } }
{ $description "Print an error to " { $link output-stream } "." }
{ $notes "This word is called by the listener and other tools which report caught errors to the user." } ;

HELP: restarts.
{ $description "Print a list of restarts for the most recently thrown error to " { $link output-stream } "." } ;

HELP: try
{ $values { "quot" quotation } }
{ $description "Attempts to call a quotation; if it throws an error, the error is printed to " { $link output-stream } ", stacks are restored, and execution continues after the call to " { $link try } "." }
{ $examples
    "The following example prints an error and keeps going:"
    { $code
        "[ \"error\" throw ] try"
        "\"still running...\" print"
    }
    { $link "listener" } " uses " { $link try } " to recover from user errors."
} ;

HELP: expired-error.
{ $error-description "Thrown by " { $link alien-address } " and " { $link alien-invoke } " if an " { $link alien } " object passed in as a parameter has expired. Alien objects expire if they are saved an image which is subsequently loaded; this prevents a certain class of programming errors, usually attempts to use uninitialized objects, since holding a C address is meaningless between sessions." }
{ $notes "You can check if an alien object has expired by calling " { $link expired? } "." } ;

HELP: io-error.
{ $error-description "Thrown by the C streams I/O primitives if an I/O error occurs." } ;

HELP: type-check-error.
{ $error-description "Thrown by various primitives if one of the inputs does not have the expected type. Generic words throw " { $link no-method } " and " { $link no-math-method } " errors in such cases instead." } ;

HELP: divide-by-zero-error.
{ $error-description "This error is thrown when " { $link / } " or " { $link /i } " is called with a zero denominator." }
{ $see-also "division-by-zero" } ;

HELP: signal-error.
{ $error-description
    "Thrown by the Factor VM when a Unix signal is received. While signal numbers are system-specific, the following are relatively standard:"
    { $list
        { "4 - Illegal instruction. If you see this error, it is a bug in Factor's compiler and should be reported." }
        { "8 - Arithmetic exception. Most likely a divide by zero in " { $link /i } "." }
        { "10, 11 - Memory protection fault. This error suggests invalid values are being passed to C functions by an " { $link alien-invoke } ". Factor also uses memory protection to trap stack underflows and overflows, but usually these are reported as their own errors. Sometimes they'll show up as a generic signal 11, though." }
    }
    "The Windows equivalent of a signal 11 is a SEH fault. When one occurs, the runtime throws a signal error, even though it does not correspond to a Unix signal."
} ;

HELP: array-size-error.
{ $error-description "Thrown by " { $link <array> } ", " { $link <string> } ", " { $link <vector> } " and " { $link <sbuf> } " if the specified capacity is negative or too large." } ;

HELP: ffi-error.
{ $error-description "Thrown by " { $link dlopen } " and " { $link dlsym } " if a problem occurs while loading a native library or looking up a symbol. See " { $link "alien" } "." } ;

HELP: undefined-symbol-error.
{ $error-description "Thrown if a previously-compiled " { $link alien-invoke } " call refers to a native library symbol which no longer exists." } ;

HELP: datastack-underflow.
{ $error-description "Thrown by the Factor VM if an attempt is made to pop elements from an empty data stack." }
{ $notes "You can use the stack effect tool to statically check stack effects of quotations. See " { $link "inference" } "." } ;

HELP: datastack-overflow.
{ $error-description "Thrown by the Factor VM if an attempt is made to push elements on a full data stack." }
{ $notes "This error usually indicates a run-away recursion, however if you legitimately need a data stack larger than the default, see " { $link "runtime-cli-args" } "." } ;

HELP: retainstack-underflow.
{ $error-description "Thrown by the Factor VM if an attempt is made to access the retain stack in an invalid manner. This bug should never come up in practice and indicates a bug in Factor." }
{ $notes "You can use the stack effect tool to statically check stack effects of quotations. See " { $link "inference" } "." } ;

HELP: retainstack-overflow.
{ $error-description "Thrown by the Factor VM if " { $link dip } " is called when the retain stack is full." }
{ $notes "This error usually indicates a run-away recursion, however if you legitimately need a retain stack larger than the default, see " { $link "runtime-cli-args" } "." } ;

HELP: memory-error.
{ $error-description "Thrown by the Factor VM if an invalid memory access occurs." }
{ $notes "This can be a result of incorrect usage of C library interface words, a bug in the compiler, or a bug in the VM." } ;
