USING: alien arrays assocs byte-arrays classes combinators
compiler.cfg compiler.cfg.builder compiler.cfg.intrinsics.fixnum
compiler.cfg.linear-scan.assignment compiler.cfg.liveness
compiler.cfg.ssa.destruction compiler.cfg.value-numbering
compiler.codegen.gc-maps compiler.tree cpu.architecture help.markup
help.syntax kernel layouts math sequences slots.private system vm ;
IN: compiler.cfg.instructions

HELP: ##alien-invoke
{ $class-description
  "An instruction for calling a function in a dynamically linked library. It has the following slots:"
  { $slots
    {
        "dead-outputs"
        { "A sequence of return values from the function that the compiler.cfg.dce pass has figured out are not used." }
    }
    {
        "reg-inputs"
        { "Registers to use for the arguments to the function call. Each sequence item is a 3-tuple consisting of a " { $link spill-slot } ", register representation and a register. When the function is called, the parameter is copied from the spill slot to the given register." }
    }
    {
        "stack-inputs"
        { "Stack slots used for the arguments to the function call." }
    }
    {
        "reg-outputs"
        { "If the called function returns a value, then this slot is a one-element sequence containing a 3-tuple describing which register is used for the return value." }
    }
    { "symbols" { "Name of the function to call." } }
    { "dll" { "A dll handle or " { $link f } "." } }
    {
        "gc-map"
        {
            "If the invoked C function calls Factor code which triggers a GC, then a "
            { $link gc-map }
            " is necessary to find the roots."
        }
    }
  }
  "Which function arguments that goes in " { $slot "reg-inputs" } " and which goes in " { $slot "stack-inputs" } " depend on the calling convention. In " { $link cdecl } " on " { $link x86.32 } ", all arguments goes in " { $slot "stack-inputs" } ", in " { $link x86.64 } " on " { $link unix } ", the first six arguments are passed in registers and then stack parameters are used for the remainder."
}
{ $see-also #alien-invoke %alien-invoke } ;

HELP: ##alien-indirect
{ $class-description
  "An instruction representing an indirect alien call. The first item on the datastack is a pointer to the function to call and the parameters follows. It has the following slots:"
  { $slots
    { "src" { "Spill slot containing the function pointer." } }
    { "reg-outputs" { "Sequence of output values passed in registers." } }
  }
}
{ $see-also alien-indirect %alien-indirect } ;

HELP: ##allot
{ $class-description
  "An instruction for allocating memory in the nursery. Usually the instruction is preceded by " { $link ##check-nursery-branch } " which checks that there is enough room in the nursery to allocate. It has the following slots:"
  { $slots
    { "dst" { "Register to put the pointer to the memory in." } }
    { "size" { "Number of bytes to allocate." } }
    { "class-of" { "Class of object to allocate, e.g " { $link tuple } " or " { $link array } "." } }
    { "temp" { "Temporary register to clobber." } }
  }
} ;

HELP: ##bit-count
{ $class-description "Specialized instruction for counting the number of lit bits in an integer." }
{ $see-also %bit-count } ;

HELP: ##box
{ $class-description
  "This instruction boxes a value into a tagged pointer."
} { $see-also %box } ;

HELP: ##box-alien
{ $class-description
  "An instruction for boxing an alien value."
} ;

HELP: ##call
{ $class-description
  "An instruction for calling a Factor word."
  { $slots
    { "word" { "The word called." } }
  }
} ;

HELP: ##check-nursery-branch
{ $class-description
  "Instruction that inserts a conditional branch to a " { $link basic-block } " that garbage collects the nursery. The " { $vocab-link "compiler.cfg.gc-checks" } " vocab goes through each block in the " { $link cfg } " and checks if it allocates memory. If it does, then this instruction is inserted in the cfg before that block and checks if there is enough available space in the nursery. If it isn't, then a basic block containing code for garbage collecting the nursery is executed."
  $nl
  "It has the following slots:"
  { $slots
    { "size" { "Number of bytes the next block in the cfg will allocate." } }
    { "cc" { "A comparison symbol." } }
    { "temp1" { "First register that will be clobbered." } }
    { "temp2" { "Second register that will be clobbered." } }
  }
}
{ $see-also %check-nursery-branch } ;

HELP: ##compare-float-ordered-branch
{ $class-description
  "It has the following slots:"
  { $slots
    { "cc" { "Comparison symbol." } }
  }
} ;

HELP: ##compare-imm
{ $class-description "Instruction used to implement trivial ifs and not ifs." }
{ $see-also emit-trivial-if emit-trivial-not-if } ;

HELP: ##compare-imm-branch
{ $class-description "The instruction used to implement branching for the " { $link if } " word." } ;

HELP: ##compare-integer
{ $class-description "This instruction is emitted for " { $link fixnum } " comparisons." }
{ $see-also emit-fixnum-comparison } ;

HELP: ##copy
{ $class-description "Instruction that copies a value from one register to another of the same type. For example, you can copy between two gprs or two simd registers but not across. It has the following slots:"
  { $slots
    { "rep" { "Value representation. Both the source and destination register must have the same representation." } }
  }
} ;

HELP: ##dispatch
{ $class-description "Special instruction for implementing " { $link case } " blocks." } ;

HELP: ##fixnum-add
{ $class-description "Instruction for adding two fixnums together." }
{ $see-also emit-fixnum+ } ;

HELP: ##inc
{ $class-description
  "An instruction that increases or decreases a stacks height by n. For example, " { $link 2drop } " decreases the datastacks height by two and pushing an item increases it by one."
} ;

HELP: ##jump
{ $class-description
  "An uncondiation jump instruction. It has the following slots:"
  { $slots
    { "word" { "Word whose address the instruction is jumping to." } }
  }
  "Note that the optimizer is sometimes able to optimize away a " { $link ##call } " and " { $link ##return } " pair into one ##jump instruction."
} ;

HELP: ##load-double
{ $class-description "Loads a " { $link float } " into a SIMD register." }
{ $see-also %load-double } ;

HELP: ##load-memory-imm
{ $class-description "Instruction for loading data from memory into a register. Either a General Purpose or an SSE register." }
{ $see-also %load-memory-imm } ;

HELP: ##load-reference
{ $class-description
  "An instruction for loading a pointer to an object into a register. It has the following slots:"
  { $slots
    { "dst" { "Register to load the pointer into." } }
    { "obj" { "A Factor object." } }
  }
} ;

HELP: ##load-tagged
{ $class-description "Loads a tagged value into a register." } ;

HELP: ##load-vector
{ $class-description
  "Loads a " { $link byte-array } " into an SSE register."
}
{ $see-also %load-vector } ;

HELP: ##local-allot
{ $class-description
  "An instruction for allocating memory in the words own stack frame. It's mostly used for receiving data from alien calls. It has the following slots:"
  { $slots
    { "dst" { "Register into which a pointer to the stack allocated memory is put." } }
    { "size" { "Number of bytes to allocate." } }
    { "offset" { } }
  }
}
{ $see-also ##allot } ;

HELP: ##mul-vector
{ $class-description
  "SIMD instruction." } ;

HELP: ##no-tco
{ $class-description "A dummy instruction that simply inhibits TCO." } ;

HELP: ##parallel-copy
{ $class-description "An instruction for performing multiple copies. It allows for optimizations or (or prunings) if more than one source or destination vreg is the same. They are transformed into " { $link ##copy } " instructions in " { $link destruct-ssa } ". It has the following slots:"
  { $slots
    { "values" { "An assoc mapping source vregs to destinations." } }
  }
} ;

HELP: ##peek
{ $class-description
  "Copies a value from a stack location to a machine register."
}
{ $see-also ##replace } ;

HELP: ##phi
{ $class-description
  "A special kind of instruction used to mark control flow. It is inserted by the " { $vocab-link "compiler.cfg.ssa.construction" } " vocab. It has the following slots:"
  { $slots
    { "inputs" { "An assoc containing as keys the blocks/block numbers where the vreg was defined and as values the vreg. Why care about the blocks?" } }
    { "dst" { "A merged vreg for the value." } }
  }
} ;

HELP: ##prologue
{ $class-description
  "An instruction for generating the prologue for a cfg. All it does is decrementing the stack register a number of cells to give the generated code some stack space to work with." }
  { $see-also ##epilogue } ;

HELP: ##reload
{ $class-description "Instruction that copies a value from a " { $link spill-slot } " to a register." } ;

HELP: ##replace
{ $class-description "Copies a value from a machine register to a stack location." }
{ $see-also ##peek ##replace-imm } ;

HELP: ##replace-imm
{ $class-description "An instruction that replaces an item on the data or register stack with an " { $link immediate } " value. The " { $link value-numbering } " compiler optimization pass can sometimes rewrite " { $link ##replace } " instructions to ##replace-imm's." }
{ $see-also ##replace } ;


HELP: ##return
{ $class-description "Instruction that returns from a procedure call." } ;

HELP: ##safepoint
{ $class-description "Instruction that inserts a safe point in the generated code." } ;

HELP: ##save-context
{ $class-description "The ##save-context instructions saves the state of the data, retain and callstacks in the threads " { $link context } " struct." }
{ $see-also %save-context } ;

HELP: ##set-slot
{ $class-description
  "An instruction for the non-primitive, non-immediate variant of " { $link set-slot } ". It has the following slots:"
  { $slots
    { "src" { "Object to put in the slot." } }
    { "obj" { "Object to set the slot on." } }
    { "slot" { "Slot index." } }
    { "tag" { "Type tag for obj." } }
  }
} ;

HELP: ##set-slot-imm
{ $class-description
  "An instruction for what? It has the following slots:"
  { $slots
    { "src" { "Register containing the value to put in the slot." } }
    { "obj" { "Register containing the object to set the slot on.." } }
    { "slot" { "Slot index." } }
    { "tag" { "Type tag for obj." } }
  }
}
{ $see-also ##set-slot %set-slot-imm } ;

{ ##set-slot-imm ##set-slot } related-words

HELP: ##single>double-float
{ $class-description "Converts a single precision value (32-bit usually) stored in a SIMD register to a double precision one (64-bit usually)." } ;

HELP: ##shuffle-vector-imm
{ $class-description "Shuffles the vector in a SSE register according to the given shuffle pattern. It is used to extract a given element of the vector."
  { $slots
    { "dst" { "Destination register to shuffle the vector to." } }
    { "src" { "Source register." } }
    { "shuffle" { "Shuffling pattern." } }
  }
}
{ $see-also %shuffle-vector-imm } ;

HELP: ##slot-imm
{ $class-description
  "Instruction for reading a slot with a given index from an object."
  { $slots
    { "dst" { "Register to read the slot value into." } }
    { "obj" { "Register containing the object with the slot." } }
    { "slot" { "Slot index." } }
    { "tag" { "Type tag for obj." } }
  }
} { $see-also %slot-imm } ;

HELP: ##spill
{ $class-description "Instruction that copies a value from a register to a " { $link spill-slot } "."
  { $slots
    { "rep" { "Register representation which is necessary when spilling SIMD registers." } }
  }
} { $see-also ##reload } ;

HELP: ##store-memory-imm
{ $class-description "Instruction that copies an 8 byte value from a XMM register to a memory location addressed by a normal register. This instruction is often turned into a cheaper " { $link ##store-memory } " instruction in the " { $link value-numbering } " pass."
  { $slots
    { "base" { "Vreg that contains the base address." } }
    {
        "offset"
        { "Offset in bytes from the address to where the data should be written." }
    }
    { "rep" { "Value representation in the vector register." } }
    { "src" { "Vreg that contains the item to set." } }
  }
}
{ $see-also %store-memory-imm } ;

HELP: ##test-branch
{ $class-description "Instruction inserted by the " { $vocab-link "compiler.cfg.value-numbering" } " compiler pass." }
{ $see-also ##compare-integer-imm-branch } ;

HELP: ##unbox-any-c-ptr
{ $class-description "Instruction that unboxes a pointer in a register so that it can be fed to a C FFI function. For example, if 'src' points to a " { $link byte-array } ", then in 'dst' will be put a pointer to the first byte of that byte array."
  { $slots
    { "dst" { "Destination register." } }
    { "src" { "Source register." } }
  }
}
{ $see-also %unbox-any-c-ptr } ;

HELP: ##unbox-long-long
{ $class-description "Instruction that unboxes a 64-bit integer to two 32-bit registers. Only used on 32 bit architectures." } ;

HELP: ##vector>scalar
{ $class-description
  "This instruction is very similar to " { $link ##copy } "."
  { $slots
    { "dst" { "destination vreg" } }
    { "src" { "source vreg" } }
    { "rep" { "representation for the source vreg" } }
  }
}
{ $notes "The two vregs must not necessarily share the same representation." }
{ $see-also %vector>scalar } ;

HELP: ##vm-field
{ $class-description "Instruction for loading a pointer to a vm field."
  { $slots
    { "dst" { "Register to load the field into." } }
    { "offset" { "Offset of the field relative to the vm address." } }
  }
}
{ $see-also %vm-field } ;

HELP: ##write-barrier
{ $class-description
  "An instruction for inserting a write barrier. This instruction is almost always inserted after a " { $link ##set-slot } " instruction. If the container object is in an older generation than the item inserted, this instruction guarantees that the item will not be garbage collected. It has the following slots:"
  { $slots
    { "src" { "Object to which the writer barrier refers." } }
    { "slot" { "Slot index of the object." } }
    { "scale" { "No idea." } }
    { "tag" { "Type tag for obj." } }
    { "temp1" { "First temporary register to clobber." } }
    { "temp2" { "Second temporary register to clobber." } }
  }
} ;

HELP: alien-call-insn
{ $class-description "Union class of all alien call instructions." } ;

HELP: allocation-insn
{ $class-description "Union class of all instructions that allocate memory." } ;

HELP: def-is-use-insn
{ $class-description "Union class of instructions that have complex expansions and require that the output registers are not equal to any of the input registers." } ;

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

HELP: gc-map-insn
{ $class-description "Union class of all instructions that contain subroutine calls to functions which allocate memory. Each of the instances has a " { $snippet "gc-map" } " slot." } ;

HELP: gc-map
{ $class-description "A tuple that holds info necessary for a gc cycle to figure out where the gc root pointers are. It has the following slots:"
  { $slots
    {
        "gc-roots"
        { { $link sequence } " of vregs or spill-slots" }
    }
    {
        "derived-roots"
        { "An " { $link assoc } " of pairs of vregs or spill slots." } }
  }
  "The 'gc-roots' and 'derived-roots' slots are initially vreg integers referencing objects that are live during the gc call and needs to be spilled so that they can be traced. In the " { $link emit-gc-map-insn } " word in " { $vocab-link "compiler.cfg.linear-scan.assignment" } " they are converted to spill slots which the collector is able to trace."
}
{ $see-also emit-gc-info-bitmap fill-gc-map } ;

ARTICLE: "compiler.cfg.instructions" "Basic block instructions"
"The " { $vocab-link "compiler.cfg.instructions" } " vocab contains all instruction classes used for generating CFG:s (Call Flow Graphs)."
$nl
"All instructions are tuples prefixed with '##' and inheriting from the base class " { $link insn } ". Most instructions are coupled with a generic word in " { $vocab-link "cpu.architecture" } " which emits machine code for it. For example, " { $link %copy } " emits code for " { $link ##copy } " instructions."
$nl
"Instruction classes for moving values around:"
{ $subsections
  ##copy
  ##parallel-copy
  ##peek
  ##reload
  ##replace
  ##replace-imm
  ##spill
}
"Control flow:"
{ $subsections
  ##branch
  ##call
  ##jump
  ##no-tco
  ##phi
  ##return
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
  ##local-allot
  ##save-context
  allocation-insn
  gc-map
  gc-map-insn
  <gc-map>
}
"Comparison instructions:"
{ $subsections
  ##compare
  ##compare-imm
  ##compare-imm-branch
  ##compare-integer
  ##compare-integer-branch
  ##compare-integer-imm-branch
  ##test
  ##test-branch
  ##test-imm
  ##test-imm-branch
}
"Constant loading:"
{ $subsections
  ##load-integer
  ##load-reference
  ##load-tagged
}
"Floating point SIMD instructions:"
{ $subsections
  ##add-float
  ##div-float
  ##mul-float
  ##sub-float
}
 "Integer arithmetic and bit operations:"
{ $subsections
  ##add
  ##add-imm
  ##and
  ##and-imm
  ##fixnum-add
  ##fixnum-sub
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
  ##write-barrier
}
"SIMD instructions"
{ $subsections
  ##add-vector
  ##add-sub-vector
  ##bit-count
  ##compare-float-ordered-branch
  ##div-vector
  ##horizontal-add-vector
  ##horizontal-sub-vector
  ##load-double
  ##load-vector
  ##mul-vector
  ##shuffle-vector-imm
  ##single>double-float
  ##store-memory-imm
  ##sub-vector
  ##vector>scalar
}
"Stack height manipulation:"
{ $subsections
  ##inc
} ;

ABOUT: "compiler.cfg.instructions"
