REQUIRES: libs/http-client libs/httpd libs/sqlite libs/xml
    libs/parser-combinators ;
PROVIDE: apps/rss
{ +files+ {
	"rss.factor"
	"rss-reader.factor"
} }
{ +tests+ {
    "test.factor"
} } ;
