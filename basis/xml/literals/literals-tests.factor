! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test xml.literals multiline kernel assocs
sequences accessors xml.writer xml.literals.private
locals splitting urls xml.data classes ;
IN: xml.literals.tests

[ "a" "c" { "a" "c" f } ] [
    "<?xml version='1.0'?><x><-a-><b val=<-c->/><-></x>"
    string>doc
    [ second var>> ]
    [ fourth "val" attr var>> ]
    [ extract-variables ] tri
] unit-test

[ {" <?xml version="1.0" encoding="UTF-8"?>
<x>
  one
  <b val="two"/>
  y
  <foo/>
</x>"} ] [
    [let* | a [ "one" ] c [ "two" ] x [ "y" ]
           d [ [XML <-x-> <foo/> XML] ] |
        <XML
            <x> <-a-> <b val=<-c->/> <-d-> </x>
        XML> pprint-xml>string
    ]
] unit-test

[ {" <?xml version="1.0" encoding="UTF-8"?>
<doc>
  <item>
    one
  </item>
  <item>
    two
  </item>
  <item>
    three
  </item>
</doc>"} ] [
    "one two three" " " split
    [ [XML <item><-></item> XML] ] map
    <XML <doc><-></doc> XML> pprint-xml>string
] unit-test

[ {" <?xml version="1.0" encoding="UTF-8"?>
<x number="3" url="http://factorcode.org/" string="hello" word="drop"/>"} ]
[ 3 f URL" http://factorcode.org/" "hello" \ drop
  <XML <x number=<-> false=<-> url=<-> string=<-> word=<->/> XML>
  pprint-xml>string  ] unit-test

[ "<x>3</x>" ] [ 3 [XML <x><-></x> XML] xml>string ] unit-test
[ "<x></x>" ] [ f [XML <x><-></x> XML] xml>string ] unit-test

\ <XML must-infer
[ [XML <-> XML] ] must-infer
[ [XML <foo><-></foo> <bar val=<->/> XML] ] must-infer

[ xml-chunk ] [ [ [XML <foo/> XML] ] first class ] unit-test
[ xml ] [ [ <XML <foo/> XML> ] first class ] unit-test
[ xml-chunk ] [ [ [XML <foo val=<->/> XML] ] third class ] unit-test
[ xml ] [ [ <XML <foo val=<->/> XML> ] third class ] unit-test
[ 1 ] [ [ [XML <foo/> XML] ] length ] unit-test
[ 1 ] [ [ <XML <foo/> XML> ] length ] unit-test

[ "" ] [ [XML XML] concat ] unit-test
