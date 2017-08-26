! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml io kernel math sequences strings xml.traversal
tools.test math.parser xml.syntax xml.data xml.syntax.private
accessors multiline locals inverse xml.writer splitting classes
xml.private ;
IN: xml.syntax.tests

! TAGS test

TAGS: calculate ( tag -- n )

: calc-2children ( tag -- n n )
    children-tags first2 [ calculate ] dip calculate ;

TAG: number calculate
    children>string string>number ;
TAG: add calculate
    calc-2children + ;
TAG: minus calculate
    calc-2children - ;
TAG: times calculate
    calc-2children * ;
TAG: divide calculate
    calc-2children / ;
TAG: neg calculate
    children-tags first calculate neg ;

: calc-arith ( string -- n )
    string>xml first-child-tag calculate ;

{ 32 } [
    "<math><times><add><number>1</number><number>3</number></add><neg><number>-8</number></neg></times></math>"
    calc-arith
] unit-test

XML-NS: foo http://blah.com

{ T{ name { main "bling" } { url "http://blah.com" } } } [ "bling" foo ] unit-test

! XML literals

{ "a" "c" { "a" "c" f } } [
    "<?xml version='1.0'?><x><-a-><b val=<-c->/><-></x>"
    string>doc
    [ second var>> ]
    [ fourth "val" attr var>> ]
    [ extract-variables ] tri
] unit-test

{ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<x>
  one
  <b val=\"two\"/>
  y
  <foo/>
</x>" } [
    let[ "one" :> a "two" :> c "y" :> x XML-CHUNK[[ <-x-> <foo/> ]] :> d
        XML-DOC[[
            <x> <-a-> <b val=<-c->/> <-d-> </x>
        ]] pprint-xml>string
    ]
] unit-test

{ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
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
</doc>" } [
    "one two three" " " split
    [ XML-CHUNK[[ <item><-></item> ]] ] map
    XML-DOC[[ <doc><-></doc> ]] pprint-xml>string
] unit-test

{ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<x number=\"3\" url=\"http://factorcode.org/\" string=\"hello\" word=\"drop\"/>" }
[ 3 f "http://factorcode.org/" "hello" \ drop
  XML-DOC[[ <x number=<-> false=<-> url=<-> string=<-> word=<->/> ]]
  pprint-xml>string  ] unit-test

{ "<x>3</x>" } [ 3 XML-CHUNK[[ <x><-></x> ]] xml>string ] unit-test
{ "<x></x>" } [ f XML-CHUNK[[ <x><-></x> ]] xml>string ] unit-test

[ XML-CHUNK[[ <-> ]] ] must-infer
[ XML-CHUNK[[ <foo><-></foo> <bar val=<->/> ]] ] must-infer

{ xml-chunk } [ [ XML-CHUNK[[ <foo/> ]] ] first class-of ] unit-test
{ xml } [ [ XML-DOC[[ <foo/> ]] ] first class-of ] unit-test
{ xml-chunk } [ [ XML-CHUNK[[ <foo val=<->/> ]] ] third class-of ] unit-test
{ xml } [ [ XML-DOC[[ <foo val=<->/> ]] ] third class-of ] unit-test
{ 1 } [ [ XML-CHUNK[[ <foo/> ]] ] length ] unit-test
{ 1 } [ [ XML-DOC[[ <foo/> ]] ] length ] unit-test

{ "" } [ XML-CHUNK[[ ]] concat ] unit-test

{ "foo" } [ XML-CHUNK[[ <a>foo</a> ]] [ XML-CHUNK[[ <a><-></a> ]] ] undo ] unit-test
{ "foo" } [ XML-CHUNK[[ <a bar='foo'/> ]] [ XML-CHUNK[[ <a bar=<-> /> ]] ] undo ] unit-test
{ "foo" "baz" } [ XML-CHUNK[[ <a bar='foo'>baz</a> ]] [ XML-CHUNK[[ <a bar=<->><-></a> ]] ] undo ] unit-test

: dispatch ( xml -- string )
    {
        { [ XML-CHUNK[[ <a><-></a> ]] ] [ "a" prepend ] }
        { [ XML-CHUNK[[ <b><-></b> ]] ] [ "b" prepend ] }
        { [ XML-CHUNK[[ <b val='yes'/> ]] ] [ "byes" ] }
        { [ XML-CHUNK[[ <b val=<->/> ]] ] [ "bno" prepend ] }
    } switch ;

{ "apple" } [ XML-CHUNK[[ <a>pple</a> ]] dispatch ] unit-test
{ "banana" } [ XML-CHUNK[[ <b>anana</b> ]] dispatch ] unit-test
{ "byes" } [ XML-CHUNK[[ <b val="yes"/> ]] dispatch ] unit-test
{ "bnowhere" } [ XML-CHUNK[[ <b val="where"/> ]] dispatch ] unit-test
{ "baboon" } [ XML-CHUNK[[ <b val="something">aboon</b> ]] dispatch ] unit-test
{ "apple" } [ XML-DOC[[ <a>pple</a> ]] dispatch ] unit-test
{ "apple" } [ XML-DOC[[ <a>pple</a> ]] body>> dispatch ] unit-test

: dispatch-doc ( xml -- string )
    {
        { [ XML-DOC[[ <a><-></a> ]] ] [ "a" prepend ] }
        { [ XML-DOC[[ <b><-></b> ]] ] [ "b" prepend ] }
        { [ XML-DOC[[ <b val='yes'/> ]] ] [ "byes" ] }
        { [ XML-DOC[[ <b val=<->/> ]] ] [ "bno" prepend ] }
    } switch ;

{ "apple" } [ XML-DOC[[ <a>pple</a> ]] dispatch-doc ] unit-test
{ "apple" } [ XML-CHUNK[[ <a>pple</a> ]] dispatch-doc ] unit-test
{ "apple" } [ XML-DOC[[ <a>pple</a> ]] body>> dispatch-doc ] unit-test

! Make sure nested XML documents interpolate correctly
{
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?><color><blue>it's blue!</blue></color>"
} [
    "it's blue!" XML-DOC[[ <blue><-></blue> ]]
    XML-DOC[[ <color><-></color> ]] xml>string
] unit-test

{
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?><a>asdf<asdf/>asdf2</a>"
} [
    default-prolog
    "asdf"
    "asdf" f f <tag>
    "asdf2" <xml>
    XML-DOC[[ <a><-></a> ]] xml>string
] unit-test
