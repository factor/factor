USING: eval vocabs vocabs.loader ;
"system" reload
"compiler.constants" reload
"cpu.architecture" reload
"compiler.cfg.build-stack-frame" reload
"compiler.codegen.relocation" reload
"compiler.cfg.builder.alien.params" reload
"compiler.cfg.builder.alien.boxing" reload
"cpu.sparc.ffi" reload
"classes.struct" reload
"compiler.cfg.builder.alien" reload
"compiler.cfg.hats" reload
"compiler" reload
"USING: accessors alien.c-types alien.strings alien.syntax arrays assocs byte-arrays grouping classes.struct command-line compiler compiler.units compiler.codegen.relocation endian cpu.architecture cpu.sparc cpu.sparc.ffi io io.encodings.ascii io.encodings.binary io.files io.pathnames kernel kernel.private layouts locals math math.order namespaces prettyprint sequences slots.private words ;\nQUALIFIED: math\nIN: sparc.compiler.probe\n: add-fixnums ( a b -- n ) { fixnum fixnum } declare + ;\n: add-floats ( a b -- n ) { math:float math:float } declare + ;\n: get-slot ( obj -- n ) { byte-array } declare 1 slot ;\n: min-fixnums ( a b -- n ) { fixnum fixnum } declare min ;\n: multiply-fixnums ( a b -- n ) { fixnum fixnum } declare * ;\nUNION-STRUCT: sparc-single-union { value double } ;\nLIBRARY: libc\nFUNCTION: int sparc_probe_add ( int a, int b )\n: call-native-add ( a b -- n ) { fixnum fixnum } declare sparc_probe_add ;\nFUNCTION: double sparc_probe_fp ( double a, double b )\n: call-native-floats ( a b -- n ) { math:float math:float } declare sparc_probe_fp ;\nFUNCTION: sparc-single-union sparc_probe_union ( int a, int b )\n: call-native-union ( a b -- n ) { fixnum fixnum } declare sparc_probe_union ;\n{ sparc.32 sparc.64 } [| target |\n target \\ cpu [ big-endian relocation-byte-order set\n  target sparc.32? [ 4 ] [ 8 ] if \\ cell [\n   H{ } clone compiled [\n    { \\ add-fixnums \\ add-floats \\ get-slot \\ min-fixnums \\ multiply-fixnums \\ call-native-add \\ call-native-floats \\ call-native-union } [ wrapped>> compile-word ] each\n    compiled get [| word code |\n     code array? [ ] [ word throw ] if\n     word name>> target sparc.32? [ \"32.bin\" ] [ \"64.bin\" ] if append\n     command-line get first swap append-path :> path\n     code 4 swap nth path binary set-file-contents\n     code 2 swap nth path \".relocs\" append binary set-file-contents\n     code first 2 group [ first symbol>string ] map path \".symbols\" append ascii set-file-lines\n     code 3 swap nth unparse path \".labels\" append ascii set-file-contents\n    ] assoc-each\n    compiled get assoc-size .\n   ] with-variable\n  ] with-variable\n ] with-variable\n] each\n" eval( -- )
