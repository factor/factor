! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces
html.forms
html.templates
html.templates.chloe
locals
http.server
http.server.filters
furnace ;
IN: furnace.boilerplate

TUPLE: boilerplate < filter-responder template init ;

: <boilerplate> ( responder -- boilerplate )
    boilerplate new
        swap >>responder
        [ ] >>init ;

M:: boilerplate call-responder* ( path responder -- )
    begin-form
    path responder call-next-method
    responder init>> call
    dup content-type>> "text/html" = [
        clone [| body |
            [
                body
                responder template>> resolve-template-path <chloe>
                with-boilerplate
            ]
        ] change-body
    ] when ;
