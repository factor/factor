! cont-html v0.6
!
! Copyright (C) 2004 Chris Double.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
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
IN: cont-html
USE: strings
USE: lists
USE: format
USE: stack
USE: combinators
USE: stdio
USE: namespaces
USE: words
USE: vocabularies
USE: logic

! These words in cont-html are used to provide a means of writing
! formatted HTML to standard output with a familiar 'html' look
! and feel in the code. 
!
! HTML tags can be used in a number of different ways. The highest
! level involves a similar syntax to HTML:
! 
! <p> "someoutput" write </p>
!
! <p> will outupt the opening tag and </p> will output the closing
! tag with no attributes.
!
! <p class= "red" p> "someoutput" write </p>
!
! This time the opening tag does not have the '>'. It pushes
! a namespace on the stack to hold the attributes and values.
! Any attribute words used will store the attribute and values
! in that namespace. After the attribute word should come the
! value of that attribute. The next attribute word or 
! finishing word (which is the html word followed by '>') 
! will actually set the attribute to that value in the namespace.
! The finishing word will print out the operning tag including
! attributes. 
! Any writes after this will appear after the opening tag.
!
! Values for attributes can be used directly without any stack
! operations:
!
! (url -- )
! <a href= a> "Click me" write </a>
!
! (url -- )
! <a href= "http://" swap cat2 a> "click" write </a>
!
! (url -- )
! <a href= <% "http://" % % %> a> "click" write </a>
!
! Tags that have no 'closing' equivalent have a trailing tag/> form:
!
! <input type= "text" name= "name" size= "20" input/>

: attrs>string ( alist -- string )
  #! Convert the attrs alist to a string
  #! suitable for embedding in an html tag.
  nreverse <% [ dup car % "='" % cdr % "'" % ] each %> ;

: write-attributes ( n: namespace -- )  
  #! With the attribute namespace on the stack, get the attributes
  #! and write them to standard output. If no attributes exist, write
  #! nothing.
  "attrs" get [ " " write attrs>string write ] when* ;

: store-prev-attribute ( n: tag value -- )   
  #! Assumes an attribute namespace is on the stack.
  #! Gets the previous attribute that was used (if any)
  #! and sets it's value to the current value on the stack.
  #! If there is no previous attribute, no value is expected
  #! on the stack.
  "current-attribute" get [ swons "attrs" cons@ ] when* ;

! HTML tag words
! 
! Each closable HTML tag has four words defined. The example below is for
! <p>:
!
!: <p> ( -- )
!  #! Writes the opening tag to standard output.
!  "<p>" write ;

!:  <p ( -- n: <namespace> )
!   #! Used for setting inline attributes. Prints out
!   #! an unclosed opening tag.
!   "<p" write <namespace> >n ;
!
!: p> ( n: <namespace> -- )
!  #! Used to close off inline attribute version of word.
!  #! Prints out attributes and closes opening tag.
!   store-prev-attribute write-attributes n> drop ">" write ;
!
!: </p> ( -- )
!  #! Write out the closing tag.
!  "</foo>" write ;
!
! Each open only HTML tag has only three words:
!
! : <input/> ( -- )
!   #! Used for printing the tag with no attributes.
!   "<input>" write ;
!
! : <input ( -- n: <namespace> )
!   #! Used for setting inline attributes.
!   "<input" write <namespace> >n ;
!
! : input/> ( n: <namespace> -- )
!   #! Used to close off inline attribute version of word
!   #! and print the tag/
!   store-prev-attribute write-attributes n> drop ">" write ;
!
! Each attribute word has the form xxxx= where 'xxxx' is the attribute
! name. The example below is for href:
!
!: href= ( n: <namespace> optional-value -- )
!  store-prev-attribute "href" "current-attribute" set ;

: define-compound ( vocab name def -- )
  #! Define 'word creating' word to allow
  #! dynamically creating words.
  >r 2dup swap create r> <compound> define ;
 
: def-for-html-word-<foo> ( name -- name quot )
  #! Return the name and code for the <foo> patterned
  #! word.
  <% "<" % % ">" % %> dup [ write ] cons ;

: def-for-html-word-<foo ( name -- name quot )
  #! Return the name and code for the <foo patterned
  #! word.
  <% "<" % % %> dup [ write <namespace> >n ] cons ;

: def-for-html-word-foo> ( name -- name quot )
  #! Return the name and code for the foo> patterned
  #! word.  
  <% % ">" % %> [ store-prev-attribute write-attributes n> drop  ">" write ] ;

: def-for-html-word-</foo> ( name -- name quot )
  #! Return the name and code for the </foo> patterned
  #! word.  
  <% "</" % % ">" % %> dup [ write ] cons ;

: def-for-html-word-<foo/> ( name -- name quot )
  #! Return the name and code for the <foo/> patterned
  #! word.  
  <% "<" % dup % "/>" % %> swap <% "<" % % ">" % %> [ write ] cons ;

: def-for-html-word-foo/> ( name -- name quot )
  #! Return the name and code for the foo/> patterned
  #! word.  
  <% % "/>" % %> [ store-prev-attribute write-attributes n> drop  ">" write ] ;

: define-closed-html-word ( name -- ) 
  #! Given an HTML tag name, define the words for
  #! that closable HTML tag.
  "cont-html" swap
  2dup def-for-html-word-<foo> define-compound
  2dup def-for-html-word-<foo define-compound
  2dup def-for-html-word-foo> define-compound
  def-for-html-word-</foo> define-compound ;

: define-open-html-word ( name -- ) 
  #! Given an HTML tag name, define the words for
  #! that open HTML tag.
  "cont-html" swap
  2dup def-for-html-word-<foo/> define-compound
  2dup def-for-html-word-<foo define-compound
  def-for-html-word-foo/> define-compound ;

: define-attribute-word ( name -- )
  "cont-html" swap dup "=" cat2 swap 
  [ store-prev-attribute ] cons reverse [ "current-attribute" set ] append define-compound ;

! Define some closed HTML tags
[ 
  "h1" "h2" "h3" "h4" "h5" "h6" "h7" "h8" "h9" 
  "ol" "li" "form" "a" "p" "html" "head" "body" "title"
  "b" "i" "ul" "table" "tr" "td" "th" "pre" "textarea"
  "script" "div" "span" "select" "option"
] [ define-closed-html-word ] each

! Define some open HTML tags
[ 
  "input" 
  "br" 
  "link"
] [ define-open-html-word ] each

! Define some attributes
[ 
  "method" "action" "type" "value" "name" 
  "size" "href" "class" "border" "rows" "cols" 
  "id" "onclick" "style" "valign" "accesskey"
  "src" "language" "colspan" "onchange" "rel"
  "width"
] [ define-attribute-word ] each 