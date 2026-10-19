USING: eval vocabs vocabs.loader ;
"system" reload
"compiler.constants" reload
"cpu.architecture" reload
"compiler.cfg.builder.alien.params" reload
"compiler.cfg.builder.alien.boxing" reload
"cpu.sparc.ffi" require
"USING: cpu.sparc cpu.sparc.ffi cpu.architecture system namespaces make byte-arrays io.files io.encodings.binary io.pathnames command-line layouts compiler.codegen.relocation ; 4 \\ cell [ sparc.32 \\ cpu [ init-relocation [ 112 %prologue 4 27 int-rep %copy 2 42 %load-immediate 3 43 %load-immediate 1 24 int-rep %copy 8 25 int-rep %copy 9 26 int-rep %copy 0 f native-call 24 8 int-rep %copy 112 %epilogue %return ] B{ } make ] with-variable ] with-variable command-line get first \"sparc-ffi-generated32.bin\" append-path binary set-file-contents 8 \\ cell [ sparc.64 \\ cpu [ init-relocation [ 192 %prologue 4 27 int-rep %copy 2 42 %load-immediate 3 43 %load-immediate 1 24 int-rep %copy 8 25 int-rep %copy 9 26 int-rep %copy 0 f native-call 24 8 int-rep %copy 192 %epilogue %return ] B{ } make ] with-variable ] with-variable command-line get first \"sparc-ffi-generated64.bin\" append-path binary set-file-contents" eval( -- )

"USING: cpu.sparc cpu.sparc.ffi cpu.architecture system namespaces make byte-arrays io.files io.encodings.binary io.pathnames command-line layouts compiler.codegen.relocation ; 4 \\ cell [ sparc.32 \\ cpu [ init-relocation [ 112 %prologue 4 27 int-rep %copy 2 42 %load-immediate 3 43 %load-immediate 1 24 int-rep %copy 8 25 int-rep %copy 9 26 int-rep %copy 28 sp-reg 64 %cell-store 0 f native-call 24 8 int-rep %copy 112 %epilogue %return ] B{ } make ] with-variable ] with-variable command-line get first \"sparc-sret-generated32.bin\" append-path binary set-file-contents" eval( -- )

! Float members of a GNU V9 aggregate use f0/f1, rather than f1/f3.
"USING: cpu.sparc cpu.sparc.ffi cpu.sparc.assembler cpu.architecture system namespaces make byte-arrays io.files io.encodings.binary io.pathnames command-line layouts compiler.codegen.relocation ; 8 \\ cell [ sparc.64 \\ cpu [ init-relocation [ 192 %prologue 4 26 int-rep %copy 2 42 %load-immediate 3 43 %load-immediate 1 24 int-rep %copy 8 25 int-rep %copy 25 sp-reg 2175 %cell-store 0 sp-reg 2175 LDDF 0 f native-call 0 sp-reg 2175 STDF 24 sp-reg 2175 %cell-load 192 %epilogue %return ] B{ } make ] with-variable ] with-variable command-line get first \"sparc-aggregate-generated64.bin\" append-path binary set-file-contents" eval( -- )
