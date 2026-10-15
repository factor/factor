USING: accessors arrays compiler.cfg.representations compiler.codegen.labels
compiler.codegen.relocation compiler.cfg.comparisons alien.c-types cpu.architecture cpu.sh cpu.sh.abi cpu.sh.assembler cpu.sh.codegen io.files
io.encodings.binary io.encodings.utf8 io.pathnames json kernel locals make
namespaces sequences vectors ;
IN: sh.nan-probe
SYMBOL: output-directory
:: emit-probe ( name quot -- )
    [
        init-relocation V{ } clone label-table set quot call( -- )
        label-table get [ [ offset>> ] [ label>> offset>> ] bi 2array ] map >json
        output-directory get name "-labels.json" append append-path utf8 set-file-contents
    ] B{ } make
    output-directory get name ".bin" append append-path binary set-file-contents ;
: emit-nan-probes ( -- )
    "native-double" [ 0 4 double-rep t sh-convert-nan RETURN ] emit-probe
    "canonical-double" [ 0 4 double-rep f sh-convert-nan RETURN ] emit-probe
    "native-float" [ 0 5 float-rep t sh-convert-nan RETURN ] emit-probe
    "canonical-float" [ 0 5 float-rep f sh-convert-nan RETURN ] emit-probe
    "add-double" [ 0 4 6 [ FADD ] float-op RETURN ] emit-probe
    "widen-float" [ 0 5 sh-single>double RETURN ] emit-probe
    "narrow-double" [ 0 4 sh-double>single RETURN ] emit-probe
    "sub-double" [ 0 4 6 [ FSUB ] float-op RETURN ] emit-probe
    "mul-double" [ 0 4 6 [ FMUL ] float-op RETURN ] emit-probe
    "div-double" [ 0 4 6 [ FDIV ] float-op RETURN ] emit-probe
    "sqrt-double" [ 0 4 sh-sqrt RETURN ] emit-probe
    "truncate-double" [ 0 4 sh-float>integer RETURN ] emit-probe
    "scalar-out-double" [ 4 double-rep 4 <abi-float-register> store-reg-param 0 4 FMV RETURN ] emit-probe
    "scalar-in-double" [ 0 double-rep 4 <abi-float-register> load-reg-param RETURN ] emit-probe
    "record-out-double" [ 4 double-rep 4 <abi-float-register> <native-float-register> store-reg-param 0 4 FMV RETURN ] emit-probe
    "record-in-double" [ 0 double-rep 4 <abi-float-register> <native-float-register> load-reg-param RETURN ] emit-probe
    "scalar-out-float" [ 5 float-rep 4 <abi-float-register> store-reg-param 5 0 FMOV RETURN ] emit-probe
    "scalar-in-float" [ 0 float-rep 4 <abi-float-register> load-reg-param RETURN ] emit-probe
    "record-out-float" [ 5 float-rep 4 <abi-float-register> <native-float-register> store-reg-param 5 0 FMOV RETURN ] emit-probe
    "record-in-float" [ 0 float-rep 4 <abi-float-register> <native-float-register> load-reg-param RETURN ] emit-probe
    "typed-load-double" [ 0 5 0 double-rep double load-memory RETURN ] emit-probe
    "raw-load-double" [ 0 5 0 double-rep f load-memory RETURN ] emit-probe
    "typed-store-double" [ 4 5 0 double-rep double store-memory 0 0 LI RETURN ] emit-probe
    "raw-store-double" [ 4 5 0 double-rep f store-memory 0 0 LI RETURN ] emit-probe
    "typed-load-float" [ 0 5 0 float-rep alien.c-types:float load-memory RETURN ] emit-probe
    "raw-load-float" [ 0 5 0 float-rep f load-memory RETURN ] emit-probe
    "typed-store-float" [ 5 5 0 float-rep alien.c-types:float store-memory 0 0 LI RETURN ] emit-probe
    "raw-store-float" [ 5 5 0 float-rep f store-memory 0 0 LI RETURN ] emit-probe
    "scalar-stack-double" [ 4 double-rep 0 8 f store-native-stack-param 0 SP 0 FLD RETURN ] emit-probe
    "record-stack-double" [ 4 double-rep 0 8 t store-native-stack-param 0 SP 0 FLD RETURN ] emit-probe
    "scalar-callback-double" [ 12 5 MV 0 double-rep 4 <abi-float-register> load-callback-reg-param RETURN ] emit-probe
    "record-callback-double" [ 12 5 MV 0 double-rep 4 <abi-float-register> <native-float-register> load-callback-reg-param RETURN ] emit-probe
    "scalar-callback-stack-double" [ 12 5 MV 0 double-rep 0 8 f load-native-stack-param RETURN ] emit-probe
    "record-callback-stack-double" [ 12 5 MV 0 double-rep 0 8 t load-native-stack-param RETURN ] emit-probe
    "quiet-less" [ 7 4 6 cc< f sh-float-bit 0 7 MV RETURN ] emit-probe
    "ordered-less" [ 7 4 6 cc< t sh-float-bit 0 7 MV RETURN ] emit-probe ;
