USING: accessors alien.prettyprint combinators
combinators.short-circuit cuda.libraries cuda.syntax definitions
effects kernel prettyprint.backend prettyprint.sections see
see.private sequences words ;
IN: cuda.prettyprint

PREDICATE: cuda-function-word < word
    def>> { [ length 14 = ] [ last \ cuda-invoke eq? ] } 1&& ;

: pprint-cuda-library ( library -- )
    [ \ CUDA-LIBRARY: [ text ] pprint-prefix ] when* ;

: pprint-cuda-function ( word quot -- )
    [
        <block "(" text
        [ def>> third ] [ stack-effect in>> ] bi
        pprint-function-args
        ")" text block>
    ] bi ; inline

M: cuda-function-word definer drop \ CUDA-FUNCTION: \ ; ;
M: cuda-function-word definition drop f ;
M: cuda-function-word synopsis*
    {
        [ seeing-word ]
        [ definer. ]
        [ [ pprint-word ] pprint-cuda-function ]
    } cleave ;
