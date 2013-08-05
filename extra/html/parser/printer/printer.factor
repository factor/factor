USING: accessors assocs html.parser html.parser.utils combinators
continuations hashtables
hashtables.private io kernel make math
namespaces prettyprint quotations sequences sequences.repeating splitting
strings unicode.categories ;
IN: html.parser.printer

TUPLE: html-printer ;
TUPLE: text-printer < html-printer ;
TUPLE: src-printer < html-printer ;
TUPLE: html-prettyprinter < html-printer ;

HOOK: print-text-tag html-printer ( tag -- )
HOOK: print-comment-tag html-printer ( tag -- )
HOOK: print-dtd-tag html-printer ( tag -- )
HOOK: print-opening-tag html-printer ( tag -- )
HOOK: print-closing-tag html-printer ( tag -- )

ERROR: unknown-tag-error tag ;

: print-tag ( tag -- )
    {
        { [ dup name>> text = ] [ print-text-tag ] }
        { [ dup name>> comment = ] [ print-comment-tag ] }
        { [ dup name>> dtd = ] [ print-dtd-tag ] }
        { [ dup [ name>> string? ] [ closing?>> ] bi and ]
            [ print-closing-tag ] }
        { [ dup name>> string? ]
            [ print-opening-tag ] }
        [ unknown-tag-error ]
    } cond ;

: print-tags ( vector -- ) [ print-tag ] each ;

: html-text. ( vector -- )
    T{ text-printer } html-printer [ print-tags ] with-variable ;

: html-src. ( vector -- )
    T{ src-printer } html-printer [ print-tags ] with-variable ;

M: html-printer print-text-tag ( tag -- ) text>> write ;

M: html-printer print-comment-tag ( tag -- )
    "<!--" write text>> write "-->" write ;

M: html-printer print-dtd-tag ( tag -- )
    "<!" write text>> write ">" write ;

: print-attributes ( hashtable -- )
    [ [ bl write "=" write ] [ ?quote write ] bi* ] assoc-each ;

M: src-printer print-opening-tag ( tag -- )
    "<" write
    [ name>> write ]
    [ attributes>> dup assoc-empty? [ drop ] [ print-attributes ] if ] bi
    ">" write ;

M: src-printer print-closing-tag ( tag -- )
    "</" write
    name>> write
    ">" write ;

SYMBOL: tab-width
SYMBOL: #indentations
SYMBOL: tagstack

: prettyprint-html ( vector -- )
    [
        T{ html-prettyprinter } html-printer set
        V{ } clone tagstack set
        2 tab-width set
        0 #indentations set
        print-tags
    ] with-scope ;

: tabs ( -- str )
    " " tab-width get #indentations get * repeat ;

M: html-prettyprinter print-opening-tag ( tag -- )
    name>>
    [ tabs "<" append ">\n" surround write ]
    ! These tags usually don't have any closing tag associated with them.
    [ { "br" "img" } member? [ #indentations inc ] unless ] bi ;

M: html-prettyprinter print-closing-tag ( tag -- )
    #indentations dec name>> tabs "</" append ">\n" surround write ;

M: html-prettyprinter print-text-tag ( tag -- )
    text>> [ blank? ] trim [ tabs "\n" surround write ] unless-empty ;
