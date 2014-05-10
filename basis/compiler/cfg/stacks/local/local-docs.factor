USING: compiler.cfg help.markup help.syntax ;
IN: compiler.cfg.stacks.local

HELP: current-height
{ $class-description "A tuple used to keep track of the heights of the data and retain stacks in a " { $link basic-block } "." } ;

HELP: emit-height-changes
{ $description "Emits stack height change instructions to the CFG being built." }
{ $examples
  { $example
    "USING: compiler.cfg.stacks.local make namespaces prettyprint ;"
    "T{ current-height { emit-d 4 } { emit-r -2 } } current-height set [ emit-height-changes ] { } make ."
    "{ T{ ##inc-d { n 4 } } T{ ##inc-r { n -2 } } }"
  }
} ;
