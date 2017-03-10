USING: compiler.cfg.registers io.streams.string prettyprint tools.test ;
IN: compiler.cfg.registers.tests

! Ensure prettyprinting of ds/rs-loc is right

{ "D: 3\nR: -1\n" } [
    [ D: 3 . R: -1 . ] with-string-writer
] unit-test
