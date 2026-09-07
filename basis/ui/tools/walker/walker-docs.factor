IN: ui.tools.walker
USING: help.markup help.syntax ui.commands ui.operations
ui.render tools.walker sequences tools.continuations ;

ARTICLE: "ui-walker-step" "Stepping through code"
"If the current position points to a word, the various stepping commands behave as follows:"
{ $list
    { { $link com-step } " executes the word and moves the current position one word further." }
    { { $link com-into } " enters the word's definition, or its expansion if it is a macro. For a primitive it behaves like " { $link com-step } "." }
    { { $link com-out } " executes until the end of the current quotation." }
}
"If the current position points to a literal, the various stepping commands behave as follows:"
{ $list
    { { $link com-step } " pushes the literal on the data stack." }
    { { $link com-into } " pushes the literal. If it is a quotation, a breakpoint is inserted at the beginning of the quotation, and if it is an array of quotations, a breakpoint is inserted at the beginning of each quotation element." }
    { { $link com-out } " executes until the end of the current quotation." }
}
"The behavior of the " { $link com-into } " command is useful when debugging code using combinators. Instead of stepping into the definition of a combinator, which may be quite complex, you can set a breakpoint on the quotation and continue. For example, suppose the following quotation is being walked:"
{ $code "{ 10 20 30 } [ 3 + . ] each" }
"If the current position is on the quotation and " { $link com-into } " is invoked, the following quotation is pushed on the stack:"
{ $code "[ break 3 + . ]" }
"Invoking " { $link com-continue } " will continue execution until the breakpoint is hit, which in this case happens immediately. The stack can then be inspected to verify that the first element of the array, 10, was pushed. Invoking " { $link com-continue } " proceeds until the breakpoint is hit on the second iteration, at which time the top of the stack will contain the value 20. Invoking " { $link com-continue } " a third time will proceed on to the final iteration where 30 is at the top of the stack. Invoking " { $link com-continue } " again will end the walk of this code snippet, since no more iterations remain the quotation will never be called again and the breakpoint will not be hit."
$nl
"On a fry form, " { $link com-step } " fills the holes and pushes the resulting quotation. " { $link com-into } " also inserts a breakpoint at its beginning, just as for a quotation literal. The body executes when the program calls the quotation. For example, step past the 3 and invoke Into on the fry in:"
{ $code "3 '[ 1 34 _ 5 + + ] call" }
"Stepping over call then pauses before the first 1. Subsequent steps execute 1, 34, 3, 5, +, and +, leaving 1 and 42 on the data stack."
$nl
"The " { $link com-back } " command travels backwards through time, and restore stacks. This does not undo side effects (modifying array entries, writing to files, formatting the hard drive, etc) and therefore can only be used reliably on referentially transparent code." ;

ARTICLE: "ui-walker" "UI walker"
"The walker single-steps through quotations. To use the walker, enter a piece of code in the listener's input area and press " { $operation walk } "."
$nl
"Walkers are instances of " { $link walker-gadget } "."
{ $subsections
    "ui-walker-step"
    "breakpoints"
}
{ $command-map walker-gadget "toolbar" }
{ $command-map walker-gadget "multitouch" } ;

ABOUT: "ui-walker"
