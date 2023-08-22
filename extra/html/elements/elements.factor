! Copyright (C) 2004, 2009 Chris Double, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: io.styles kernel present sequences words xml.entities ;
IN: html.elements

SYMBOL: html

: write-html ( str -- )
    H{ { html t } } format ;

: print-html ( str -- )
    write-html "\n" write-html ;

<<

CONSTANT: elements-vocab "html.elements"

: html-word ( name def effect -- )
    ! Define 'word creating' word to allow
    ! dynamically creating words.
    [ elements-vocab create-word ] 2dip define-declared ;

: <foo> ( str -- <str> ) "<" ">" surround ;

: def-for-html-word-<foo> ( name -- )
    ! Return the name and code for the <foo> patterned
    ! word.
    dup <foo> swap '[ _ <foo> write-html ]
    ( -- ) html-word ;

: <foo ( str -- <str ) "<" prepend ;

: def-for-html-word-<foo ( name -- )
    ! Return the name and code for the <foo patterned
    ! word.
    <foo dup '[ _ write-html ]
    ( -- ) html-word ;

: foo> ( str -- foo> ) ">" append ;

: def-for-html-word-foo> ( name -- )
    ! Return the name and code for the foo> patterned
    ! word.
    foo> [ ">" write-html ] ( -- ) html-word ;

: </foo> ( str -- </str> ) "</" ">" surround ;

: def-for-html-word-</foo> ( name -- )
    ! Return the name and code for the </foo> patterned
    ! word.
    </foo> dup '[ _ write-html ] ( -- ) html-word ;

: <foo/> ( str -- <str/> ) "<" "/>" surround ;

: def-for-html-word-<foo/> ( name -- )
    ! Return the name and code for the <foo/> patterned
    ! word.
    dup <foo/> swap '[ _ <foo/> write-html ]
    ( -- ) html-word ;

: foo/> ( str -- str/> ) "/>" append ;

: def-for-html-word-foo/> ( name -- )
    ! Return the name and code for the foo/> patterned
    ! word.
    foo/> [ "/>" write-html ] ( -- ) html-word ;

: define-closed-html-word ( name -- )
    ! Given an HTML tag name, define the words for
    ! that closable HTML tag.
    dup def-for-html-word-<foo>
    dup def-for-html-word-<foo
    dup def-for-html-word-foo>
    def-for-html-word-</foo> ;

: define-open-html-word ( name -- )
    ! Given an HTML tag name, define the words for
    ! that open HTML tag.
    dup def-for-html-word-<foo/>
    dup def-for-html-word-<foo
    def-for-html-word-foo/> ;

: write-attr ( value name -- )
    " " write-html
    write-html
    "='" write-html
    present escape-quoted-string write-html
    "'" write-html ;

: define-attribute-word ( name -- )
    dup "=" prepend swap
    '[ _ write-attr ] ( string -- ) html-word ;

! Define some closed HTML tags
[
    "h1" "h2" "h3" "h4" "h5" "h6" "h7" "h8" "h9"
    "ol" "li" "form" "a" "p" "html" "head" "body" "title"
    "b" "i" "ul" "table" "thead" "tfoot" "tbody" "tr" "td" "th" "pre" "textarea"
    "script" "div" "span" "select" "option" "style" "input"
    "strong"
] [ define-closed-html-word ] each

! Define some open HTML tags
[
    "input"
    "br"
    "hr"
    "link"
    "img"
    "base"
] [ define-open-html-word ] each

! Define some attributes
[
    "method" "action" "type" "value" "name"
    "size" "href" "class" "border" "rows" "cols"
    "id" "onclick" "style" "valign" "accesskey"
    "src" "language" "colspan" "onchange" "rel"
    "width" "selected" "onsubmit" "xmlns" "lang" "xml:lang"
    "media" "title" "multiple" "checked"
    "summary" "cellspacing" "align" "scope" "abbr"
    "nofollow" "alt" "target"
] [ define-attribute-word ] each

>>
