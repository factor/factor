IN: tools.continuations
USING: help.markup help.syntax ;

HELP: break
{ $description "A breakpoint. When this word is executed, the walker tool opens with execution suspended at the breakpoint's location." }
{ $see-also "ui-walker" } ;

HELP: break-count
{ $description "Counts the number of times the word is executed."
  $nl "Uses the symbol " { $link break-counter } " to accumulate the number of times. "
  "Examine the counter in the walker to set up a conditional break point using " { $link break-count= } "."
}
{ $examples
  { $code 
    "yourcode break-count yourcode"
    "break-counter get . "
    }
}
{ $notes "The shortcut BC is available for use. \n\nInitialize the counter before using with " { $link break-count-zero } 
" either manually in the Listener or appropriately in your code before any looping occurs" } 
;

HELP: break-count=
{ $values { "n" "number to wait" } }
{ $description "Sets a conditional breakpoint based on the " { $link break-counter } "."
  "When the counter reaches the number given a break will occur." }
{ $examples
  { $code 
        "10 break-count="
    }
}
{ $notes "The shortcut BC= is avaiable for use" }
;

HELP: break-count-zero
{ $description "Initializes the symbol " { $link break-count } " by setting it to zero" } 
;
