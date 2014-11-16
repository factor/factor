USING: arrays assocs classes compiler.cfg compiler.codegen.gc-maps
cpu.architecture help.markup help.syntax kernel layouts sequences
slots.private ;
IN: compiler.cfg.instructions

HELP: new-insn
{ $values { "class" class } { "insn" insn } }
{ $description
  "Boa wrapper for the " { $link insn } " class with " { $slot "insn#" } " set to " { $link f } "."
} ;

HELP: insn
{ $class-description
  "Base class for all virtual cpu instructions, used by the CFG IR."
} ;

HELP: vreg-insn
{ $class-description
  "Base class for instructions that uses vregs."
} ;

HELP: flushable-insn
{ $class-description
  "Instructions which do not have side effects; used for dead code elimination." } ;

HELP: foldable-insn
{ $class-description
  "Instructions which are referentially transparent; used for value numbering." } ;

HELP: ##load-reference
{ $class-description
  "An instruction for loading a pointer to an object into a register. It has the following slots:"
  { $table
    { { $slot "dst" } { "Register to load the pointer into." } }
    { { $slot "obj" } { "A Factor object." } }
  }
} ;

HELP: ##inc-d
{ $class-description
  "An instruction that increases or decreases the data stacks height by n. For example, " { $link 2drop } " decreases it by two and pushing an item increases it by one."
} ;

HELP: ##prologue
{ $class-description
  "An instruction for generating the prologue for a cfg. All it does is decrementing the stack register a number of cells to give the generated code some stack space to work with." }
  { $see-also ##epilogue } ;

HELP: ##allot
{ $class-description
  "An instruction for allocating memory in the nursery. Usually the instruction is preceeded by " { $link ##check-nursery-branch } " which checks that there is enough room in the nursery to allocate. It has the following slots:"
  { $table
    { { $slot "dst" } { "Register to put the pointer to the memory in." } }
    { { $slot "size" } { "Number of bytes to allocate." } }
    { { $slot "class-of" } { "Class of object to allocate, e.g " { $link tuple } " or " { $link array } "." } }
    { { $slot "temp" } { "Temporary register to clobber." } }
  }
} ;

HELP: ##alien-invoke
{ $class-description
  "An instruction for calling a function in a dynamically linked library. It has the following slots:"
  { $table
    { { $slot "reg-inputs" } { "Registers to use for the arguments to the function call." } }
    { { $slot "stack-inputs" } { "Stack slots used for the arguments to the function call. Only used if all register arguments are already filled." } }
    {
        { $slot "reg-outputs" }
        { "If the called function returns a value, then this slot is a one-element sequence containing a 3-tuple describing which register is used for the return value." }
    }
    { { $slot "symbols" } { "Name of the function to call." } }
    { { $slot "dll" } { "A dll handle." } }
  }
} ;

HELP: alien-call-insn
{ $class-description "Union class of all alien call instructions." } ;

HELP: def-is-use-insn
{ $class-description "Union class of instructions that have complex expansions and require that the output registers are not equal to any of the input registers." } ;

HELP: ##call
{ $class-description
  "An instruction for calling a Factor word."
} ;

HELP: ##set-slot
{ $class-description
  "An instruction for the non-primitive, non-immediate variant of " { $link set-slot } ". It has the following slots:"
  { $table
    { { $slot "src" } { "Object to put in the slot." } }
    { { $slot "obj" } { "Object to set the slot on." } }
    { { $slot "slot" } { "Slot index." } }
    { { $slot "tag" } { "Type tag for obj." } }
  }
} ;

HELP: ##set-slot-imm
{ $class-description
  "An instruction for what? It has the following slots:"
  { $table
    { { $slot "src" } { "Register containing the value to put in the slot." } }
    { { $slot "obj" } { "Register containing the object to set the slot on.." } }
    { { $slot "slot" } { "Slot index." } }
    { { $slot "tag" } { "Type tag for obj." } }
  }
} ;

{ ##set-slot %set-slot } related-words
{ ##set-slot-imm %set-slot-imm } related-words
{ ##set-slot-imm ##set-slot } related-words

HELP: ##replace-imm
{ $class-description
  "An instruction that replaces an item on the data or register stack with an " { $link immediate } " value." } ;

HELP: ##replace
{ $class-description
  "Copies a value from a machine register to a stack location." }
  { $see-also ##peek ##replace-imm } ;

HELP: ##box-alien
{ $class-description
  "An instruction for boxing an alien value."
} ;

HELP: ##write-barrier
{ $class-description
  "An instruction for inserting a write barrier. This instruction is almost always inserted after a " { $link ##set-slot } " instruction. It has the following slots:"
  { $table
    { { $slot "src" } { "Object which the writer barrier refers." } }
    { { $slot "slot" } { "Slot index of the object." } }
    { { $slot "tag" } { "Type tag for obj." } }
    { { $slot "temp1" } { "First temporary register to clobber." } }
    { { $slot "temp2" } { "Second temporary register to clobber." } }
  }
} ;

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

HELP: ##safepoint
{ $class-description "Instruction that inserts a safe point in the generated code." } ;

HELP: ##check-nursery-branch
{ $class-description
  "Instruction that inserts a conditional branch to a " { $link basic-block } " that garbage collects the nursery. The " { $vocab-link "compiler.cfg.gc-checks" } " vocab goes through each block in the " { $link cfg } " and checks if it allocates memory. If it does, then this instruction is inserted in the cfg before that block and checks if there is enough available space in the nursery. If it isn't, then a basic block containing code for garbage collecting the nursery is executed."
  $nl
  "It has the following slots:"
  { $table
    { { $slot "size" } { "Number of bytes the next block in the cfg will allocate." } }
    { { $slot "cc" } { "A comparison symbol." } }
    { { $slot "temp1" } { "Register symbol." } }
    { { $slot "temp2" } { "Register symbol." } }
  }
} ;

HELP: ##return
{ $class-description "Instruction that returns from a procedure call." } ;

HELP: ##no-tco
{ $class-description "A dummy instruction that simply inhibits TCO." } ;

HELP: ##copy
{ $class-description "Instruction that copies a value from one register to another." } ;

HELP: ##compare-integer
{ $class-description "This instruction is emitted for integer comparisons." } ;

HELP: ##spill
{ $class-description "Instruction that copies a value from a register to a " { $link spill-slot } "." } ;

HELP: gc-map-insn
{ $class-description "Union class of all instructions that contain subroutine calls to functions which allocate memory. Each of the has a " { $slot "gc-map" } " slot." } ;

HELP: gc-map
{ $class-description "A tuple that holds info necessary for a gc cycle to figure out where the gc root pointers are. It has the following slots:"
  { $table
    { { $slot "gc-roots" } { "A " { $link sequence } " of " { $link spill-slot } " which will be traced in a gc cycle. " } }
    { { $slot "derived-roots" } { "An " { $link assoc } " of pairs of spill slots." } }
  }
}
{ $see-also emit-gc-info-bitmaps } ;

ARTICLE: "compiler.cfg.instructions" "Basic block instructions"
"The " { $vocab-link "compiler.cfg.instructions" } " vocab contains all instruction classes used for generating CFG:s (Call Flow Graphs)."
$nl
"Instruction classes for moving values around:"
{ $subsections
  ##copy
  ##peek
  ##reload
  ##replace
  ##replace-imm
  ##spill
}
"Control flow:"
{ $subsections
  ##call
  ##jump
  ##no-tco
  ##phi
  ##return
}
"Comparison instructions:"
{ $subsections
  ##compare
  ##compare-imm
  ##compare-integer
  ##compare-integer-branch
  ##compare-integer-imm-branch
  ##test
  ##test-branch
  ##test-imm
  ##test-imm-branch
}
"Alien calls and FFI:"
{ $subsections
  ##alien-assembly
  ##alien-indirect
  ##alien-invoke
  ##box
  ##box-alien
  ##box-displaced-alien
  ##box-long-long
  ##callback-inputs
  ##callback-outputs
  ##local-allot
  ##unbox
  ##unbox-alien
  ##unbox-any-c-ptr
  ##unbox-long-long
  alien-call-insn
}
"Allocation and garbage collection:"
{ $subsections
  ##allot
  ##call-gc
  ##check-nursery-branch
  gc-map
  gc-map-insn
  <gc-map>
}
"Constant loading:"
{ $subsections
  ##load-integer
  ##load-reference
}
 "Integer arithmetic and bit operations:"
{ $subsections
  ##add
  ##add-imm
  ##and
  ##and-imm
  ##mul
  ##mul-imm
  ##neg
  ##not
  ##or
  ##or-imm
  ##sar
  ##sar-imm
  ##shl
  ##shl-imm
  ##shr
  ##shr-imm
  ##sub
  ##sub-imm
  ##xor
  ##xor-imm
}
"Slot access:"
{ $subsections
  ##slot
  ##slot-imm
  ##set-slot
  ##set-slot-imm
}
"Stack height manipulation:"
{ $subsections
  ##inc-d
  ##inc-r
} ;

ABOUT: "compiler.cfg.instructions"
