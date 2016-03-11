! Copyright (C) 2004, 2009 Chris Double, Daniel Ehrenberg,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel xml.data xml.writer xml.syntax 
urls.encoding ;
IN: html

TUPLE: empty-prolog < prolog ;
M: empty-prolog write-xml drop ;
: <empty-prolog> ( -- prolog ) \ empty-prolog new ;

: simple-page ( title head body -- xml )
    <XML
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
            <head>
                <title><-></title>
                <->
            </head>
            <body><-></body>
        </html>
    XML> <empty-prolog> >>prolog ;

: render-error ( message -- xml )
    [XML <span class="error"><-></span> XML] ;

: simple-link ( xml url -- xml' )
    url-encode swap [XML <a href=<->><-></a> XML] ;

: simple-image ( url -- xml )
    url-encode [XML <img src=<-> /> XML] ;
