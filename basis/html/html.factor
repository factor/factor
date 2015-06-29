! Copyright (C) 2004, 2009 Chris Double, Daniel Ehrenberg,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel xml.data xml.writer xml.syntax urls.encoding ;
IN: html

: simple-page ( title head body -- xml )
    <XML
        <?xml version="1.0"?>
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
            <head>
                <title><-></title>
                <->
            </head>
            <body><-></body>
        </html>
    XML> ;

: render-error ( message -- xml )
    [XML <span class="error"><-></span> XML] ;

: simple-link ( xml url -- xml' )
    url-encode swap [XML <a href=<->><-></a> XML] ;

: simple-image ( url -- xml )
    url-encode [XML <img src=<-> /> XML] ;
