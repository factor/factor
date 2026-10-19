USING: classes classes.tuple continuations kernel locals math sequences tools.test
 tools.test.private ;
IN: compiler.test.literal-metadata

<PRIVATE

TUPLE: float-metadata bits ;
TUPLE: tuple-metadata class slots ;

GENERIC: literal-metadata ( obj -- metadata )
M: object literal-metadata ;
M: float literal-metadata double>bits float-metadata boa ;
M: sequence literal-metadata [ literal-metadata ] map ;
M: tuple literal-metadata
    [ class-of ] [ tuple-slots [ literal-metadata ] map ] bi
    tuple-metadata boa ;

:: (literal-metadata-unit-test) ( output input -- error/f failed? tested? )
    [
        { } input with-datastack [ literal-metadata ] map
        output [ literal-metadata ] map assert-sequence= f f
    ] [ t ] recover t ;

PRIVATE>

DEFINE-TEST-WORD: literal-metadata-unit-test
