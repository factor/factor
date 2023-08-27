! Copyright (C) 2004, 2009 Chris Double, Daniel Ehrenberg,
! Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel present urls urls.encoding xml.data
xml.writer xml.syntax ;
IN: html

TUPLE: empty-prolog < prolog ;
M: empty-prolog write-xml drop ;
: <empty-prolog> ( -- prolog ) \ empty-prolog new ;

: simple-page ( title head body -- xml )
    <XML
        <!DOCTYPE html>
        <html xmlns="https://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
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
    >url present swap [XML <a href=<->><-></a> XML] ;

: simple-image ( url -- xml )
    >url present [XML <img src=<-> /> XML] ;
