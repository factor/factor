! Emit the production large-frame prologue with native input observers.
USING: eval vocabs.loader ;
"system" reload
"compiler.constants" reload
"cpu.architecture" reload
"compiler.codegen.relocation" reload
"cpu.sparc" reload
"USING: byte-arrays command-line compiler.constants compiler.codegen.relocation cpu.architecture\ncpu.sparc cpu.sparc.assembler endian io.encodings.binary io.files io.pathnames kernel\nlayouts locals make math math.parser namespaces sequences strings system ;\nIN: sparc-large-frame.probe\n:: emit-entry ( frame -- bytes )\n    big-endian relocation-byte-order set init-relocation [\n        frame %prologue %safepoint\n        1 0 %set-cell \"large_frame_results\" f rc-native-1 rel-dlsym\n        6 [ dup 24 + 1 rot bootstrap-cells %cell-store ] each-integer\n        \\ cpu get sparc.64? [ 12 1 48 STDF 14 1 56 STDF ] when\n        24 29 0 ORI frame %epilogue %return\n    ] B{ } make ;\n{ sparc.32 sparc.64 } [| target |\n    target sparc.32? 4 8 ? \\ cell [ target \\ cpu [\n        { 4096 4112 8192 12288 65536 } [| frame |\n            command-line get first target sparc.32? \"32-\" \"64-\" ?\n            frame number>string append append-path :> stem\n            frame emit-entry stem \".bin\" append binary set-file-contents\n            relocation-table get >byte-array stem \".reloc\" append binary set-file-contents\n        ] each\n    ] with-variable ] with-variable\n] each\n" eval( -- )
