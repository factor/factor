USING: compiler.cfg compiler.cfg.registers help.markup help.syntax ;
IN: compiler.cfg.stacks.local

HELP: current-height
{ $class-description "A tuple used to keep track of the heights of the data and retain stacks in a " { $link basic-block } " The idea is that if the stack change instructions are tracked, then multiple changes can be folded into one. It has the following slots:"
  { $table
    { { $slot "d" } { "Current datastack height." } }
    { { $slot "r" } { "Current retainstack height." } }
    { { $slot "emit-d" } { "Queued up datastack height change." } }
    { { $slot "emit-r" } { "Queued up retainstack height change." } }
  }
} ;

HELP: translate-local-loc
{ $values { "loc" loc } { "loc'" loc } }
{ $description "Translates an absolute stack location to one that is relative to the current stacks height as given in " { $link current-height } "." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.local compiler.cfg.registers compiler.cfg.debugger namespaces prettyprint ;"
    "T{ current-height { d 3 } } current-height set D 7 translate-local-loc ."
    "D 4"
  }
} ;

HELP: emit-height-changes
{ $description "Emits stack height change instructions to the CFG being built. This is done when a " { $link basic-block } " is begun or ended." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.local make namespaces prettyprint ;"
    "T{ current-height { emit-d 4 } { emit-r -2 } } current-height set [ emit-height-changes ] { } make ."
    "{ T{ ##inc-d { n 4 } } T{ ##inc-r { n -2 } } }"
  }
} ;
