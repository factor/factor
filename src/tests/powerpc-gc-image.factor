! Build a minimal native continuation/GC image from the real target bootstrap.
USING: accessors assocs bootstrap.image bootstrap.image.private
command-line combinators continuations effects hashtables init io io.encodings.binary io.files
kernel kernel.private layouts locals math memory namespaces parser
parser.notes sequences system vocabs.loader ;
IN: powerpc.gc-image

"system" reload
"compiler.constants" reload
"compiler.codegen.relocation" reload
"cpu.ppc.assembler" reload
"bootstrap.image" reload

:: make-probe-image ( arch path -- )
    arch architecture associate H{
        { parser-quiet? f }
        { auto-use? f }
    } assoc-union! [
        H{ } clone special-objects set
        "resource:basis/bootstrap/stage1.factor" run-file
        OBJ-STARTUP-QUOT special-objects get at :> startup
        "resource:basis/bootstrap/stage2.factor" startup index :> stage2-index
        stage2-index [ ] [ "missing stage2 dispatch" throw ] if
        startup stage2-index head [
            [ 42 ] ( -- value ) call-effect 42 = [ ] [ 21 (exit) ] if
            123 [ 7 + ] ( value -- value ) call-effect 130 = [ ] [ 22 (exit) ] if
            "Native dynamic call-effect probe passed" print flush
            1 2 + 3 = [ ] [ 1 (exit) ] if
            -7 4 + -3 = [ ] [ 1 (exit) ] if
            2.0 3.5 * 7.0 = [ ] [ 1 (exit) ] if
            20 [
                [ minor-gc gc compact-gc 42 swap continue-with ] callcc1
                42 = [ ] [ 1 (exit) ] if
            ] times
            "Native arithmetic, forced GC and continuation restoration passed (20 iterations)" print flush
            0 (exit)
        ] append OBJ-STARTUP-QUOT special-objects get set-at
        build-image path binary [ (write-image) ] with-file-writer
    ] with-variables ;

command-line get first2 make-probe-image
