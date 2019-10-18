USING: smalltalk.parser smalltalk.compiler.return tools.test ;

[ t ] [ "(i <= 1) ifTrue: [^1] ifFalse: [^((Fib new i:(i-1)) compute + (Fib new i:(i-2)) compute)]" parse-smalltalk need-return-continuation? ] unit-test