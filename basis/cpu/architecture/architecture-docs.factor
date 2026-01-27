USING: alien assocs classes compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stack-frame help.markup
help.syntax kernel layouts literals math multiline sequences
strings system vm words ;
IN: cpu.architecture

<<
STRING: ex-%allot
USING: cpu.architecture make ;
[ RAX 40 tuple RCX %allot ] B{ } make disassemble
0000000002270cc0: 498d4d10        lea rcx, [r13+0x10]
0000000002270cc4: 488b01          mov rax, [rcx]
0000000002270cc7: 48c7001c000000  mov qword [rax], 0x1c
0000000002270cce: 4883c807        or rax, 0x7
0000000002270cd2: 48830130        add qword [rcx], 0x30
;

STRING: ex-%box-alien
USING: compiler.codegen compiler.codegen.relocation cpu.architecture make ;
[ RAX RBX RCX %box-alien ] with-fixup 4 swap nth disassemble
000000e9fcc720a0: 48b80100000000000000  mov eax, 0x1
000000e9fcc720aa: 4885db                test rbx, rbx
000000e9fcc720ad: 0f8400000000          jz dword 0xe9fcc720b3
000000e9fcc720b3: 498d4d10              lea rcx, [r13+0x10]
000000e9fcc720b7: 488b01                mov rax, [rcx]
000000e9fcc720ba: 48c70018000000        mov qword [rax], 0x18
000000e9fcc720c1: 4883c806              or rax, 0x6
000000e9fcc720c5: 48830130              add qword [rcx], 0x30
000000e9fcc720c9: 48c7400201000000      mov qword [rax+0x2], 0x1
000000e9fcc720d1: 48c7400a01000000      mov qword [rax+0xa], 0x1
000000e9fcc720d9: 48895812              mov [rax+0x12], rbx
000000e9fcc720dd: 4889581a              mov [rax+0x1a], rbx
;

STRING: ex-%context
USING: cpu.architecture make ;
[ EAX %context ] B{ } make disassemble
00000000010f5ed0: 418b4500  mov eax, [r13]
;

STRING: ex-%copy
USING: cpu.architecture make ;
RAX RBX int-rep [ %copy ] B{ } make disassemble
000000000108a970: 4889d8  mov rax, rbx
;

STRING: ex-%safepoint
USING: cpu.architecture make ;
init-relocation [ %safepoint ] B{ } make disassemble
00000000010b05a0: 890500000000  mov [rip], eax
;

STRING: ex-%save-context
USING: cpu.architecture make ;
[ RAX RBX %save-context ] B{ } make disassemble
0000000000e63ab0: 498b4500    mov rax, [r13]
0000000000e63ab4: 488d5c24f8  lea rbx, [rsp-0x8]
0000000000e63ab9: 488918      mov [rax], rbx
0000000000e63abc: 4c897010    mov [rax+0x10], r14
0000000000e63ac0: 4c897818    mov [rax+0x18], r15
;

STRING: ex-%write-barrier
USING: cpu.architecture make tools.disassembler ;
init-relocation [ RAX RBX 3 -14 RCX RDX %write-barrier ] B{ } make disassemble
000000000143f960: 488d4cd80e            lea rcx, [rax+rbx*8+0xe]
000000000143f965: 48c1e908              shr rcx, 0x8
000000000143f969: 48ba0000000000000000  mov rdx, 0x0
000000000143f973: 48c60411c0            mov byte [rcx+rdx], 0xc0
000000000143f978: 48c1e90a              shr rcx, 0xa
000000000143f97c: 48ba0000000000000000  mov rdx, 0x0
000000000143f986: 48c60411c0            mov byte [rcx+rdx], 0xc0
;
>>

HELP: %alien-invoke
{ $values
  { "varargs?" boolean }
  { "reg-inputs" sequence }
  { "stack-inputs" sequence }
  { "reg-outputs" sequence }
  { "dead-outputs" sequence }
  { "cleanup" integer }
  { "stack-size" integer }
  { "symbol" string }
  { "dll" { $maybe dll } }
  { "gc-map" gc-map }
}
{ $description "Machine code emitter for the " { $link ##alien-invoke } " instruction." } ;


HELP: %allot
{ $values
  { "dst" "destination register symbol" }
  { "size" "number of bytes to allocate" }
  { "class" "one of the built-in classes listed in " { $link type-numbers } }
  { "temp" "temporary register symbol" }
}
{ $description "Emits machine code for allocating memory." }
{ $examples
  "In this example 40 bytes is allocated and a tagged pointer to the memory is put in " { $snippet RAX } ":"
  { $unchecked-example $[ ex-%allot ] }
} ;

HELP: %and-imm
{ $values
  { "dst" "destination register" }
  { "src1" "first source register" }
  { "src2" "second source register" }
}
{ $description "Emits an " { $snippet AND } " instruction between a register and an immediate." } ;

HELP: %box
{ $values
  { "dst" "destination register" }
  { "src" "source register" }
  { "func" "function?" }
  { "rep" "representation class" }
  { "gc-map" gc-map }
}
{ $description "Call a function to convert a value into a tagged pointer, possibly allocating a bignum, float, or alien instance, which is then pushed on the data stack." } ;

HELP: %box-alien
{ $values
  { "dst" "destination register" }
  { "src" "register containing pointer to the alien" }
  { "temp" "temporary register" }
}
{ $description "Emits machine code for boxing an alien value. If the alien is not a NULL pointer, then five " { $link cells } " will be allocated in the nursery space to wrap the object. See vm/layouts.hpp for details." }
{ $examples { $unchecked-example $[ ex-%box-alien ] } }
{ $see-also ##box-alien %allot } ;

HELP: %call
{ $values { "word" word } }
{ $description "Emits code for calling a Factor word." } ;

HELP: %c-invoke
{ $values { "symbol" string } { "dll" dll } { "gc-map" gc-map } }
{ $description "Emits code for calling an FFI function." } ;

HELP: %check-nursery-branch
{ $values
  { "label" "label" }
  { "size" integer }
  { "cc" "comparison symbol" }
  { "temp1" "first temporary register" }
  { "temp2" "second temporary register" }
}
{ $description "Emits code for jumping to the nursery garbage collection block if an allocation of size 'size' requires a garbage collection." } ;

HELP: %context
{ $values { "dst" "a register symbol" } }
{ $description "Emits machine code for putting a pointer to the context field of the " { $link vm } " in a register." }
{ $examples { $unchecked-example $[ ex-%context ] } } ;

HELP: %copy
{ $values { "dst" "destination" } { "src" "source" } { "rep" representation } }
{ $description "Emits code copying a value from a register, arbitrary memory location or " { $link spill-slot } " to a destination." }
{ $examples { $unchecked-example $[ ex-%copy ] } } ;

HELP: %dispatch
{ $values { "src" "a register symbol" } { "temp" "a register symbol" } }
{ $description "Code emitter for the " { $link ##dispatch } " instruction." } ;

HELP: %horizontal-add-vector
{ $values
  { "dst" "destination register symbol" }
  { "src1"  "first source register" }
  { "src2" "second source register" }
  { "rep" "representation" }
}
{ $description "Emits machine code for performing a horizontal add, meaning that adjacent elements in the same operand are added together. So if the two vectors are (a0, a1, a2, a3) and (b0, b1, b2, b3) then the result is (a0 + a1, a2 + a3, b0 + b1, b2 + b3)." }
{ $examples
  { $unchecked-example
    "USING: cpu.architecture make tools.disassembler ;"
    "[ XMM0 XMM1 XMM2 float-4-rep %horizontal-add-vector ] B{ } make disassemble"
    "0000000002660870: 0f28c1    movaps xmm0, xmm1"
    "0000000002660873: f20f7cc2  haddps xmm0, xmm2"
  }
} ;

HELP: %load-double
{ $values
  { "reg" "destination register symbol" }
  { "val" float }
} { $description "Loads a literal floating point value into a register. On x86, this corresponds to the " { $snippet MOVSD } " instruction." }
{ $see-also ##load-double } ;

HELP: %load-immediate
{ $values { "reg" "a register symbol" } { "val" "a value" } }
{ $description "Emits code for loading an immediate value into a register. On " { $link x86 } ", if val is 0, then an " { $snippet XOR } " instruction is emitted instead of " { $snippet MOV } " because the former is shorter." }
{ $see-also ##load-tagged } ;

HELP: %load-memory-imm
{ $values
  { "dst" "destination register" }
  { "base" "base gpr for memory address" }
  { "offset" "memory offset" }
  { "rep" "representation" }
  { "c-type" "no idea" }
}
{ $description "Emits code for loading a value from memory into a SIMD register." }
{ $examples
  { $unchecked-example
    "USING: cpu.architecture make tools.disassembler ;"
    "[ XMM0 RCX 7 float-4-rep f %load-memory-imm ] B{ } make disassemble"
    "0000000002633800: 480f284107  movaps xmm0, [rcx+0x7]"
  }
} ;

HELP: %local-allot
{ $values
  { "dst" "destination register symbol" }
  { "size" "number of bytes to allocate" }
  { "align" "alignment" }
  { "offset" "where to allocate the data, relative to the stack register" }
}
{ $description "Emits machine code for stack \"allocating\" a chunk of memory. No memory is really allocated and instead a pointer to it is just put in the destination register." }
{ $see-also ##local-allot } ;

HELP: %replace-imm
{ $values
  { "src" integer }
  { "loc" loc }
}
{ $description "Emits machine code for putting a literal on the stack." }
{ $examples
  { $unchecked-example
    "USING: cpu.architecture make ;"
    "[ 777 D: 0 %replace-imm ] B{ } make disassemble"
    "0000000000aad8c0: 49c70690300000  mov qword [r14], 0x3090"
  }
} ;

HELP: %safepoint
{ $description "Emits a safe point to the current code sequence being generated." }
{ $examples { $unchecked-example $[ ex-%safepoint ] } } ;

HELP: %save-context
{ $values { "temp1" "a register symbol" } { "temp2" "a register symbol" } }
{ $description "Emits machine code for saving pointers to the callstack, datastack and retainstack in the current context field struct." }
{ $examples { $unchecked-example $[ ex-%save-context ] } } ;

HELP: %set-slot
{ $values
  { "src" "register containing the element" }
  { "obj" "register containing the object" }
  { "slot" "register containing the slot index" }
  { "scale" fixnum }
  { "tag" "type tag for the builtin" }
} { $description "Emits machine code for " { $link ##set-slot } " instructions." }
{ $examples
  { $unchecked-example
    "USING: cpu.architecture prettyprint ;"
    "[ RAX RBX RCX 3 2 %set-slot ] B{ } make disassemble"
    "0000000000f1fda0: 488944cbfe  mov [rbx+rcx*8-0x2], rax"
  }
} ;

HELP: %shl-imm
{ $values
  { "dst" "register" }
  { "src1" "register" }
  { "src2" integer }
} { $description "Bitshifts the value in a register left by a constant." }
{ $see-also ##shl-imm } ;

HELP: %spill
{ $values
  { "src" "source register" }
  { "rep" representation }
  { "dst" spill-slot }
} { $description "Emits machine code for spilling a register to a spill slot." }
{ $see-also %reload } ;

HELP: %store-memory-imm
{ $values
  { "value" "source register" }
  { "base" "base register for memory" }
  { "offset" "memory offset" }
  { "rep" "representation" }
  { "c-type" "a c type or " { $link f } }
}
{ $description "Emits machine code for " { $link ##store-memory-imm } " instructions." }
{ $examples
  { $unchecked-example
    "USING: cpu.architecture prettyprint ;"
    "[ XMM0 RBX 5 double-rep f %store-memory-imm ] B{ } make disassemble"
    "0000000002800ae0: f2480f114305  movsd [rbx+0x5], xmm0"
  }
} ;

HELP: %test-imm-branch
{ $values
  { "label" "branch destination" }
  { "src1" "register" }
  { "src2" "immediate" }
  { "cc" "comparison symbol" }
} { $description "Emits a TEST instruction with a register and an immediate, followed by a branch." } ;

HELP: %unbox
{ $values
  { "dst" "destination register" }
  { "src" "source register" }
  { "func" "function?" }
  { "rep" representation }
}
{ $description "Call a function to convert a tagged pointer into a value that can be passed to a C function, or returned from a callback." } ;

HELP: %vector>scalar
{ $values
  { "dst" "destination register" }
  { "src" "source register" }
  { "rep" representation }
}
{ $description "Converts the contents of a SIMD register to a scalar. On x86 this instruction is a noop." } ;

HELP: %write-barrier
{ $values
  { "src" "a register symbol" }
  { "slot" "a register symbol" }
  { "scale" integer }
  { "tag" integer }
  { "temp1" "a register symbol" }
  { "temp2" "a register symbol" }
}
{ $description "Generates code for the " { $link ##write-barrier } " instruction." }
{ $examples { $unchecked-example $[ ex-%write-barrier ] } } ;

HELP: complex-addressing?
{ $values { "?" boolean } }
{ $description "Specifies if " { $link %slot } ", " { $link %set-slot } " and " { $link %write-barrier } " accept the 'scale' and 'tag' parameters, and if %load-memory and %store-memory work." } ;

HELP: double-2-rep
{ $var-description "Representation for a pair of doubles." } ;

HELP: dummy-fp-params?
{ $values { "?" boolean } }
{ $description "Whether the architecture's ABI uses dummy floating point parameters. If it does, then the corresponding floating point register is 'dummy allocated' when an integer register is allocated." } { $see-also dummy-int-params? } ;

HELP: dummy-int-params?
{ $values { "?" boolean } }
{ $description "Whether the architecture's ABI uses dummy integer parameters. If it does, then the corresponding integer register is 'dummy allocated' when a floating point register is allocated." } { $see-also dummy-fp-params? } ;

HELP: float-regs
{ $description "Floating point register class." } ;

HELP: fused-unboxing?
{ $values { "?" boolean } }
{ $description "Whether this architecture supports " { $link %load-float } ", " { $link %load-double } ", and " { $link %load-vector } "." } ;

HELP: enable-cpu-features
{ $description "This word is run when compiling the compiler during bootstrap and enables optional features that the processor is found to support." } ;

HELP: gc-root-offset
{ $values { "spill-slot" spill-slot } { "n" integer } }
{ $description "Offset in the " { $link stack-frame } " for the word being constructed where the spill slot is located. The value is given in " { $link cell } " units." }
{ $see-also gc-info } ;

HELP: immediate-arithmetic?
{ $values { "n" number } { "?" boolean } }
{ $description
  "Can this value be an immediate operand for " { $link %add-imm } ", "
  { $link %sub-imm } ", or " { $link %mul-imm } "?"
} ;

HELP: immediate-bitwise?
{ $values { "n" number } { "?" boolean } }
{ $description "Can this value be an immediate operand for %and-imm, %or-imm, or %xor-imm?" } ;

HELP: immediate-comparand?
{ $values { "n" number } { "?" boolean } }
{ $description "Can this value be an immediate operand for %compare-imm or %compare-imm-branch?" } ;

HELP: immediate-store?
{ $values { "n" number } { "?" boolean } }
{ $description "Can this value be an immediate operand for %replace-imm?" } ;

HELP: int-regs
{ $description "Integer register class." } ;

HELP: machine-registers
{ $values { "assoc" assoc } }
{ $description "Mapping from register class to machine registers. Only registers not reserved by the Factor VM are included." } ;

HELP: param-regs
{ $values { "abi" "a calling convention symbol" } { "regs" assoc } }
{ $description "Retrieves the order in which machine registers are used for parameters for the given calling convention." } ;

HELP: rep-size
{ $values { "rep" representation } { "n" integer } }
{ $description "Size in bytes of a representation." }
{ $see representation } ;

HELP: reg-class-of
{ $values { "rep" representation } { "reg-class" reg-class } }
{ $description "Register class for values of the given representation." } ;

HELP: return-regs
{ $values { "regs" assoc } }
{ $description "What registers that will be used for function return values of which class." } ;

HELP: return-struct-in-registers?
{ $values { "c-type" class } { "?" boolean } }
{ $description "Whether the size of the struct is so small that it will be returned in registers or not." } ;

HELP: signed-rep
{ $values { "rep" representation } { "rep'" representation } }
{ $description "Maps any representation to its signed counterpart, if it has one." } ;

HELP: stack-cleanup
{ $values
  { "stack-size" integer }
  { "return" "a c type" }
  { "abi" abi }
  { "n" integer }
}
{ $description "Calculates how many bytes of stack space the caller of the procedure being constructed need to cleanup. For modern abi's the value is almost always 0." }
{ $examples
  { $unchecked-example
    "USING: cpu.architecture prettyprint ;"
    "20 void stdcall stack-cleanup ."
    "20"
  }
} ;

HELP: stack-frame-size
{ $values
  { "stack-frame" stack-frame }
  { "n" integer }
} { $description "Calculates the total size of a stack frame, including padding and alignment." } ;

HELP: test-instruction?
{ $values { "?" boolean } }
{ $description "Does the current architecture have a test instruction? Used on x86 to rewrite some " { $snippet CMP } " instructions to less expensive " { $snippet TEST } "s." } ;

HELP: vm-stack-space
{ $values { "n" number } }
{ $description "Parameter space to reserve in anything making VM calls. Why is this set to 16 on x86.32?" } ;

ARTICLE: "cpu.architecture" "CPU architecture description model"
"The " { $vocab-link "cpu.architecture" } " vocab contains generic words and hooks that serves as an api for the compiler towards the cpu architecture."
$nl
"Architecture support checks:"
{ $subsections
  complex-addressing?
  dummy-int-params?
  dummy-fp-params?
  float-right-align-on-stack?
  fused-unboxing?
  test-instruction?
}
"Arithmetic:"
{ $subsections
  %add
  %add-imm
  %sub
  %sub-imm
  %mul
  %mul-imm
  %neg
}
"Bit twiddling:"
{ $subsections
  %and
  %and-imm
  %not
  %or
  %or-imm
  %sar
  %sar-imm
  %shl
  %shl-imm
  %shr
  %shr-imm
  %xor
  %xor-imm
}
"Control flow code emitters:"
{ $subsections
  %call
  %epilogue
  %jump
  %jump-label
  %prologue
  %return
  %safepoint
}
"Foreign function interface:"
{ $subsections %c-invoke }
"Garbage collection:"
{ $subsections
  %call-gc
  %check-nursery-branch
}
"Moving values around:"
{ $subsections
  %clear
  %peek
  %replace
  %replace-imm
}
"Register categories:"
{ $subsections
  machine-registers
  param-regs
  return-regs
}
"Representation metadata:"
{ $subsections
  narrow-vector-rep
  reg-class-of
  rep-component-type
  rep-length
  rep-size
  scalar-rep-of
  signed-rep
  widen-vector-rep
}
"Slot access:"
{ $subsections
  %set-slot
  %set-slot-imm
  %slot
  %slot-imm
  %write-barrier
}
"Spilling & reloading:"
{ $subsections %spill %reload gc-root-offset }
"Value as immediate checks:"
{ $subsections
  immediate-arithmetic?
  immediate-bitwise?
  immediate-comparand?
  immediate-store?
  immediate-shift-count?
} ;

ABOUT: "cpu.architecture"
