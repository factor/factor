IN: scratchpad
USING: kernel parser compiler words sequences ;

"contrib/dlists.factor" run-file
"contrib/math/load.factor" run-file

{ 
    "concurrency"
    "concurrency-examples"
} [ "contrib/concurrency/" swap ".factor" append3 run-file ] each
