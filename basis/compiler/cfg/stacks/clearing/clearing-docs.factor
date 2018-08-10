USING: compiler.cfg compiler.cfg.instructions help.markup
help.syntax kernel sequences strings ;
IN: compiler.cfg.stacks.clearing

ARTICLE: "compiler.cfg.stacks.clearing" "Uninitialized stack location clearing"
"A compiler pass that inserts " { $link clear## } " instructions front of instructions which requires the whole stack to be initialized. Consider the following sequence of instructions:"
{ $code
  "inc## d: 2"
  "..."
  "allot##"
  "replace## ... d: 0"
  "replace## ... d: 1"
}
"The GC check runs before stack locations 0 and 1 have been initialized, so they need to be cleared as they can contain garbage data which could crash Factor if it tries to trace them. This is achieved by computing uninitialized locations with a dataflow analysis (see " { $vocab-link "compiler.cfg.stacks.padding" } ") and then inserting clears so that the instruction sequence becomes:"
{ $code
  "inc## d: 2"
  "..."
  "clear## d: 0"
  "clear## d: 1"
  "allot##"
  "replace## ... d: 0"
  "replace## ... d: 1"
}
"Similar dangerous stack 'holes' needs to be padded in the same way to guard unsafe " { $link peek## } " instructions. E.g:"
{ $code
  "inc## d: 2"
  "peek## RCX d: 2"
}
"Here the peek## can cause a stack underflow and then there will be two uninitialized locations on the captured data stack that can't be traced. As in the previous example, clears## are inserted on locations d: 0 and d: 1." ;

HELP: dangerous-insn?
{ $values { "state" "a stack state" } { "insn" insn } { "?" boolean } }
{ $description "Checks if the instruction is dangerous, meaning that the holes in the stack must be filled before it is executed." }
{ $examples
  { $example
    "USING: compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stacks.clearing prettyprint ;"
    "{ { 0 { } } { 0 { } } } T{ peek## { loc d: 0 } } dangerous-insn? ."
    "t"
  }
  { $example
    "USING: compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stacks.clearing prettyprint ;"
    "{ { 0 { } } { 2 { } } } T{ peek## { loc r: 0 } } dangerous-insn? ."
    "f"
  }
  { $example
    "USING: compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stacks.clearing prettyprint ;"
    "{ { 0 { } } { 3 { } } } T{ call-gc## } dangerous-insn? ."
    "t"
  }
} ;


ABOUT: "compiler.cfg.stacks.clearing"
