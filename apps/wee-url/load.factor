REQUIRES: libs/httpd libs/serialize ;

PROVIDE: apps/wee-url
{ +files+ { "store.factor" "responder.factor" } } ;
