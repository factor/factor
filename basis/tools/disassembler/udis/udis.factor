! Copyright (C) 2008 Slava Pestov, Jorge Acereda Macia.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.disassembler namespaces combinators
alien alien.syntax alien.c-types lexer parser kernel
sequences layouts math math.order alien.libraries
math.parser system make fry arrays libc destructors ;
IN: tools.disassembler.udis

<<
"libudis86" {
    { [ os macosx? ] [ "libudis86.0.dylib" ] }
    { [ os unix? ] [ "libudis86.so.0" ] }
    { [ os winnt? ] [ "libudis86.dll" ] }
} cond "cdecl" add-library
>>

LIBRARY: libudis86

C-STRUCT: ud_operand
    { "int" "type" }
    { "uint8_t" "size" }
    { "uint64_t" "lval" }
    { "int" "base" }
    { "int" "index" }
    { "uint8_t" "offset" }
    { "uint8_t" "scale" } ;

C-STRUCT: ud
    { "void*" "inp_hook" }
    { "uint8_t" "inp_curr" }
    { "uint8_t" "inp_fill" }
    { "FILE*" "inp_file" }
    { "uint8_t" "inp_ctr" }
    { "uint8_t*" "inp_buff" }
    { "uint8_t*" "inp_buff_end" }
    { "uint8_t" "inp_end" }
    { "void*" "translator" }
    { "uint64_t" "insn_offset" }
    { "char[32]" "insn_hexcode" }
    { "char[64]" "insn_buffer" }
    { "uint" "insn_fill" }
    { "uint8_t" "dis_mode" }
    { "uint64_t" "pc" }
    { "uint8_t" "vendor" }
    { "struct map_entry*" "mapen" }
    { "int" "mnemonic" }
    { "ud_operand[3]" "operand" }
    { "uint8_t" "error" }
    { "uint8_t" " " "pfx_rex" }
    { "uint8_t" "pfx_seg" }
    { "uint8_t" "pfx_opr" }
    { "uint8_t" "pfx_adr" }
    { "uint8_t" "pfx_lock" }
    { "uint8_t" "pfx_rep" }
    { "uint8_t" "pfx_repe" }
    { "uint8_t" "pfx_repne" }
    { "uint8_t" "pfx_insn" }
    { "uint8_t" "default64" }
    { "uint8_t" "opr_mode" }
    { "uint8_t" "adr_mode" }
    { "uint8_t" "br_far" }
    { "uint8_t" "br_near" }
    { "uint8_t" "implicit_addr" }
    { "uint8_t" "c1" }
    { "uint8_t" "c2" }
    { "uint8_t" "c3" }
    { "uint8_t[256]" "inp_cache" }
    { "uint8_t[64]" "inp_sess" }
    { "ud_itab_entry*" "itab_entry" } ;

FUNCTION: void ud_translate_intel ( ud* u ) ;
FUNCTION: void ud_translate_att ( ud* u ) ;

: UD_SYN_INTEL ( -- addr ) &: ud_translate_intel ; inline
: UD_SYN_ATT ( -- addr ) &: ud_translate_att ; inline

CONSTANT: UD_EOI          -1
CONSTANT: UD_INP_CACHE_SZ 32
CONSTANT: UD_VENDOR_AMD   0
CONSTANT: UD_VENDOR_INTEL 1

FUNCTION: void ud_init ( ud* u ) ;
FUNCTION: void ud_set_mode ( ud* u, uchar mode ) ;
FUNCTION: void ud_set_pc ( ud* u, ulonglong pc ) ;
FUNCTION: void ud_set_input_buffer ( ud* u, uchar* offset, size_t size ) ;
FUNCTION: void ud_set_vendor ( ud* u, uint vendor ) ;
FUNCTION: void ud_set_syntax ( ud* u, void* syntax ) ;
FUNCTION: void ud_input_skip ( ud* u, size_t size ) ;
FUNCTION: int ud_input_end ( ud* u ) ;
FUNCTION: uint ud_decode ( ud* u ) ;
FUNCTION: uint ud_disassemble ( ud* u ) ;
FUNCTION: char* ud_insn_asm ( ud* u ) ;
FUNCTION: void* ud_insn_ptr ( ud* u ) ;
FUNCTION: ulonglong ud_insn_off ( ud* u ) ;
FUNCTION: char* ud_insn_hex ( ud* u ) ;
FUNCTION: uint ud_insn_len ( ud* u ) ;
FUNCTION: char* ud_lookup_mnemonic ( int c ) ;

: <ud> ( -- ud )
    "ud" malloc-object &free
    dup ud_init
    dup cell-bits ud_set_mode
    dup UD_SYN_INTEL ud_set_syntax ;

: with-ud ( quot: ( ud -- ) -- )
    [ [ <ud> ] dip call ] with-destructors ; inline

SINGLETON: udis-disassembler

: buf/len ( from to -- buf len ) [ drop <alien> ] [ swap - ] 2bi ;

: format-disassembly ( lines -- lines' )
    dup [ second length ] [ max ] map-reduce
    '[
        [
            [ first >hex cell 2 * CHAR: 0 pad-head % ": " % ]
            [ second _ CHAR: \s pad-tail % "  " % ]
            [ third % ]
            tri
        ] "" make
    ] map ;

: (disassemble) ( ud -- lines )
    [
        dup '[
            _ ud_disassemble 0 =
            [ f ] [
                _
                [ ud_insn_off ]
                [ ud_insn_hex ]
                [ ud_insn_asm ]
                tri 3array , t
            ] if
        ] loop
    ] { } make ;

M: udis-disassembler disassemble* ( from to -- buffer )
    '[
        _ _
        [ drop ud_set_pc ]
        [ buf/len ud_set_input_buffer ]
        [ 2drop (disassemble) format-disassembly ]
        3tri
    ] with-ud ;

udis-disassembler disassembler-backend set-global
