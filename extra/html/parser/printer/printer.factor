USING: assocs html.parser html.parser.utils combinators
continuations hashtables
hashtables.private io kernel math
namespaces prettyprint quotations sequences splitting
state-parser strings ;
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
UNION: printer text-printer ui-printer src-printer ;
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

M: printer print-dtd-tag
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
    dup tag-name write
    tag-attributes dup assoc-empty? [ drop ] [ print-attributes ] if
    ">" write ;

M: src-printer print-closing-named-tag ( tag -- )
    "</" write
    tag-name write
    ">" write ;

TUPLE: unknown-tag-error tag ;

C: <unknown-tag-error> unknown-tag-error

M: printer print-tag ( tag -- )
    {
        { [ dup tag-name text = ] [ print-text-tag ] }
        { [ dup tag-name comment = ] [ print-comment-tag ] }
        { [ dup tag-name dtd = ] [ print-dtd-tag ] }
        { [ dup tag-name string? over tag-closing? and ]
            [ print-closing-named-tag ] }
        { [ dup tag-name string? ]
            [ print-opening-named-tag ] }
        { [ t ] [ <unknown-tag-error> throw ] }
    } cond ;

SYMBOL: tablestack

: with-html-printer
    [
        V{ } clone tablestack set
    ] with-scope ;

! { { 1 2 } { 3 4 } }
! H{ { table-gap { 10 10 } } } [
    ! [ [ [ [ . ] with-cell ] each ] with-row ] each
! ] tabular-output
