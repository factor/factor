USING: compiler.errors stack-checker.errors tools.test words ;
IN: tools.errors

DEFER: blah

[ ] [
    {
        T{ compiler-error
           { error
             T{ inference-error
                f
                T{ do-not-compile f blah }
                +compiler-error+
                blah
             }
           }
           { asset blah }
        }
    } errors.
] unit-test