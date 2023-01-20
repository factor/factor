! Copyright (c) 2008, 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit furnace.utilities
html.forms html.templates html.templates.chloe http.server
http.server.filters kernel ;
IN: furnace.boilerplate

TUPLE: boilerplate < filter-responder template init ;

: <boilerplate> ( responder -- boilerplate )
    boilerplate new
        swap >>responder
        [ ] >>init ;

: wrap-boilerplate? ( response -- ? )
    { [ code>> 200 = ] [ content-type>> "text/html" = ] } 1&& ;

M:: boilerplate call-responder* ( path responder -- response )
    begin-form
    path responder call-next-method
    responder init>> call( -- )
    dup wrap-boilerplate? [
        clone [| body |
            [
                body
                responder template>> resolve-template-path <chloe>
                with-boilerplate
            ]
        ] change-body
    ] when ;
