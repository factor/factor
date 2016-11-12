USING: accessors assocs combinators fry html.parser
html.parser.utils io io.streams.string kernel math namespaces
sequences strings unicode ;
IN: html.parser.printer

SYMBOL: indentation "  " indentation set-global
SYMBOL: #indentations

: indent ( -- )
    #indentations get indentation get '[ _ write ] times ;

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
        { [ dup name>> string? ]
            [
                dup closing?>>
                [ print-closing-tag ] [ print-opening-tag ] if
            ]
        }
        [ unknown-tag-error ]
    } cond ;

: print-tags ( vector -- )
    0 #indentations [ [ print-tag ] each ] with-variable ;

: html-text. ( vector -- )
    T{ text-printer } html-printer [ print-tags ] with-variable ;

: html-text ( vector -- string )
    [ html-text. ] with-string-writer ;

: html-src. ( vector -- )
    T{ src-printer } html-printer [ print-tags ] with-variable ;

: html-src ( vector -- string )
    [ html-src. ] with-string-writer ;

M: text-printer print-opening-tag
    name>> {
        { "br" [ nl indent ] }
        ! { "ol" [ nl indent ] }
        ! { "ul" [ nl indent ] }
        { "li" [ " * " write ] }
        { "blockquote" [ #indentations inc indent ] }
        [ drop ]
    } case ;

M: text-printer print-closing-tag
    name>> {
        [ "blockquote" = [ #indentations dec ] when ]
        [
            { "p" "blockquote" "h1" "h2" "h3" "h4" "h5" }
            member? [ nl indent nl indent ] when
        ]
        [
            { "ul" "ol" "li" "tr" } member? [ nl indent ] when
        ]
        [ "td" = [ bl ] when ]
    } cleave ;

M: text-printer print-comment-tag drop ;

M: html-printer print-text-tag ( tag -- )
    text>> write ;

M: html-printer print-comment-tag ( tag -- )
    "<!--" write text>> write "-->" write ;

M: html-printer print-dtd-tag ( tag -- )
    "<!" write text>> write ">" write ;

: print-attributes ( hashtable -- )
    [ [ bl write "=" write ] [ ?quote write ] bi* ] assoc-each ;

M: src-printer print-opening-tag ( tag -- )
    "<" write
    [ name>> write ] [ attributes>> print-attributes ] bi
    ">" write ;

M: src-printer print-closing-tag ( tag -- )
    "</" write name>> write ">" write ;

: prettyprint-html ( vector -- )
    T{ html-prettyprinter } html-printer [ print-tags ] with-variable ;

M: html-prettyprinter print-opening-tag ( tag -- )
    name>>
    [ indent "<" write write ">\n" write ]
    ! These tags usually don't have any closing tag associated with them.
    [ { "br" "img" } member? [ #indentations inc ] unless ] bi ;

M: html-prettyprinter print-closing-tag ( tag -- )
    ! These tags usually don't have any closing tag associated with them.
    [ { "br" "img" } member? [ #indentations dec ] unless ]
    [ indent "</" write name>> write ">\n" write ] bi ;

M: html-prettyprinter print-text-tag ( tag -- )
    text>> [ blank? ] trim [ indent write "\n" write ] unless-empty ;
