! Signature coverage requires no raylib shared library or GUI initialization.
USING: effects raylib tools.test words ;
IN: raylib.tests

{ ( logLevel text args -- ) } [
    \ TraceLogCallback "callback-effect" word-prop
] unit-test
