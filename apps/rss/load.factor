REQUIRES: libs/http-client libs/httpd libs/sqlite ;
PROVIDE: apps/rss
{ +files+ {
	"rss.factor"
	"rss-reader.factor"
} } ;
