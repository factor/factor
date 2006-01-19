IN: scratchpad
USING: kernel parser sequences words compiler ;

{ "lazy" "parser-combinators" "lazy-examples" "tests" }
[ "contrib/parser-combinators/" swap ".factor" append3 run-file ] each

{ "lazy" "lazy-examples" "parser-combinators" }
[ words [ try-compile ] each ] each
