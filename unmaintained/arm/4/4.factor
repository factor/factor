! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays cpu.architecture cpu.arm.assembler
cpu.arm.architecture cpu.arm5.assembler kernel kernel.private
math math.private namespaces sequences words quotations
byte-arrays hashtables.private hashtables generator
generator.registers generator.fixup sequences.private
strings.private ;
IN: cpu.arm4

: (%char-slot)
    "out" operand string-offset MOV
    "out" operand dup "n" operand 2 <LSR> ADD ;

\ char-slot [
    (%char-slot)
    "out" operand "obj" operand "out" operand <+> LDRH
    "out" operand dup %tag-fixnum
] H{
    { +input+ { { f "n" } { f "obj" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ set-char-slot [
    "val" operand dup %untag-fixnum
    (%char-slot)
    "val" operand "obj" operand "out" operand <+> STRH
] H{
    { +input+ { { f "val" } { f "n" } { f "obj" } } }
    { +scratch+ { { f "out" } } }
    { +clobber+ { "val" } }
} define-intrinsic

\ alien-signed-1 [ LDRSB ]
\ set-alien-signed-1 [ STRB ]
define-alien-integer-intrinsics

\ alien-unsigned-2 [ LDRH ]
\ set-alien-unsigned-2 [ STRH ]
define-alien-integer-intrinsics

\ alien-signed-2 [ LDRSH ]
\ set-alien-signed-2 [ STRH ]
define-alien-integer-intrinsics
