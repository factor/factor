REQUIRES: contrib/httpd ;

PROVIDE: contrib/furnace
{ +files+ { 
    "validator.factor"
    "responder.factor"
    "tools/help.factor"
    "tools/browser.factor"
} }
{ +tests+ { 
    "test/validator.factor"
    "test/responder.factor"
} } ;
