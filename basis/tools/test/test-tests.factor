IN: tools.test.tests
USING: accessors continuations debugger io.streams.string kernel locals namespaces parser.notes
sequences tools.test tools.test.private prettyprint.config ;

! Deliberate failures used to test the harness must not look like real failures.
{ 1 "" } [
    f verbose-tests? [
        [ [ [ "OOPS" ] must-fail ] fake-unit-test length ] with-string-writer
    ] with-variable
] unit-test

:: capture-test-output ( paths -- output failures )
    [
        V{ } clone test-failures set
        [ "output fixture" [ paths [ run-test-file ] each ] with-test-run ]
        with-string-writer
        test-failures get length
    ] with-scope ;

! Quiet parsing is scoped, and counts include all files in the run.
{ "Testing output fixture...\n2 tests run, 0 skipped, 0 pending failures.\n" 0 f } [
    f parser-quiet? [ f verbose-tests? [ f silent-tests? [
        { "resource:basis/tools/test/output-pass.factor"
          "resource:basis/tools/test/output-pass.factor" } capture-test-output
        parser-quiet? get
    ] with-variable ] with-variable ] with-variable
] unit-test

! Verbose output remains available for diagnosing a particular test or load.
{ t t 0 } [
    t verbose-tests? [ f silent-tests? [
        { "resource:basis/tools/test/output-pass.factor" } capture-test-output
        [ [ "Loading " subseq-of? ] [ "Unit Test:" subseq-of? ] bi ] dip
    ] with-variable ] with-variable
] unit-test

{ "" 0 } [
    t verbose-tests? [ t silent-tests? [
        { "resource:basis/tools/test/output-pass.factor" } capture-test-output
    ] with-variable ] with-variable
] unit-test

! Silent mode cannot conceal a failed test or its source location.
{ t 1 } [
    f verbose-tests? [ t silent-tests? [
        { "resource:basis/tools/test/output-fail.factor" } capture-test-output
        [ "output-fail.factor:3: test failed:" subseq-of? ] dip
    ] with-variable ] with-variable
] unit-test

! Skips are aggregated without implying that unexecuted tests passed.
{ "Testing output fixture...\n0 tests run, 1 skipped, 0 pending failures.\n" 0 } [
    f verbose-tests? [ f silent-tests? [
        { "resource:basis/tools/test/output-skip.factor" } capture-test-output
    ] with-variable ] with-variable
] unit-test

{ "1 tests skipped.\n" 0 } [
    f verbose-tests? [ t silent-tests? [
        { "resource:basis/tools/test/output-skip.factor" } capture-test-output
    ] with-variable ] with-variable
] unit-test

: create-test-failure ( -- error )
    [ "hello" throw ] [
        f "path" 25 error-continuation get test-failure boa
    ] recover ;

! Just verifies that the presented output contains a callstack.
{ t } [
    create-test-failure [ error. ] with-string-writer
    "OBJ-CURRENT-THREAD" subseq-of?
] unit-test

! Failure details retain the complete experiment even in concise mode.
{ t } [
    f verbose-tests? [
        create-test-failure { "Unit Test" { 42 } [ 43 ] } >>asset
        [ error. ] with-string-writer
        "Unit Test: { { 42 } [ 43 ] }" subseq-of?
    ] with-variable
] unit-test

! GitHub issue #2053: listener print settings must not affect test files.
{ t 16 } [
    H{
        { number-base 16 }
        { boa-tuples? t }
        { qualified-names? t }
        { nesting-limit 0 }
        { length-limit 1 }
    } [
        [
            [ "resource:basis/tools/test/printer-settings.factor" run-test-file ]
            with-string-writer drop
        ] fake-unit-test empty?
        number-base get
    ] with-variables
] unit-test
