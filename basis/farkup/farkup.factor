! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators html.elements io
io.streams.string kernel math namespaces peg peg.ebnf
sequences sequences.deep strings xml.entities
vectors splitting xmode.code2html urls.encoding ;
IN: farkup

SYMBOL: relative-link-prefix
SYMBOL: disable-images?
SYMBOL: link-no-follow?
SYMBOL: line-breaks?

TUPLE: heading1 child ;
TUPLE: heading2 child ;
TUPLE: heading3 child ;
TUPLE: heading4 child ;
TUPLE: strong child ;
TUPLE: emphasis child ;
TUPLE: superscript child ;
TUPLE: subscript child ;
TUPLE: inline-code child ;
TUPLE: paragraph child ;
TUPLE: list-item child ;
TUPLE: unordered-list child ;
TUPLE: ordered-list child ;
TUPLE: table child ;
TUPLE: table-row child ;
TUPLE: link href text ;
TUPLE: image href text ;
TUPLE: code mode string ;
TUPLE: line ;
TUPLE: line-break ;

: absolute-url? ( string -- ? )
    { "http://" "https://" "ftp://" } [ head? ] with contains? ;

: simple-link-title ( string -- string' )
    dup absolute-url? [ "/" split1-last swap or ] unless ;

EBNF: parse-farkup
nl               = ("\r\n" | "\r" | "\n") => [[ drop "\n" ]]
whitespace       = " " | "\t" | nl

heading1      = "=" (!("=" | nl).)+ "="
    => [[ second >string heading1 boa ]]

heading2      = "==" (!("=" | nl).)+ "=="
    => [[ second >string heading2 boa ]]

heading3      = "===" (!("=" | nl).)+ "==="
    => [[ second >string heading3 boa ]]

heading4      = "====" (!("=" | nl).)+ "===="
    => [[ second >string heading4 boa ]]

heading          = heading4 | heading3 | heading2 | heading1



strong        = "*" (!("*" | nl).)+ "*"
    => [[ second >string strong boa ]]

emphasis      = "_" (!("_" | nl).)+ "_"
    => [[ second >string emphasis boa ]]

superscript   = "^" (!("^" | nl).)+ "^"
    => [[ second >string superscript boa ]]

subscript     = "~" (!("~" | nl).)+ "~"
    => [[ second >string subscript boa ]]

inline-code   = "%" (!("%" | nl).)+ "%"
    => [[ second >string inline-code boa ]]

link-content     = (!("|"|"]").)+

image-link       = "[[image:" link-content  "|" link-content "]]"
                    => [[ [ second >string ] [ fourth >string ] bi image boa ]]
                  | "[[image:" link-content "]]"
                    => [[ second >string f image boa ]]

simple-link      = "[[" link-content "]]"
    => [[ second >string dup simple-link-title link boa ]]

labelled-link    = "[[" link-content "|" link-content "]]"
    => [[ [ second >string ] [ fourth >string ] bi link boa ]]

link             = image-link | labelled-link | simple-link

escaped-char  = "\" .
    => [[ second 1string ]]

inline-tag       = strong | emphasis | superscript | subscript | inline-code
                   | link | escaped-char



inline-delimiter = '*' | '_' | '^' | '~' | '%' | '\' | '['

cell             = (!(inline-delimiter | '|' | nl).)+
    => [[ >string ]]
    
table-column     = (list | cell | inline-tag | inline-delimiter  ) '|'
    => [[ first ]]
table-row        = "|" (table-column)+
    => [[ second table-row boa ]]
table            =  ((table-row nl => [[ first ]] )+ table-row? | table-row)
    => [[ table boa ]]

text = (!(nl | code | heading | inline-delimiter | table ).)+
    => [[ >string ]]

paragraph-nl-item = nl list
    | nl line
    | nl => [[ line-breaks? get [ drop line-break new ] when ]]
paragraph-item = (table | code | text | inline-tag | inline-delimiter)+
paragraph = ((paragraph-item paragraph-nl-item)+ nl+ => [[ first ]]
             | (paragraph-item paragraph-nl-item)+ paragraph-item?
             | paragraph-item)
    => [[ paragraph boa ]]


list-item     = (cell | inline-tag | inline-delimiter)*

ordered-list-item      = '#' list-item
    => [[ second list-item boa ]]
ordered-list = ((ordered-list-item nl)+ ordered-list-item? | ordered-list-item)
    => [[ ordered-list boa ]]

unordered-list-item    = '-' list-item
    => [[ second list-item boa ]]
unordered-list = ((unordered-list-item nl)+ unordered-list-item? | unordered-list-item)
    => [[ unordered-list boa ]]

list = ordered-list | unordered-list


line = '___'
    => [[ drop line new ]]


named-code
           =  '[' (!('{' | whitespace | '[').)+ '{' (!("}]").)+ "}]"
    => [[ [ second >string ] [ fourth >string ] bi code boa ]]

simple-code
           = "[{" (!("}]").)+ "}]"
    => [[ second f swap code boa ]]

code = named-code | simple-code


stand-alone
           = (line | code | heading | list | table | paragraph | nl)*
;EBNF

: invalid-url "javascript:alert('Invalid URL in farkup');" ;

: check-url ( href -- href' )
    {
        { [ dup empty? ] [ drop invalid-url ] }
        { [ dup [ 127 > ] contains? ] [ drop invalid-url ] }
        { [ dup first "/\\" member? ] [ drop invalid-url ] }
        { [ CHAR: : over member? ] [ dup absolute-url? [ drop invalid-url ] unless ] }
        [ relative-link-prefix get prepend ]
    } cond ;

: escape-link ( href text -- href-esc text-esc )
    [ check-url ] dip escape-string ;

: write-link ( href text -- )
    escape-link
    [ <a url-encode =href link-no-follow? get [ "true" =nofollow ] when a> ]
    [ write </a> ]
    bi* ;

: write-image-link ( href text -- )
    disable-images? get [
        2drop
        <strong> "Images are not allowed" write </strong>
    ] [
        escape-link
        [ <img url-encode =src ] [ [ =alt ] unless-empty img/> ] bi*
    ] if ;

: render-code ( string mode -- string' )
    [ string-lines ] dip
    [
        <pre>
            htmlize-lines
        </pre>
    ] with-string-writer write ;

GENERIC: (write-farkup) ( farkup -- )
: <foo.> ( string -- ) <foo> write ;
: </foo.> ( string -- ) </foo> write ;
: in-tag. ( obj quot string -- ) [ <foo.> call ] keep </foo.> ; inline
M: heading1 (write-farkup) [ child>> (write-farkup) ] "h1" in-tag. ;
M: heading2 (write-farkup) [ child>> (write-farkup) ] "h2" in-tag. ;
M: heading3 (write-farkup) [ child>> (write-farkup) ] "h3" in-tag. ;
M: heading4 (write-farkup) [ child>> (write-farkup) ] "h4" in-tag. ;
M: strong (write-farkup) [ child>> (write-farkup) ] "strong" in-tag. ;
M: emphasis (write-farkup) [ child>> (write-farkup) ] "em" in-tag. ;
M: superscript (write-farkup) [ child>> (write-farkup) ] "sup" in-tag. ;
M: subscript (write-farkup) [ child>> (write-farkup) ] "sub" in-tag. ;
M: inline-code (write-farkup) [ child>> (write-farkup) ] "code" in-tag. ;
M: list-item (write-farkup) [ child>> (write-farkup) ] "li" in-tag. ;
M: unordered-list (write-farkup) [ child>> (write-farkup) ] "ul" in-tag. ;
M: ordered-list (write-farkup) [ child>> (write-farkup) ] "ol" in-tag. ;
M: paragraph (write-farkup) [ child>> (write-farkup) ] "p" in-tag. ;
M: link (write-farkup) [ href>> ] [ text>> ] bi write-link ;
M: image (write-farkup) [ href>> ] [ text>> ] bi write-image-link ;
M: code (write-farkup) [ string>> ] [ mode>> ] bi render-code ;
M: line (write-farkup) drop <hr/> ;
M: line-break (write-farkup) drop <br/> nl ;
M: table-row (write-farkup) ( obj -- )
    child>> [ [ [ (write-farkup) ] "td" in-tag. ] each ] "tr" in-tag. ;
M: table (write-farkup) [ child>> (write-farkup) ] "table" in-tag. ;
M: string (write-farkup) escape-string write ;
M: vector (write-farkup) [ (write-farkup) ] each ;
M: f (write-farkup) drop ;

: write-farkup ( string -- )
    parse-farkup (write-farkup) ;

: convert-farkup ( string -- string' )
    parse-farkup [ (write-farkup) ] with-string-writer ;
