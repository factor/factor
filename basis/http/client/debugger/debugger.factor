! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel summary debugger io make math.parser
prettyprint http http.client accessors ;
IN: http.client.debugger

M: too-many-redirects summary
    drop
    [ "Redirection limit of " % max-redirects # " exceeded" % ] "" make ;

M: download-failed error.
    "HTTP request failed:" print nl
    response>> ... ;
