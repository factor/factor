! Execute the production callback-entry poll/SAVE ordering with native inputs.
USING: eval vocabs vocabs.loader ;
"system" reload
"compiler.constants" reload
"cpu.architecture" reload
"compiler.codegen.relocation" reload
"cpu.sparc" reload
"USING: byte-arrays command-line compiler.constants compiler.codegen.relocation cpu.architecture\ncpu.sparc cpu.sparc.assembler io.encodings.binary io.files io.pathnames endian kernel\nlayouts make math namespaces sequences system ;\nIN: sparc-callback-poll.probe\n: emit-entry ( -- bytes )\n    big-endian relocation-byte-order set\n    init-relocation [\n        %safepoint\n        \\ cpu get sparc.32? [ 96 ] [ 176 ] if %prologue\n        1 0 %set-cell \"callback_poll_results\" f rc-native-1 rel-dlsym\n        6 [ dup 24 + 1 rot bootstrap-cells %cell-store ] each-integer\n        \\ cpu get sparc.64? [ 12 1 48 STDF 14 1 56 STDF ] when\n        24 29 0 ORI\n        \\ cpu get sparc.32? [ 96 ] [ 176 ] if %epilogue %return\n    ] B{ } make ;\n{ sparc.32 sparc.64 } [\n    dup sparc.32? [ 4 ] [ 8 ] if \\ cell [\n        \\ cpu [\n            emit-entry\n            command-line get first \\ cpu get sparc.32? [ \"entry32.bin\" ] [ \"entry64.bin\" ] if append-path\n            binary set-file-contents\n            relocation-table get >byte-array\n            command-line get first \\ cpu get sparc.32? [ \"entry32.reloc\" ] [ \"entry64.reloc\" ] if append-path\n            binary set-file-contents\n        ] with-variable\n    ] with-variable\n] each\n" eval( -- )
