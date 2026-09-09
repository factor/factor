USING: alien alien.c-types alien.varargs arrays compiler.test continuations
kernel locals namespaces raylib tools.test ;
IN: raylib.tests

SYMBOL: raylib-log-result
:: capture-raylib-log ( level text args -- )
    level text args int va-arg args double va-arg
    4array raylib-log-result set-global ;

{ { 3 "%d/%.2f" 7 2.5 } } [ [
    [ capture-raylib-log ] TraceLogCallback [| callback |
        [
            LOG_ALL set-trace-log-level
            callback set-trace-log-callback
            LOG_INFO "%d/%.2f" 7 2.5 raylib-test-log
            raylib-log-result get-global
        ] [ f set-trace-log-callback LOG_INFO set-trace-log-level ] finally
    ] with-callback
] compile-call ] unit-test
