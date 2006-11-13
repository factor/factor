PROVIDE: examples/mandel
{ +files+ { "mandel.factor" } }
{ +tests+ { "tests.factor" } } ;

USE: mandel
USE: test

MAIN: examples/mandel [ "mandel.pnm" run>file ] time ;
