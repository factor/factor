! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators html.elements io
io.streams.string kernel math namespaces peg peg.ebnf
sequences sequences.deep strings xml.entities xml.literals
vectors splitting xmode.code2html urls.encoding xml.data
xml.writer ;
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
    { "http://" "https://" "ftp://" } [ head? ] with any? ;

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
                    => [[ >string ]]

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
    => [[ second >string f swap code boa ]]

code = named-code | simple-code


stand-alone
           = (line | code | heading | list | table | paragraph | nl)*
;EBNF

: invalid-url "javascript:alert('Invalid URL in farkup');" ;

: check-url ( href -- href' )
    {
        { [ dup empty? ] [ drop invalid-url ] }
        { [ dup [ 127 > ] any? ] [ drop invalid-url ] }
        { [ dup first "/\\" member? ] [ drop invalid-url ] }
        { [ CHAR: : over member? ] [ dup absolute-url? [ drop invalid-url ] unless ] }
        [ relative-link-prefix get prepend "" like ]
    } cond url-encode ;

: write-link ( href text -- xml )
    [ check-url link-no-follow? get "true" and ] dip
    [XML <a href=<-> nofollow=<->><-></a> XML] ;

: write-image-link ( href text -- xml )
    disable-images? get [
        2drop
        [XML <strong>Images are not allowed</strong> XML]
    ] [
        [ check-url ] [ f like ] bi*
        [XML <img src=<-> alt=<->/> XML]
    ] if ;

: render-code ( string mode -- xml )
    [ string-lines ] dip htmlize-lines
    [XML <pre><-></pre> XML] ;

GENERIC: (write-farkup) ( farkup -- xml )

: farkup-inside ( farkup name -- xml )
    <simple-name> swap T{ attrs } swap
    child>> (write-farkup) 1array <tag> ;

M: heading1 (write-farkup) "h1" farkup-inside ;
M: heading2 (write-farkup) "h2" farkup-inside ;
M: heading3 (write-farkup) "h3" farkup-inside ;
M: heading4 (write-farkup) "h4" farkup-inside ;
M: strong (write-farkup) "strong" farkup-inside ;
M: emphasis (write-farkup) "em" farkup-inside ;
M: superscript (write-farkup) "sup" farkup-inside ;
M: subscript (write-farkup) "sub" farkup-inside ;
M: inline-code (write-farkup) "code" farkup-inside ;
M: list-item (write-farkup) "li" farkup-inside ;
M: unordered-list (write-farkup) "ul" farkup-inside ;
M: ordered-list (write-farkup) "ol" farkup-inside ;
M: paragraph (write-farkup) "p" farkup-inside ;
M: table (write-farkup) "table" farkup-inside ;

M: link (write-farkup)
    [ href>> ] [ text>> ] bi write-link ;

M: image (write-farkup)
    [ href>> ] [ text>> ] bi write-image-link ;

M: code (write-farkup)
    [ string>> ] [ mode>> ] bi render-code ;

M: line (write-farkup)
    drop [XML <hr/> XML] ;

M: line-break (write-farkup)
    drop [XML <br/> XML] ;

M: table-row (write-farkup)
    child>>
    [ (write-farkup) [XML <td><-></td> XML] ] map
    [XML <tr><-></tr> XML] ;

M: string (write-farkup) ;

M: vector (write-farkup) [ (write-farkup) ] map ;

M: f (write-farkup) ;

: farkup>xml ( string -- xml )
    parse-farkup (write-farkup) ;

: write-farkup ( string -- )
    farkup>xml write-xml ;

: convert-farkup ( string -- string' )
    [ write-farkup ] with-string-writer ;
