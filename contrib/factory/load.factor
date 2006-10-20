REQUIRES: contrib/process contrib/concurrency contrib/x11
contrib/vars ;

PROVIDE: contrib/factory { "factory.factor" } ;

USE: factory

MAIN: contrib/factory f start-factory ;
