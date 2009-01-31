! Copyright (C) 2004, 2009 Chris Double, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel xml.data xml.writer io.streams.string
xml.literals io.styles ;
IN: html

SYMBOL: html

: write-html ( str -- )
    H{ { html t } } format ;

: print-html ( str -- )
    write-html "\n" write-html ;

: xhtml-preamble ( -- )
    "<?xml version=\"1.0\"?>" write-html
    "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">" write-html ;

: simple-page ( title head-quot body-quot -- )
    [ with-string-writer <unescaped> ] bi@
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
    XML> write-xml ; inline

: render-error ( message -- )
    [XML <span class="error"><-></span> XML] write-xml ;
