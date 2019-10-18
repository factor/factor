IN: scratchpad
USING: parser compiler words sequences io ;

"../parser-combinators/lazy.factor" run-file
"../parser-combinators/parser-combinators.factor" run-file
"cpu-8080.factor" run-file 
"space-invaders.factor" run-file

"cpu-8080" words [ try-compile ] each
"space-invaders" words [ try-compile ] each

"Use 'run' in the 'space-invaders' vocabulary to start." print