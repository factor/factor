USING: kernel tools.test regexp.parser fry sequences ;
IN: regexp.parser.tests

: regexp-parses ( string -- )
    [ [ ] ] dip '[ _ parse-regexp drop ] unit-test ;

: regexp-fails ( string -- )
    '[ _ parse-regexp ] must-fail ;

{
    "a|b" "a.b" "a|b|c" "abc|b" "a|bcd" "a|(b)" "(?-i:a)" "||"
    "(a)|b" "(a|b)" "((a)|(b))" "(?:a)" "(?i:a)" "|b" "b|"
    "[abc]" "[a-c]" "[^a-c]" "[^]]" "[]a]" "[[]" "[]-a]" "[a-]" "[-]"
    "foo*" "(foo)*" "(a|b)|c" "(foo){2,3}" "(foo){2,}"
    "(foo){2}" "{2,3}" "{," "{,}" "}" "foo}" "[^]-a]" "[^-]a]"
    "[a-]" "[^a-]" "[^a-]" "a{,2}" "(?#foobar)"
    "\\p{Space}" "\\t" "\\[" "[\\]]" "\\P{Space}"
    "\\ueeee" "\\0333" "\\xff" "\\\\" "\\w"
} [ regexp-parses ] each

{
    "[^]" "[]" "a{foo}" "a{,}" "a{}" "(?)" "\\p{foo}" "\\P{foo}"
    "\\ueeeg" "\\0339" "\\xfg"
} [ regexp-fails ] each
