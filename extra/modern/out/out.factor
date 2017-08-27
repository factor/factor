! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs io io.encodings.utf8 io.files
io.streams.string kernel modern modern.paths modern.slices
multiline namespaces prettyprint sequences sequences.extras
splitting strings ;
IN: modern.out

SYMBOL: last-slice

: write-whitespace ( obj -- )
    [ last-slice get [ swap slice-between ] [ slice-before ] if* >string io:write ]
    [ last-slice namespaces:set ] bi ;

GENERIC: write-literal ( obj -- )
M: string write-literal write ;
M: slice write-literal [ write-whitespace ] [ >string write ] bi ;
M: array write-literal [ write-literal ] each ;


: write-modern-loop ( quot -- )
    [ write-literal ] each ; inline

: write-modern-string ( seq -- string )
    [ write-modern-loop ] with-string-writer ; inline

: write-modern-path ( seq path -- )
    utf8 [ write-modern-loop nl ] with-file-writer ; inline

![[
: rewrite-path ( path quot -- )
    ! dup print
    '[ [ path>literals [ _ map-literals ] map ] [ ] bi write-modern-path ]
    [ drop . ] recover ; inline

: rewrite-string ( string quot -- )
    ! dup print
    [ string>literals ] dip '[ _ map-literals ] map write-modern-string ; inline

: rewrite-paths ( seq quot -- ) '[ _ rewrite-path ] each ; inline
]]
: rewrite-path-exact ( path -- )
    [ path>literals ] [ ] bi write-modern-path ;

: rewrite-vocab-exact ( name -- )
    modern-source-path rewrite-path-exact ;

: rewrite-paths ( paths -- )
    [ rewrite-path-exact ] each ;

: strings-core-to-file ( -- )
    core-bootstrap-vocabs
    [ ".private" ?tail drop modern-source-path utf8 file-contents ] map-zip
    [ "[========[" dup matching-delimiter-string surround ] assoc-map
    [
        first2 [ "VOCAB: " prepend ] dip " " glue
    ] map
    [ "    " prepend ] map "\n\n" join
    "<VOCAB-ROOT: factorcode-core \"https://factorcode.org/git/factor.git\" \"core/\"\n"
    "\n;VOCAB-ROOT>" surround "resource:core-strings.factor" utf8 set-file-contents ;

: parsed-core-to-file ( -- )
    core-bootstrap-vocabs
    [ vocab>literals ] map-zip
    [
        first2 [ "<VOCAB: " prepend ] dip
        >strings
        ! [ 3 head ] [ 3 tail* ] bi [ >strings ] bi@ { "..." } glue
        ";VOCAB>" 3array
    ] map 1array

    { "<VOCAB-ROOT:" "factorcode-core" "https://factorcode.org/git/factor.git" "core/" }
    { ";VOCAB-ROOT>" } surround "resource:core-parsed.factor" utf8 [ ... ] with-file-writer ;