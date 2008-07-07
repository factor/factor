USING: assocs html.parser html.parser.utils combinators
continuations hashtables
hashtables.private io kernel math
namespaces prettyprint quotations sequences splitting
strings ;
IN: html.parser.printer

SYMBOL: no-section
SYMBOL: html
SYMBOL: head
SYMBOL: body
TUPLE: state section ;

! TUPLE: text bold? underline? strikethrough? ;

TUPLE: text-printer ;
TUPLE: ui-printer ;
TUPLE: src-printer ;
TUPLE: html-prettyprinter ;
UNION: printer text-printer ui-printer src-printer html-prettyprinter ;
HOOK: print-tag printer ( tag -- )
HOOK: print-text-tag printer ( tag -- )
HOOK: print-comment-tag printer ( tag -- )
HOOK: print-dtd-tag printer ( tag -- )
HOOK: print-opening-named-tag printer ( tag -- )
HOOK: print-closing-named-tag printer ( tag -- )

: print-tags ( vector -- )
    [ print-tag ] each ;

: html-text. ( vector -- )
    [
        T{ text-printer } printer set
        print-tags
    ] with-scope ;

: html-src. ( vector -- )
    [
        T{ src-printer } printer set
        print-tags
    ] with-scope ;

M: printer print-text-tag ( tag -- )
    tag-text write ;

M: printer print-comment-tag ( tag -- )
    "<!--" write
    tag-text write
    "-->" write ;

M: printer print-dtd-tag ( tag -- )
    "<!" write
    tag-text write
    ">" write ;

M: printer print-opening-named-tag ( tag -- )
    dup tag-name {
        { "html" [ drop ] }
        { "head" [ drop ] }
        { "body" [ drop ] }
        { "title" [ "Title: " write tag-text print ] }
    } case ;

M: printer print-closing-named-tag ( tag -- )
    drop ;

: print-attributes ( hashtable -- )
    [
        swap bl write "=" write ?quote write
    ] assoc-each ;

M: src-printer print-opening-named-tag ( tag -- )
    "<" write
    [ tag-name write ]
    [ tag-attributes dup assoc-empty? [ drop ] [ print-attributes ] if ] bi
    ">" write ;

M: src-printer print-closing-named-tag ( tag -- )
    "</" write
    tag-name write
    ">" write ;

SYMBOL: tab-width
SYMBOL: #indentations

: html-pp ( vector -- )
    [
        0 #indentations set
        2 tab-width set
        
    ] with-scope ;

: print-tabs ( -- )
    tab-width get #indentations get * CHAR: \s <repetition> write ; 

M: html-prettyprinter print-opening-named-tag ( tag -- )
    print-tabs "<" write
    tag-name write
    ">\n" write ;

M: html-prettyprinter print-closing-named-tag ( tag -- )
    "</" write
    tag-name write
    ">" write ;

ERROR: unknown-tag-error tag ;

M: printer print-tag ( tag -- )
    {
        { [ dup tag-name text = ] [ print-text-tag ] }
        { [ dup tag-name comment = ] [ print-comment-tag ] }
        { [ dup tag-name dtd = ] [ print-dtd-tag ] }
        { [ dup tag-name string? over tag-closing? and ]
            [ print-closing-named-tag ] }
        { [ dup tag-name string? ]
            [ print-opening-named-tag ] }
        [ unknown-tag-error ]
    } cond ;

! SYMBOL: tablestack
! : with-html-printer ( vector quot -- )
    ! [ V{ } clone tablestack set ] with-scope ;

! { { 1 2 } { 3 4 } }
! H{ { table-gap { 10 10 } } } [
    ! [ [ [ [ . ] with-cell ] each ] with-row ] each
! ] tabular-output
