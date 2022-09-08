IN: tools.continuations
USING: help.markup help.syntax math ;

HELP: break
{ $description "A breakpoint. When this word is executed, the walker tool opens with execution suspended at the breakpoint's location." }
{ $see-also "ui-walker" } ;

HELP: hit-count@
{ $description "Returns the number of times the word was executed"
} ;

HELP: break=
{ $values { "n" number } }
{ $description
  "Sets a breakpoint which triggers after given count."
  "The walker tool opens with execution suspended at the breakpoint's location."
  " While waiting for the trigger to occur, a hit counter is also incremented"
  " each time the word is executed. This can be useful to find the number of times"
  " the word is executed before something bad happens. Once you know the number of times"
  " you can set the break count to one less then begin troubleshooting."
}
{ $examples
    "Break if the word test is excuted 3 or more times."
    { $unchecked-example
      "USE: tools.continuations : test ( -- ) 3 break= hit-count@ .  ;"
      "test"
      "test"
      "test"
        ""
    }
} 
{ $see-also "ui-walker" "B=" "HIT" } ;
