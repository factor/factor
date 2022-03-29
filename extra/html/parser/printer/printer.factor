USING: accessors assocs combinators html.parser
html.parser.utils io io.streams.string kernel math namespaces
regexp sequences strings unicode ;
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

SYMBOLS: preformatted? script? style? ;

M: text-printer print-opening-tag
    name>> {
        { "br" [ nl indent ] }
        { "ol" [ nl indent ] }
        { "ul" [ nl indent ] }
        { "li" [ " * " write ] }
        { "blockquote" [ #indentations inc indent ] }
        { "pre" [ preformatted? on ] }
        { "script" [ script? on ] }
        { "style" [ style? on ] }
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
        [ { "th" "td" } member? [ bl ] when ]
        [ "pre" = [ preformatted? off ] when ]
        [ "script" = [ script? off ] when ]
        [ "style" = [ style? off ] when ]
    } cleave ;

M: text-printer print-comment-tag drop ;

M: text-printer print-dtd-tag drop ;

: collapse-spaces ( text -- text' )
    preformatted? get [ R/ \s+/ " " re-replace ] unless ;

M: text-printer print-text-tag
    script? get style? get or
    [ drop ] [ text>> collapse-spaces write ] if ;

M: html-printer print-text-tag
    text>> write ;

M: html-printer print-comment-tag
    "<!--" write text>> write "-->" write ;

M: html-printer print-dtd-tag
    "<!" write text>> write ">" write ;

: print-attributes ( hashtable -- )
    [ [ bl write "=" write ] [ ?quote write ] bi* ] assoc-each ;

M: src-printer print-opening-tag
    "<" write
    [ name>> write ] [ attributes>> print-attributes ] bi
    ">" write ;

M: src-printer print-closing-tag
    "</" write name>> write ">" write ;

: prettyprint-html ( vector -- )
    T{ html-prettyprinter } html-printer [ print-tags ] with-variable ;

M: html-prettyprinter print-opening-tag
    name>>
    [ indent "<" write write ">\n" write ]
    ! These tags usually don't have any closing tag associated with them.
    [ { "br" "img" } member? [ #indentations inc ] unless ] bi ;

M: html-prettyprinter print-closing-tag
    ! These tags usually don't have any closing tag associated with them.
    [ { "br" "img" } member? [ #indentations dec ] unless ]
    [ indent "</" write name>> write ">\n" write ] bi ;

M: html-prettyprinter print-text-tag
    text>> [ blank? ] trim [ indent write "\n" write ] unless-empty ;
