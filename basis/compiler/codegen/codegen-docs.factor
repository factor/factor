USING: alien byte-arrays compiler.cfg compiler.cfg.instructions
compiler.codegen.labels compiler.codegen.relocation cpu.architecture
hashtables help.markup help.syntax literals make multiline quotations
sequences ;
IN: compiler.codegen

<<
STRING: generate-ex
USING: compiler.cfg.debugger io prettyprint ;
[ "hello\n" write ] test-regs first dup cfg set generate [ . ] [ 4 swap nth disassemble ] bi
;

STRING: generate-ex-answer
{
    { }
    { "hello\n" output-stream assoc-stack stream-write }
    B{
        6 0 0 242 24 0 0 96 49 0 0 96 58 0 0 34 64 0 0 242 80 0
        0 50
    }
    { }
    B{
        137 5 0 0 0 0 72 131 236 8 73 131 198 24 72 185 0 0 0 0
        0 0 0 0 73 137 78 240 73 139 77 0 72 139 73 64 73 137 14
        72 185 0 0 0 0 0 0 0 0 73 137 78 248 232 0 0 0 0 137 5 0
        0 0 0 72 131 196 8 72 141 29 5 0 0 0 233 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0
    }
    16
}
0000000001cc4ca0: 890500000000          mov [rip], eax
0000000001cc4ca6: 4883ec08              sub rsp, 0x8
0000000001cc4caa: 4983c618              add r14, 0x18
0000000001cc4cae: 48b90000000000000000  mov rcx, 0x0
0000000001cc4cb8: 49894ef0              mov [r14-0x10], rcx
0000000001cc4cbc: 498b4d00              mov rcx, [r13]
0000000001cc4cc0: 488b4940              mov rcx, [rcx+0x40]
0000000001cc4cc4: 49890e                mov [r14], rcx
0000000001cc4cc7: 48b90000000000000000  mov rcx, 0x0
0000000001cc4cd1: 49894ef8              mov [r14-0x8], rcx
0000000001cc4cd5: e800000000            call 0x1cc4cda
0000000001cc4cda: 890500000000          mov [rip], eax
0000000001cc4ce0: 4883c408              add rsp, 0x8
0000000001cc4ce4: 488d1d05000000        lea rbx, [rip+0x5]
0000000001cc4ceb: e900000000            jmp 0x1cc4cf0
0000000001cc4cf0: 0000                  add [rax], al
0000000001cc4cf2: 0000                  add [rax], al
0000000001cc4cf4: 0000                  add [rax], al
0000000001cc4cf6: 0000                  add [rax], al
0000000001cc4cf8: 0000                  add [rax], al
0000000001cc4cfa: 0000                  add [rax], al
0000000001cc4cfc: 0000                  add [rax], al
0000000001cc4cfe: 0000                  add [rax], al
;
>>

HELP: emit-branch
{ $values { "bb" basic-block } { "successor" basic-block } }
{ $description "Emits a branching instruction for jumping from one block to the next. If the blocks are next to each other, then no jump is needed." }
{ $see-also %jump-label } ;

HELP: generate
{ $values { "cfg" cfg } { "code" sequence } }
{ $description "Generates assembly code for the given cfg. The output " { $link sequence } " has six items with the following interpretations:"
  { $list
    { "The first element is a sequence of alien function symbols and " { $link dll } "s used by the cfg interleaved. That is, the " { $link parameter-table } "." }
    { "The second item is the " { $link literal-table } "." }
    { "The third item is the relocation table as a " { $link byte-array } "." }
    { "The fourth item is the " { $link label-table } "." }
    { "The fifth item is the generated assembly code as a " { $link byte-array } ". It still contains unresolved crossreferences." }
    "The sixth item is the size of the stack frame in bytes."
  }
}
{ $examples
  "A small quotation is compiled and then disassembled:"
  { $unchecked-example $[ generate-ex generate-ex-answer ] }
} ;

HELP: generate-insn
{ $values { "insn" insn } }
{ $description "Generates assembler code for one cfg instruction." }
{ $see-also generate } ;

HELP: generate-block
{ $values { "bb" basic-block } }
{ $description "Emits machine code to the current " { $link make } " sequence for one basic block." } ;


HELP: labels
{ $description { $link hashtable } " of mappings from " { $link basic-block } " to " { $link label } "." } ;

HELP: lookup-label
{ $values { "bb" basic-block } { "label" label } }
{ $description "Sets and gets a " { $link label } " for the " { $link basic-block } ". The labels are used to generate branch instructions from one block to another." } ;

HELP: useless-branch?
{ $values
  { "bb" basic-block }
  { "successor" "The successor block of bb" }
  { "?" "A boolean value" }
}
{ $description "If successor immediately follows bb in the linearization order, then a branch is is not needed." } ;

HELP: check-fixup
{ $values { "seq" "a " { $link sequence } " of generated machine code." } }
{ $description "Used by " { $link with-fixup } " to ensure that the generated machine code is properly aligned." } ;

HELP: with-fixup
{ $values
  { "quot" quotation }
  { "code" sequence }
}
{ $description "Runs the quotation to emit compiled code. The output is a six-tuple with the same format as the one output by " { $link generate } "." } ;

ARTICLE: "compiler.codegen" "Code generation from MR (machine representation)"
"Code generators for cfg instructions."
$nl
"Combinators:"
{ $subsections with-fixup } ;

ABOUT: "compiler.codegen"
