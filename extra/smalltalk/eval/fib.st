class Fib [
    |i|
    method i: newI [i:=newI].
    method compute [
        (i <= 1)
          ifTrue: [^1]
          ifFalse: [^((Fib new i:(i-1)) compute + (Fib new i:(i-2)) compute)]
    ].
].

[(Fib new i: 26) compute] time