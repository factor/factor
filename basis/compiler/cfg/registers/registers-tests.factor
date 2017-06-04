USING: compiler.cfg.registers io.streams.string prettyprint tools.test ;
IN: compiler.cfg.registers.tests

! Ensure prettyprinting of ds/rs-loc is right

{ "d: 3\nr: -1\n" } [
    [ d: 3 . r: -1 . ] with-string-writer
] unit-test
