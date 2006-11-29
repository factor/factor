PROVIDE: apps/mandel
{ +files+ { "mandel.factor" } }
{ +tests+ { "tests.factor" } } ;

USE: mandel
USE: test

MAIN: apps/mandel [ "mandel.pnm" run>file ] time ;
