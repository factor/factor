REQUIRES: apps/http-server libs/basic-authentication ;

PROVIDE: libs/furnace
{ +files+ { 
    "validator.factor"
    "responder.factor"
    "tools/help.factor"
    "tools/browser.factor"
    "scaffold.factor"
} }
{ +tests+ { 
    "test/validator.factor"
    "test/responder.factor"
} } ;
