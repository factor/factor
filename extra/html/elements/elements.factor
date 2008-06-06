! cont-html v0.6
!
! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: io kernel namespaces prettyprint quotations
sequences strings words xml.entities compiler.units effects
urls math math.parser combinators present ;

IN: html.elements

! These words are used to provide a means of writing
! formatted HTML to standard output with a familiar 'html' look
! and feel in the code.
!
! HTML tags can be used in a number of different ways. The highest
! level involves a similar syntax to HTML:
!
! <p> "someoutput" write </p>
!
! <p> will output the opening tag and </p> will output the closing
! tag with no attributes.
!
! <p "red" =class p> "someoutput" write </p>
!
! This time the opening tag does not have the '>'. It pushes
! a namespace on the stack to hold the attributes and values.
! Any attribute words used will store the attribute and values
! in that namespace. Before the attribute word should come the
! value of that attribute.
! The finishing word will print out the operning tag including
! attributes.
! Any writes after this will appear after the opening tag.
!
! Values for attributes can be used directly without any stack
! operations:
!
! (url -- )
! <a =href a> "Click me" write </a>
!
! (url -- )
! <a "http://" prepend =href a> "click" write </a>
!
! (url -- )
! <a [ "http://" % % ] "" make =href a> "click" write </a>
!
! Tags that have no 'closing' equivalent have a trailing tag/> form:
!
! <input "text" =type "name" =name "20" =size input/>

: elements-vocab ( -- vocab-name ) "html.elements" ;

SYMBOL: html

: write-html ( str -- )
    H{ { html t } } format ;

: print-html ( str -- )
    write-html "\n" write-html ;

<<

: html-word ( name def effect -- )
    #! Define 'word creating' word to allow
    #! dynamically creating words.
    >r >r elements-vocab create r> r> define-declared ;

: <foo> "<" swap ">" 3append ;

: empty-effect T{ effect f 0 0 } ;

: def-for-html-word-<foo> ( name -- )
    #! Return the name and code for the <foo> patterned
    #! word.
    dup <foo> swap [ <foo> write-html ] curry
    empty-effect html-word ;

: <foo "<" prepend ;

: def-for-html-word-<foo ( name -- )
    #! Return the name and code for the <foo patterned
    #! word.
    <foo dup [ write-html ] curry
    empty-effect html-word ;

: foo> ">" append ;

: def-for-html-word-foo> ( name -- )
    #! Return the name and code for the foo> patterned
    #! word.
    foo> [ ">" write-html ] empty-effect html-word ;

: </foo> "</" swap ">" 3append ;

: def-for-html-word-</foo> ( name -- )
    #! Return the name and code for the </foo> patterned
    #! word.
    </foo> dup [ write-html ] curry empty-effect html-word ;

: <foo/> "<" swap "/>" 3append ;

: def-for-html-word-<foo/> ( name -- )
    #! Return the name and code for the <foo/> patterned
    #! word.
    dup <foo/> swap [ <foo/> write-html ] curry
    empty-effect html-word ;

: foo/> "/>" append ;

: def-for-html-word-foo/> ( name -- )
    #! Return the name and code for the foo/> patterned
    #! word.
    foo/> [ "/>" write-html ] empty-effect html-word ;

: define-closed-html-word ( name -- )
    #! Given an HTML tag name, define the words for
    #! that closable HTML tag.
    dup def-for-html-word-<foo>
    dup def-for-html-word-<foo
    dup def-for-html-word-foo>
    def-for-html-word-</foo> ;

: define-open-html-word ( name -- )
    #! Given an HTML tag name, define the words for
    #! that open HTML tag.
    dup def-for-html-word-<foo/>
    dup def-for-html-word-<foo
    def-for-html-word-foo/> ;

: write-attr ( value name -- )
    " " write-html
    write-html
    "='" write-html
    present escape-quoted-string write-html
    "'" write-html ;

: attribute-effect T{ effect f { "string" } 0 } ;

: define-attribute-word ( name -- )
    dup "=" prepend swap
    [ write-attr ] curry attribute-effect html-word ;

! Define some closed HTML tags
[
    "h1" "h2" "h3" "h4" "h5" "h6" "h7" "h8" "h9"
    "ol" "li" "form" "a" "p" "html" "head" "body" "title"
    "b" "i" "ul" "table" "tbody" "tr" "td" "th" "pre" "textarea"
    "script" "div" "span" "select" "option" "style" "input"
] [ define-closed-html-word ] each

! Define some open HTML tags
[
    "input"
    "br"
    "link"
    "img"
] [ define-open-html-word ] each

! Define some attributes
[
    "method" "action" "type" "value" "name"
    "size" "href" "class" "border" "rows" "cols"
    "id" "onclick" "style" "valign" "accesskey"
    "src" "language" "colspan" "onchange" "rel"
    "width" "selected" "onsubmit" "xmlns" "lang" "xml:lang"
    "media" "title" "multiple" "checked"
] [ define-attribute-word ] each

>>

: xhtml-preamble ( -- )
    "<?xml version=\"1.0\"?>" write-html
    "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">" write-html ;

: simple-page ( title quot -- )
    #! Call the quotation, with all output going to the
    #! body of an html page with the given title.
    xhtml-preamble
    <html "http://www.w3.org/1999/xhtml" =xmlns "en" =xml:lang "en" =lang html>
        <head> <title> swap write </title> </head>
        <body> call </body>
    </html> ; inline

: render-error ( message -- )
    <span "error" =class span> escape-string write </span> ;
