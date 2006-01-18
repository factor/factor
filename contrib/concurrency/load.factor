IN: scratchpad
USING: kernel parser compiler words sequences ;

"contrib/dlists.factor" run-file
"contrib/math/load.factor" run-file

{ "concurrency" "concurrency-examples" }
dup
[ "contrib/concurrency/" swap ".factor" append3 run-file ] each
[ words [ try-compile ] each ] each
