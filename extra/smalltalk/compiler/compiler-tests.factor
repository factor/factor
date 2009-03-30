USING: smalltalk.compiler tools.test prettyprint smalltalk.ast
stack-checker locals.rewrite.closures kernel accessors
compiler.units sequences ;
IN: smalltalk.compiler.tests

[ 2 1 ] [
    [
        T{ ast-block f
           { "a" "b" }
           {
               T{ ast-message-send f
                  T{ ast-name f "a" }
                  "+"
                  { T{ ast-name f "b" } }
               }
           }
        } compile-method
        [ . ] [ rewrite-closures first infer [ in>> ] [ out>> ] bi ] bi
    ] with-compilation-unit
] unit-test

[ 3 1 ] [
    [
        T{ ast-block f
           { "a" "b" "c" }
           {
               T{ ast-assignment f
                  T{ ast-name f "a" }
                  T{ ast-message-send f
                     T{ ast-name f "a" }
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
        } compile-method
        [ . ] [ rewrite-closures first infer [ in>> ] [ out>> ] bi ] bi
    ] with-compilation-unit
] unit-test