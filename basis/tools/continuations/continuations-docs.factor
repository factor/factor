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
    "code break-count code"
    "break-counter get . "
    }
}
{ $notes "The shortcut  $link BC   is available for use." }
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
{ $notes "The shortcut  $link BC=   is avaiable for use" }
;
