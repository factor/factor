USING: compiler.cfg.instructions help.markup help.syntax layouts math ;
IN: compiler.cfg.stack-frame

HELP: stack-frame
{ $class-description "Counts in bytes of the various sizes of the blocks of the stack frame. The stack frame is organized in the following fashion, from bottom to top:"
  { $list
    "Parameter space: space for parameters to FFI functions "
    "Allocation area: space for local allocations."
    "Spill area: space for register spills."
    { "Reserved stack space: only applicable on Windows x86.64. See " { $snippet "reserved-stack-space" } "." }
    { "One final " { $link cell } " of padding." }
  }
  "The stack frame is also aligned to a 16 byte boundary. It has the following slots:"
  { $slots
    { "total-size" { "Total size of the stack frame." } }
    { "params" { "Reserved parameter space." } }
    { "allot-area-base" { "Base offset of the allocation area." } }
    { "allot-area-size" { "Number of bytes requires for the allocation area." } }
    { "allot-area-align" { "This slot is always at least " { $link cell } " bytes." } }
    { "spill-area-base" { "Base offset for the spill area." } }
    { "spill-area-size" { "Number of bytes requires for all spill slots." } }
    { "spill-area-align" { "This slot is always at least " { $link cell } " bytes." } }
  }
  "See also " { $snippet "align-stack" } " of the " { $vocab-link "cpu.x86" } " vocabulary."
} ;

HELP: (stack-frame-size)
{ $values { "stack-frame" stack-frame } { "n" integer } }
{ $description "Base stack frame size, without padding and alignment. If the size is zero, then no " { $link ##epilogue } " and " { $link ##prologue } " needs to be emitted for the word." } ;

ARTICLE: "compiler.cfg.stack-frame" "Stack frames"
"This vocab contains definitions for constructing stack frames." ;

ABOUT: "compiler.cfg.stack-frame"
