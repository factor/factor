USING: continuations help.markup help.syntax io kernel parser
prettyprint quotations system threads vocabs vocabs.loader ;
IN: listener

ARTICLE: "listener-watch" "Watching variables in the listener"
"The listener prints values of dynamic variables which are added to a watch list:"
{ $subsections visible-vars }
"To add or remove a single variable:"
{ $subsections
    show-var
    hide-var
}
"To add and remove multiple variables:"
{ $subsections
    show-vars
    hide-vars
}
"Clearing the watch list:"
{ $subsections hide-all-vars } ;

HELP: use-loaded-vocabs
{ $values { "vocabs" "a sequence of vocabulary specifiers" } }
{ $description "Adds to the search path only those vocabularies which are loaded." } ;

HELP: with-interactive-vocabs
{ $values { "quot" quotation } }
{ $description "Calls the quotation in a scope with an initial vocabulary search path consisting of all vocabularies from " { $link interactive-vocabs } ", and with the current vocabulary for new definitions set to " { $vocab-link "scratchpad" } "." }
{ $notes "This is the same initial search path as used by the " { $link "listener" } " tool." } ;

HELP: show-var
{ $values { "var" "a variable name" } }
{ $description "Adds a variable to the watch list; its value will be printed by the listener after every expression." } ;

HELP: show-vars
{ $values { "seq" "a sequence of variable names" } }
{ $description "Adds a sequence of variables to the watch list; their values will be printed by the listener after every expression." } ;

HELP: hide-var
{ $values { "var" "a variable name" } }
{ $description "Removes a variable from the watch list." } ;

HELP: hide-vars
{ $values { "seq" "a sequence of variable names" } }
{ $description "Removes a sequence of variables from the watch list." } ;

HELP: hide-all-vars
{ $description "Removes all variables from the watch list." } ;

ARTICLE: "listener" "The listener"
"The listener evaluates Factor expressions read from the input stream. Typically, you write Factor code in a text editor, load it from the listener by calling " { $link require } ", " { $link reload } " or " { $link run-file } ", and then test it interactively."
$nl
"The classical first program can be run in the listener:"
{ $example "\"Hello, world\" print" "Hello, world" }
"New words can also be defined in the listener:"
{ $example
    "USE: math.functions"
    ": twice ( word -- ) [ execute ] [ execute ] bi ; inline"
    "81 \\ sqrt twice ."
    "3.0"
}
"Multi-line expressions are supported:"
{ $example "{ 1 2 3 } [\n    .\n] each" "1\n2\n3" }
"The listener will display the current contents of the datastack after every line of input."
$nl
"If your code runs too long, you can press C-Break to interrupt it (works only on Windows). To enable this feature, run the following code, or add it to your " { $link ".factor-rc" } ":"
{ $code
    "USING: listener namespaces ;"
    "t handle-ctrl-break set-global"
}
"The listener can watch dynamic variables:"
{ $subsections "listener-watch" }
"Nested listeners can be useful for testing code in other dynamic scopes. For example, when doing database maintenance using the " { $vocab-link "db.tuples" } " vocabulary, it can be useful to start a listener with a database connection:"
{ $code
    "USING: db db.sqlite listener ;"
    "\"data.db\" <sqlite-db> [ listener ] with-db"
}
"Starting a nested listener:"
{ $subsections listener }
"To exit a listener, invoke the " { $link return } " word."
$nl
"The listener's mechanism for reading multi-line expressions from the input stream can be called from user code:"
{ $subsections read-quot } ;

HELP: handle-ctrl-break
{ $description "If this variable is " { $link t } ", the listener will wrap the user code with calls to " { $link enable-ctrl-break } " and " { $link disable-ctrl-break } " to make it interruptible with C-Break. This includes both compilation and execution phases, so circular vocab import can be interrupted as well as infinite loops."
$nl
"This only works on Windows, and has no effect on other platforms."
{ $warning "There were reports that after enabling this feature the Factor process may hang randomly, see " { $url "https://github.com/factor/factor/issues/2037" } "." }
{ $warning "If user code " { $link yield } "s or gets stuck on an asynchronous I/O operation, pressing C-Break will most likely crash the Factor VM." } } ;

ABOUT: "listener"

HELP: read-quot
{ $values { "quot/f" "a parsed quotation, or " { $link f } " indicating end of file" } }
{ $description "Reads a Factor expression which possibly spans more than one line from " { $link input-stream } ". Additional lines of input are read while the parser stack height is greater than one. Since structural parsing words push partial quotations on the stack, this will keep on reading input until all delimited parsing words are terminated." } ;

HELP: listener
{ $description "Prompts for expressions on " { $link input-stream } " and evaluates them until end of file is reached." } ;
