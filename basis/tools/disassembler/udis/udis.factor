! Copyright (C) 2008 Slava Pestov, Jorge Acereda Macia.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.disassembler namespaces combinators
alien alien.syntax alien.c-types lexer parser kernel
sequences layouts math math.order
math.parser system make fry arrays ;
IN: tools.disassembler.udis

<<
"libudis86" {
    { [ os macosx? ] [ "libudis86.0.dylib" ] }
    { [ os unix? ] [ "libudis86.so.0" ] }
    { [ os winnt? ] [ "libudis86.dll" ] }
} cond "cdecl" add-library
>>

LIBRARY: libudis86

TYPEDEF: char[592] ud

FUNCTION: void ud_translate_intel ( ud* u ) ;
FUNCTION: void ud_translate_att ( ud* u ) ;

: UD_SYN_INTEL ( -- addr ) &: ud_translate_intel ; inline
: UD_SYN_ATT ( -- addr ) &: ud_translate_att ; inline

: UD_EOI          -1 ; inline
: UD_INP_CACHE_SZ 32 ; inline
: UD_VENDOR_AMD   0 ; inline
: UD_VENDOR_INTEL 1 ; inline

FUNCTION: void ud_init ( ud* u ) ;
FUNCTION: void ud_set_mode ( ud* u, uint8_t mode ) ;
FUNCTION: void ud_set_pc ( ud* u, ulonglong pc ) ;
FUNCTION: void ud_set_input_buffer ( ud* u, uint8_t* offset, size_t size ) ;
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
    "ud" <c-object>
    dup ud_init
    dup cell-bits ud_set_mode
    dup UD_SYN_INTEL ud_set_syntax ;

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
    [ <ud> ] 2dip {
        [ drop ud_set_pc ]
        [ buf/len ud_set_input_buffer ]
        [ 2drop (disassemble) format-disassembly ]
    } 3cleave ;

udis-disassembler disassembler-backend set-global
