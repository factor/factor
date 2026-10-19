USING: eval vocabs.loader ;
"system" reload
"compiler.constants" reload
"cpu.architecture" reload
"compiler.cfg.instructions" reload
"compiler.cfg.build-stack-frame" reload
"compiler.codegen.relocation" reload
"cpu.sparc" reload
"compiler.cfg.builder" reload
"compiler.codegen.gc-maps" reload
"compiler.codegen" reload
"compiler" reload
"USING: accessors arrays assocs byte-arrays command-line compiler compiler.units compiler.codegen.relocation cpu.architecture cpu.sparc endian io.encodings.binary io.files io.pathnames kernel layouts locals namespaces prettyprint sequences words ;\nIN: sparc.tail-target.probe\nGENERIC: target-generic ( x -- y )\nM: object target-generic ;\n: tail-caller ( x -- y ) target-generic ;\n{ sparc.32 sparc.64 } [| target | target \\ cpu [ big-endian relocation-byte-order set target sparc.32? [ 4 ] [ 8 ] if \\ cell [ H{ } clone compiled [ \\ tail-caller compile-word compiled get \\ tail-caller swap at 4 swap nth command-line get first target sparc.32? [ \"caller32.bin\" ] [ \"caller64.bin\" ] if append-path binary set-file-contents ] with-variable ] with-variable ] with-variable ] each\n" eval( -- )
