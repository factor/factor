! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data arrays byte-arrays
compiler.units destructors io kernel layouts libc make math
math.order math.parser namespaces prettyprint quotations
sequences sequences.private stack-checker system tools.memory
vocabs words ;
IN: tools.disassembler

GENERIC: disassemble ( obj -- )

<PRIVATE

SYMBOL: disassembler-backend

HOOK: disassemble* disassembler-backend ( from to -- )

GENERIC: convert-address ( object -- n )

M: integer convert-address ;

M: alien convert-address alien-address ;

: complete-address ( n seq -- )
    " (" % building get [ "" like write ] [ delete-all ] bi
    [ nip owner>> pprint-short ] [ entry-point>> - ] 2bi
    [ " + 0x" % >hex % ] unless-zero ")" % ;

: search-xt ( addr -- )
    dup lookup-return-address [ complete-address ] [ drop ] if* ;

: resolve-xt ( str -- )
    string>number [ search-xt ] when* ;

: resolve-call ( str -- )
    "0x" over subseq-start [ tail-slice resolve-xt ] [ drop ] if* ;

: write-disassembly ( lines -- )
    dup [ second length ] [ max ] map-reduce [
        '[
            [ first >hex cell 2 * CHAR: 0 pad-head % ": " % ]
            [ second _ CHAR: \s pad-tail % "  " % ]
            [ third [ % ] [ resolve-call ] bi ]
            tri CHAR: \n ,
        ] each
    ] "" make write ;

PRIVATE>

M: byte-array disassemble
    [
        [ malloc-byte-array &free alien-address dup ]
        [ length + ] bi 2array disassemble
    ] with-destructors ;

M: pair disassemble
    first2-unsafe [ convert-address ] bi@ disassemble* ;

M: word disassemble word-code 2array disassemble ;

M: callable disassemble
    [ dup infer define-temp ] with-compilation-unit disassemble ;

cpu x86?
"tools.disassembler.udis"
"tools.disassembler.gdb" ?
require
