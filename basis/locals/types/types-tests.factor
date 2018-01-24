USING: accessors compiler.units kernel locals.types tools.test words ;
IN: locals.types.tests

{ t } [
    [ "hello" <local> ] with-compilation-unit "local?" word-prop
] unit-test

{ t "hello!" } [
    [ "hello" <local-reader> <local-writer> ] with-compilation-unit
    [ "local-writer?" word-prop ] [ name>> ] bi
] unit-test
