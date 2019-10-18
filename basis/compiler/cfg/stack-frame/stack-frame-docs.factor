USING: help.markup help.syntax ;
IN: compiler.cfg.stack-frame

HELP: stack-frame
{ $class-description "Counts of, among other things, how much stack a compiled word needs. It has the following slots:"
  { $table
    { { $slot "total-size" } { "Total size of the stack frame." } }
    { { $slot "spill-area-size" } { "Number of bytes requires for all spill slots." } }
  }
} ;
