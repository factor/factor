! cont-html v0.5
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
! <p> [ "someoutput" write ] </p>
!
! <p> will push the tag on the stack and </p> will call the
! quotation wrapping the output in the tag with no attributes.
!
! <p class= "red" p> [ "someoutput" write ] </p>
!
! This time the opening tag does not have the '>'. It pushes
! the tag on the stack with a boolean at the top for indicating no
! prior attribute value. The next word is assumed to be an attribute
! word. These words are the attribute name followed by '='.
! They set any previous attributes in tbe word and set in the tag
! the current attribute to be processed. 
! Immediately after the attribute word should come the value
! that that attribute will be set to.
! The next attribute word or finishing word (which is the
! html word followed by '>') will actually set the attribute to
! that value in the tag.
! The remaining words are a quotation and the closing tag which
! calls the quotation and displays the attributed HTML tag around
! its output.
!
! The opening tag words push the tag onto the namespace stack
! so values for attributes can be used directly without any stack
! operations:
!
! (url -- )
! <a href= a> [ "Click me" write ] </a>
!
! (url -- )
! <a href= "http://" swap cat2 a> [ "click" write ] </a>
!
! (url -- )
! <a href= <% "http://" % % %> a> [ "click" write ] </a>
!
! Tags that have no 'closing' equivalent have a trailing tag/> form:
!
! <input type= "text" name= "name" size= "20" input/>

: <tag> ( closed? name -- <tag> )
  #! Return a <tag> object which describes the named
  #! HTML tag. closed? should be true false if the
  #! tag does not need have a closing tag printed 
  #! (eg. <br>, <input>). 'attrs' contains a
  #! namespace of name/values for the attributes.
  <namespace> [ 
    "tag" set
    "closed?" set 
    "attrs" <namespace> put
    "last-name" f put
  ] extend ;
  
: set-attr ( value name <tag> -- )
  #! Set the attribute of the <tag> to the given value.
  [ "attrs" get [ set ] bind ] bind ;

: attribute-assign ( <tag> name value -- <tag> )
  #! If value is not false then set the attribute in the
  #! tag, otherwise do nothing (ie. just drop the false values).
  2dup and [ swap pick set-attr ] [ 2drop ] ifte ;

: attrs>string ( namespace -- string )
  #! Convert the attrs namespace to a string
  #! suitable for embedding in an html tag.
  [ 
    vars-values 
    <% [ dup car % "='" % cdr % "' " % ] each %> 
  ] bind ;

: write-open-tag ( <tag> -- )
  #! Write to standard output the opening HTML tag plus
  #! attributes if any.
  [   
    "<" write
    "tag" get write
     "attrs" get [ " " write attrs>string write  ] when* 
     ">" write 
  ] bind ;

: write-close-tag ( <tag> -- )
  #! Write to standard output the closing HTML tag if
  #! the tag requires it.
  [
    "closed?" get [ 
      "</" write
      "tag" get write
      ">" write
    ] when
  ] bind ;

: write-tag ( <tag> quot -- )
  #! Call the quotation, wrapping any output to standard
  #! output within the given HTML tag.
  over write-open-tag dip write-close-tag ;

! HTML tag words
! 
! Each closable HTML tag has four words defined. The example below is for
! <p>:
!
!: <p> ( -- <tag> )
!  #! Pushes the HTML tag on the stack
!  t "p" <tag> ;
!
!:  <p ( -- attr-value n: <tag> )
!   #! Used for setting inline attributes.
!   t "p" <tag> >n f ;
!
!: p> ( n: <tag> last-value -- <tag> )
!  #! Used to close off inline attribute version of word.
!  "last-name" get n> -rot swap attribute-assign ;
!
!: </p> ( <tag> quot -- )
!  #! Calls the quotation, wrapping the output in the tag.
!  write-tag ;
!
! Each open only HTML tag has only three words:
!
! : <input/> ( -- )
!   #! Used for printing the tag with no attributes.
!   f "input" <tag> [ ] write-tag ;
!
! : <input ( -- n: <tag> attr-value )
!   #! Used for setting inline attributes.
!   f "input" <tag> >n f ;
!
! : input/> ( n: <tag> value or f -- )
!   #! Used to close off inline attribute version of word
!   #! and print the tag/
!   "last-name" get n> -rot swap attribute-assign [ ] write-tag ;
!
! Each attribute word has the form xxxx= where 'xxxx' is the attribute
! name. The example below is for href:
!
!: href= ( n: <tag> value or f  -- n: <tag> )
!  "last-name" get n> -rot swap attribute-assign >n "href" "last-name" set ;

: define-compound ( vocab name def -- )
  #! Define 'word creating' word to allow
  #! dynamically creating words.
  >r 2dup swap create r> <compound> define ;

: closed-html-word-names ( name -- )
  #! Return a list of the names of the words
  #! used for a closable HTML tag.
  dup [ "<" swap ">" cat3 ] dip
  dup [ "<" swap cat2 ] dip
  dup [ ">" cat2 ] dip 
  "</" swap ">" cat3 
  3list cons ;

: closed-html-word-code ( name -- )
  #! Return a list of the code for the words
  #! used for the closable HTML tag.
  dup [ <tag> ] cons t swons 
  swap [ <tag> >n f ] cons t swons
  [ "last-name" get n> -rot swap attribute-assign ]
  [ write-tag ]
  3list cons ;

: 2car>pair ( list1 list2 -- cdr cdr pair )
  #! Take the car of two lists and put then in a
  #! pair. The cdr of the two lists remain on the
  #! stack.
  >r uncons swap r> uncons -rot cons ;

: 2list>alist ( list1 list2 alist -- alist )
  #! Append two lists to an alist by
  #! taking the car of each list and
  #! forming it into a pair recursively.
  >r dup [ 
    2car>pair r> swap add 2list>alist
  ] [
    drop drop r>
  ] ifte ;
   
: define-closed-html-word ( name -- ) 
  #! Given an HTML tag name, define the words for
  #! that closable HTML tag.
  dup closed-html-word-names 
  swap closed-html-word-code 
  [ ] 2list>alist
  [ uncons "cont-html" -rot define-compound ] each ;

: open-html-word-names ( name -- )
  #! Return a list of the names of the words
  #! used for a open only HTML tag.
  dup [ "<" swap "/>" cat3 ] dip
  dup [ "<" swap cat2 ] dip
  "/>" cat2 
  2list cons ;

: open-html-word-code ( name -- )
  #! Return a list of the code for the words
  #! used for the open only HTML tag.
  dup [ <tag> [ ] write-tag ] cons f swons 
  swap [ <tag> >n f ] cons f swons
  [ "last-name" get n> -rot swap attribute-assign [ ] write-tag ]
  2list cons ;

: define-open-html-word ( name -- ) 
  #! Given an HTML tag name, define the words for
  #! that open only HTML tag.
  dup open-html-word-names 
  swap open-html-word-code 
  [ ] 2list>alist 
  [ uncons "cont-html" -rot define-compound ] each ;

: define-attribute-word ( name -- )
  #! Given an attribute name, define the word for
  #! that attribute.
  "cont-html" swap 
  dup "=" cat2 
  swap [ "last-name" get n> -rot swap attribute-assign >n ] swap add  
  [ "last-name" set ] append
  define-compound ;

! Define some open HTML tags
[ 
  "h1" "h2" "h3" "h4" "h5" "h6" "h7" "h8" "h9" 
  "ol" "li" "form" "a" "p" "html" "head" "body" "title"
  "b" "i" "ul" "table" "tr" "td" "th" "pre" "textarea"
  "script" "div" "span"
] [ define-closed-html-word ] each

! Define some closed HTML tags
[ 
  "input" 
  "br" 
] [ define-open-html-word ] each

! Define some attributes
[ 
  "method" "action" "type" "value" "name" 
  "size" "href" "class" "border" "rows" "cols" 
  "id" "onclick" "style" "valign" "accesskey"
  "src" "language"
] [ define-attribute-word ] each 