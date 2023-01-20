! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: http.server accessors ;
IN: http.server.filters

TUPLE: filter-responder responder ;

M: filter-responder call-responder*
    responder>> call-responder ;
