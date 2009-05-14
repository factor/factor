USING: generic kernel kernel.private math memory prettyprint io
sequences tools.test words namespaces layouts classes
classes.builtin arrays quotations io.launcher system ;
IN: memory.tests

[ ] [ { } { } become ] unit-test

! LOL
[ ] [
    vm
    "-i=" image append
    "-generations=2"
    "-e=USING: memory io prettyprint system ; input-stream gc . 0 exit"
    4array try-process
] unit-test

[ [ ] instances ] must-infer

! Code GC wasn't kicking in when needed
: leak-step ( -- ) 800000 f <array> 1quotation call( -- obj ) drop ;

: leak-loop ( -- ) 100 [ leak-step ] times ;

[ ] [ leak-loop ] unit-test

TUPLE: testing x y z ;

[ save-image-and-exit ] must-fail

! Erg's bug
2 [ [ [ 3 throw ] instances ] must-fail ] times

! Bug found on Windows build box, having too many words in the image breaks 'become'
[ ] [ 100000 [ f f <word> ] replicate { } { } become drop ] unit-test
