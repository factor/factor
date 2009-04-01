USING: smalltalk.compiler tools.test prettyprint smalltalk.ast
smalltalk.compiler.lexenv stack-checker locals.rewrite.closures
kernel accessors compiler.units sequences arrays ;
IN: smalltalk.compiler.tests

: test-compilation ( ast -- quot )
    [
        1array ast-sequence new swap >>body
        compile-smalltalk [ call ] append
    ] with-compilation-unit ;

: test-inference ( ast -- in# out# )
    test-compilation infer [ in>> ] [ out>> ] bi ;

[ 2 1 ] [
    T{ ast-block f
       { "a" "b" }
       {
           T{ ast-message-send f
              T{ ast-name f "a" }
              "+"
              { T{ ast-name f "b" } }
           }
       }
    } test-inference
] unit-test

[ 3 1 ] [
    T{ ast-block f
       { "a" "b" "c" }
       {
           T{ ast-assignment f
              T{ ast-name f "a" }
              T{ ast-message-send f
                 T{ ast-name f "c" }
                 "+"
                 { T{ ast-name f "b" } }
              }
           }
           T{ ast-message-send f
              T{ ast-name f "b" }
              "blah:"
              { 123.456 }
           }
           T{ ast-return f T{ ast-name f "c" } }
       }
    } test-inference
] unit-test

[ 0 1 ] [
    T{ ast-block f
       { }
       { }
       {
           T{ ast-message-send
              { receiver 1 }
              { selector "to:do:" }
              { arguments
                {
                    10
                    T{ ast-block
                       { arguments { "i" } }
                       { body
                         {
                             T{ ast-message-send
                                { receiver
                                  T{ ast-name { name "i" } }
                                }
                                { selector "print" }
                             }
                         }
                       }
                    }
                }
              }
           }
       }
    } test-inference
] unit-test

[ "a" ] [
    T{ ast-block f
       { }
       { }
       { { T{ ast-block { body { "a" } } } } }
    } test-compilation call first call
] unit-test