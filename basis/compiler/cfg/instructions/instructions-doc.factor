USING: help.markup help.syntax kernel layouts slots.private ;
IN: compiler.cfg.instructions

HELP: vreg-insn
{ $class-description
  "Base class for instructions that uses vregs."
} ;

HELP: ##inc-d
{ $class-description
  "An instruction that increases or decreases the data stacks size by n. For example, " { $link 2drop } " decreases it by two and pushing an item increases it by one."
} ;

HELP: ##alien-invoke
{ $class-description
  "An instruction for calling a function in a dynamically linked library."
} ;

HELP: ##set-slot
{ $class-description
  "An instruction for non-primitive non-immediate variant of " { $link set-slot } ". It has the following slots:"
  { $table
    { { $slot "src" } { "Object to put in the slot." } }
    { { $slot "obj" } { "Object to set the slot on." } }
    { { $slot "slot" } { "Slot index." } }
    { { $slot "tag" } { "Type tag for obj." } }
  }
}
{ $see-also ##set-slot-imm } ;

HELP: ##replace-imm
{ $class-description
  "An instruction that replaces an item on the data or register stack with an " { $link immediate } " value." } ;

HELP: ##replace
{ $class-description
  "Copies a value from a machine register to a stack location." }
{ $see-also ##peek ##replace-imm } ;


HELP: ##jump
{ $class-description
  "An uncondiation jump instruction. It has the following slots:"
  { $table
    { { $slot "word" } { "Word whose address the instruction is jumping to." } }
  }
  "Note that the optimizer is sometimes able to optimize away a " { $link ##call } " and " { $link ##return } " pair into one ##jump instruction."
} ;

HELP: ##peek
{ $class-description
  "Copies a value from a stack location to a machine register."
}
{ $see-also ##replace } ;
