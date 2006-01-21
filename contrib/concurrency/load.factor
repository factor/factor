IN: scratchpad
USING: kernel parser compiler words sequences ;

"/contrib/dlists.factor" run-resource
"/contrib/math/load.factor" run-resource

{ 
    "concurrency"
    "concurrency-examples"
} [ "/contrib/concurrency/" swap ".factor" append3 run-resource ] each
