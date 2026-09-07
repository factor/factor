USING: accessors kernel tools.test regexp.parser fry sequences ;
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

! Capturing parentheses must survive parsing; noncapturing ones do not.
{ f } [ "(a)" parse-regexp "a" parse-regexp = ] unit-test
{ t } [ "(?:a)" parse-regexp "a" parse-regexp = ] unit-test
{ } [ "(?<name>a)" parse-regexp drop ] unit-test

{ "_name2" } [ "(?<_name2>a)" parse-regexp name>> ] unit-test
[ "(?<>a)" parse-regexp ] must-fail
[ "(?<2name>a)" parse-regexp ] must-fail
[ "(?<a-b>a)" parse-regexp ] must-fail
