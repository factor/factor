REQUIRES: libs/http-client apps/http-server libs/sqlite libs/xml
    libs/parser-combinators ;
PROVIDE: apps/rss
{ +files+ {
	"rss.factor"
	"rss-reader.factor"
} }
{ +tests+ {
    "test.factor"
} } ;
