REQUIRES: contrib/parser-combinators contrib/concurrency ;

PROVIDE: contrib/space-invaders {
	"cpu-8080.factor"
	"space-invaders.factor"
} { } ;

USE: space-invaders

MAIN: contrib/space-invaders run ;
