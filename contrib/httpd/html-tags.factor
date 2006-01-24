! cont-html v0.6
!
! Copyright (C) 2004 Chris Double.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!        this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!        this list of conditions and the following disclaimer in the documentation
!        and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: html
USE: prettyprint
USE: strings
USE: lists
USE: kernel
USE: io
USE: namespaces
USE: words
USE: sequences

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
! <a "http://" swap append =href a> "click" write </a>
!
! (url -- )
! <a [ "http://" % % ] "" make =href a> "click" write </a>
!
! Tags that have no 'closing' equivalent have a trailing tag/> form:
!
! <input "text" =type "name" =name "20" =size input/>

SYMBOL: html

: write-html H{ { html t } } format ;

: attrs>string ( alist -- string )
    #! Convert the attrs alist to a string
    #! suitable for embedding in an html tag.
    [ [ " " % dup car % "='" % cdr % "'" % ] each ] "" make ;

: write-attributes ( n: namespace -- )    
    #! With the attribute namespace on the stack, get the attributes
    #! and write them to standard output. If no attributes exist, write
    #! nothing.
    "attrs" get attrs>string write-html ;

: html-word ( name def -- )
    #! Define 'word creating' word to allow
    #! dynamically creating words.
    >r "html" create dup r> define-compound ;
 
: <foo> "<" swap ">" append3 ;

: do-<foo> <foo> write-html ;

: def-for-html-word-<foo> ( name -- )
    #! Return the name and code for the <foo> patterned
    #! word.
    dup <foo> swap [ do-<foo> ] cons html-word define-open ;

: <foo "<" swap append ;

: do-<foo write-html H{ } clone >n V{ } clone "attrs" set ;

: def-for-html-word-<foo ( name -- )
    #! Return the name and code for the <foo patterned
    #! word.
    <foo dup [ do-<foo ] cons html-word drop ;

: foo> ">" append ;

: do-foo> write-attributes n> drop ">" write-html ;

: do-foo/> write-attributes n> drop "/>" write-html ;

: def-for-html-word-foo> ( name -- )
    #! Return the name and code for the foo> patterned
    #! word.
    foo> [ do-foo> ] html-word define-open ;

: </foo> [ "</" % % ">" % ] "" make ;

: def-for-html-word-</foo> ( name -- )
    #! Return the name and code for the </foo> patterned
    #! word.    
    </foo> dup [ write-html ] cons html-word define-close ;

: <foo/> [ "<" % % "/>" % ] "" make ;

: do-<foo/> <foo/> write-html ;

: def-for-html-word-<foo/> ( name -- )
    #! Return the name and code for the <foo/> patterned
    #! word.
    dup <foo/> swap [ do-<foo/> ] cons html-word drop ;

: foo/> "/>" append ;

: def-for-html-word-foo/> ( name -- )
    #! Return the name and code for the foo/> patterned
    #! word.    
    foo/> [ do-foo/> ] html-word define-close ;

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

: define-attribute-word ( name -- )
    dup "=" swap append swap [
        , [ swons "attrs" get push ] %
    ] [ ] make html-word drop ;

! Define some closed HTML tags
[
    "h1" "h2" "h3" "h4" "h5" "h6" "h7" "h8" "h9"    
    "ol" "li" "form" "a" "p" "html" "head" "body" "title"
    "b" "i" "ul" "table" "tr" "td" "th" "pre" "textarea"
    "script" "div" "span" "select" "option" "style"
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
    "width"
] [ define-attribute-word ] each 
