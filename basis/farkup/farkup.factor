! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators io.streams.string
kernel lists math math.order namespaces sequences splitting
strings urls urls.encoding xml.data xml.syntax xml.writer
xmode.code2html ;
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
    >url protocol>> >boolean ;

: simple-link-title ( string -- string' )
    dup absolute-url? [ "/" split1-last swap or ] unless ;

! _foo*bar_baz*bing works like <i>foo*bar</i>baz<b>bing</b>
! I could support overlapping, but there's not a good use case for it.

DEFER: (parse-paragraph)

: parse-paragraph ( string -- seq )
    (parse-paragraph) list>array ;

: make-paragraph ( string -- paragraph )
    parse-paragraph paragraph boa ;

: cut-half-slice ( string i -- before after-slice )
    [ head ] [ 1 + index-or-length tail-slice ] 2bi ;

: find-cut ( string quot -- before after delimiter )
    dupd find
    [ [ cut-half-slice ] [ f ] if* ] dip ; inline

: parse-delimiter ( string delimiter class -- paragraph )
    [ '[ _ = ] find-cut drop ] dip
    '[ parse-paragraph _ new swap >>child ]
    [ (parse-paragraph) ] bi* cons ;

: delimiter-class ( delimiter -- class )
    H{
        { CHAR: * strong }
        { CHAR: _ emphasis }
        { CHAR: ^ superscript }
        { CHAR: ~ subscript }
        { CHAR: % inline-code }
    } at ;

: or-simple-title ( ... url title/f quot: ( ... title -- ... title' ) -- ... url title' )
    [ "" like dup simple-link-title ] if* ; inline

: parse-link ( string -- paragraph-list )
    rest-slice "]]" split1-slice [
        "|" split1
        [ "image:" ?head ] dip swap
        [ [ ] or-simple-title image boa ]
        [ [ parse-paragraph ] or-simple-title link boa ] if
    ] dip [ (parse-paragraph) cons ] [ 1list ] if* ;

: parse-big-link ( before after -- link rest )
    dup ?first CHAR: [ =
    [ parse-link ]
    [ [ CHAR: [ suffix ] [ (parse-paragraph) ] bi* ]
    if ;

: escape ( before after -- before' after' )
    [ nil ] [ unclip-slice swap [ suffix ] dip (parse-paragraph) ] if-empty ;

: (parse-paragraph) ( string -- list )
    [ nil ] [
        [ "*_^~%[\\" member? ] find-cut [
            {
                { CHAR: [ [ parse-big-link ] }
                { CHAR: \\ [ escape ] }
                [ dup delimiter-class parse-delimiter ]
            } case cons
        ] [ drop "" like 1list ] if*
    ] if-empty ;

: look ( state i -- char ) swap first ?nth ;

: take-lines ( state char -- state' lines )
    dupd '[ ?first _ = not ] find drop
    [ cut-slice ] [ f ] if* swap ;

:: (take-until) ( state delimiter accum -- string/f state' )
    state empty? [ accum join-lines f ] [
        state unclip-slice :> ( rest first )
        first delimiter split1 :> ( before after )
        before accum push
        after [
            accum join-lines
            rest after prefix
        ] [
            rest delimiter accum (take-until)
        ] if
    ] if ;

: take-until ( state delimiter -- string state'/f )
    V{ } clone (take-until) ;

: count= ( string -- n )
    dup <reversed> [ [ CHAR: = = not ] find drop 0 or ] bi@ min ;

: trim= ( string -- string' )
    [ CHAR: = = ] trim ;

: make-heading ( string class -- heading )
    [ trim= parse-paragraph ] dip boa ; inline

: parse-heading ( state -- state' heading )
    unclip-slice dup count= {
        { 0 [ make-paragraph ] }
        { 1 [ heading1 make-heading ] }
        { 2 [ heading2 make-heading ] }
        { 3 [ heading3 make-heading ] }
        { 4 [ heading4 make-heading ] }
        [ drop heading4 make-heading ]
    } case ;

: trim-row ( seq -- seq' )
    rest
    dup last empty? [ but-last ] when ;

: coalesce ( rows -- rows' )
    V{ } clone [
        '[
            _ dup ?last ?last CHAR: \\ =
            [ [ pop "|" rot 3append ] keep ] when
            push
        ] each
    ] keep ;

: parse-table ( state -- state' table )
    CHAR: | take-lines [
        "|" split
        trim-row
        coalesce
        [ parse-paragraph ] map
        table-row boa
    ] map table boa ;

: parse-line ( state -- state' item )
    unclip-slice dup "___" =
    [ drop line new ] [ make-paragraph ] if ;

: parse-list ( state char class -- state' list )
    [
        take-lines
        [ rest parse-paragraph list-item boa ] map
    ] dip boa ; inline

: parse-ul ( state -- state' ul )
    CHAR: - unordered-list parse-list ;

: parse-ol ( state -- state' ul )
    CHAR: # ordered-list parse-list ;

: parse-code ( state -- state' item )
    dup 1 look CHAR: [ =
    [ unclip-slice make-paragraph ] [
        dup "{" take-until [
            [ nip rest ] dip
            "}]" take-until
            [ code boa ] dip swap
        ] [ drop unclip-slice make-paragraph ] if*
    ] if ;

: parse-item ( state -- state' item )
    dup 0 look {
        { CHAR: = [ parse-heading ] }
        { CHAR: | [ parse-table ] }
        { CHAR: _ [ parse-line ] }
        { CHAR: - [ parse-ul ] }
        { CHAR: # [ parse-ol ] }
        { CHAR: [ [ parse-code ] }
        { f [ rest-slice f ] }
        [ drop unclip-slice make-paragraph ]
    } case ;

: parse-farkup ( string -- farkup )
    split-lines [ dup empty? not ] [ parse-item ] produce nip sift ;

CONSTANT: invalid-url "javascript:alert('Invalid URL in farkup');"

: check-url ( href -- href' absolute? )
    {
        { [ dup empty? ] [ drop invalid-url f ] }
        { [ dup [ 127 > ] any? ] [ drop invalid-url f ] }
        { [ dup first "/\\" member? ] [ drop invalid-url f ] }
        { [ CHAR: : over member? ] [ dup absolute-url? [ t ] [ drop invalid-url f ] if ] }
        [ relative-link-prefix get prepend "" like url-encode f ]
    } cond ;

: render-code ( string mode -- xml )
    [ split-lines ] dip htmlize-lines
    [XML <pre><-></pre> XML] ;

GENERIC: (write-farkup) ( farkup -- xml )

: farkup-inside ( farkup name -- xml )
    <simple-name> swap T{ attrs } clone swap
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

: write-link ( href text -- xml )
    [ check-url link-no-follow? get "nofollow" and and ] dip
    [XML <a href=<-> rel=<->><-></a> XML] ;

: write-image-link ( href text -- xml )
    disable-images? get [
        2drop
        [XML <strong>Images are not allowed</strong> XML]
    ] [
        [ check-url drop ] [ f like ] bi*
        [XML <img src=<-> alt=<->/> XML]
    ] if ;

: open-link ( link -- href text )
    [ href>> ] [ text>> (write-farkup) ] bi ;

M: link (write-farkup)
    open-link write-link ;

M: image (write-farkup)
    open-link write-image-link ;

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

M: array (write-farkup) [ (write-farkup) ] map ;

: farkup>xml ( string -- xml )
    parse-farkup (write-farkup) ;

: write-farkup ( string -- )
    farkup>xml write-xml ;

: convert-farkup ( string -- string' )
    [ write-farkup ] with-string-writer ;
