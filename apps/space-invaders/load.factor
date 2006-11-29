REQUIRES: libs/parser-combinators libs/concurrency ;

PROVIDE: apps/space-invaders
{ +files+ {
	"cpu-8080.factor"
	"space-invaders.factor"
} } ;

USE: space-invaders

MAIN: apps/space-invaders run ;
