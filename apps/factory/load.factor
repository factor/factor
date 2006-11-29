REQUIRES: libs/process libs/concurrency libs/x11 libs/vars ;

PROVIDE: apps/factory { +files+ {  "factory.factor" } } ;

USE: factory

MAIN: apps/factory f start-factory ;
