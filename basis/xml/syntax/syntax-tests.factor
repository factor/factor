! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: xml io kernel math sequences strings xml.traversal
tools.test math.parser xml.syntax xml.data xml.syntax.private
accessors multiline inverse xml.writer splitting classes
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

XML-NS: foo https://blah.com

{ T{ name { main "bling" } { url "https://blah.com" } } } [ "bling" foo ] unit-test

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
    [let "one" :> a "two" :> c "y" :> x [XML <-x-> <foo/> XML] :> d
        <XML
            <x> <-a-> <b val=<-c->/> <-d-> </x>
        XML> pprint-xml>string
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
    "one two three" split-words
    [ [XML <item><-></item> XML] ] map
    <XML <doc><-></doc> XML> pprint-xml>string
] unit-test

{ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<x number=\"3\" url=\"https://factorcode.org/\" string=\"hello\" word=\"drop\"/>" }
[ 3 f "https://factorcode.org/" "hello" \ drop
  <XML <x number=<-> false=<-> url=<-> string=<-> word=<->/> XML>
  pprint-xml>string  ] unit-test

{ "<x>3</x>" } [ 3 [XML <x><-></x> XML] xml>string ] unit-test
{ "<x></x>" } [ f [XML <x><-></x> XML] xml>string ] unit-test

[ [XML <-> XML] ] must-infer
[ [XML <foo><-></foo> <bar val=<->/> XML] ] must-infer

{ xml-chunk } [ [ [XML <foo/> XML] ] first class-of ] unit-test
{ xml } [ [ <XML <foo/> XML> ] first class-of ] unit-test
{ xml-chunk } [ [ [XML <foo val=<->/> XML] ] third class-of ] unit-test
{ xml } [ [ <XML <foo val=<->/> XML> ] third class-of ] unit-test
{ 1 } [ [ [XML <foo/> XML] ] length ] unit-test
{ 1 } [ [ <XML <foo/> XML> ] length ] unit-test

{ "" } [ [XML XML] concat ] unit-test

{ "foo" } [ [XML <a>foo</a> XML] [ [XML <a><-></a> XML] ] undo ] unit-test
{ "foo" } [ [XML <a bar='foo'/> XML] [ [XML <a bar=<-> /> XML] ] undo ] unit-test
{ "foo" "baz" } [ [XML <a bar='foo'>baz</a> XML] [ [XML <a bar=<->><-></a> XML] ] undo ] unit-test

: dispatch ( xml -- string )
    {
        { [ [XML <a><-></a> XML] ] [ "a" prepend ] }
        { [ [XML <b><-></b> XML] ] [ "b" prepend ] }
        { [ [XML <b val='yes'/> XML] ] [ "byes" ] }
        { [ [XML <b val=<->/> XML] ] [ "bno" prepend ] }
    } switch ;

{ "apple" } [ [XML <a>pple</a> XML] dispatch ] unit-test
{ "banana" } [ [XML <b>anana</b> XML] dispatch ] unit-test
{ "byes" } [ [XML <b val="yes"/> XML] dispatch ] unit-test
{ "bnowhere" } [ [XML <b val="where"/> XML] dispatch ] unit-test
{ "baboon" } [ [XML <b val="something">aboon</b> XML] dispatch ] unit-test
{ "apple" } [ <XML <a>pple</a> XML> dispatch ] unit-test
{ "apple" } [ <XML <a>pple</a> XML> body>> dispatch ] unit-test

: dispatch-doc ( xml -- string )
    {
        { [ <XML <a><-></a> XML> ] [ "a" prepend ] }
        { [ <XML <b><-></b> XML> ] [ "b" prepend ] }
        { [ <XML <b val='yes'/> XML> ] [ "byes" ] }
        { [ <XML <b val=<->/> XML> ] [ "bno" prepend ] }
    } switch ;

{ "apple" } [ <XML <a>pple</a> XML> dispatch-doc ] unit-test
{ "apple" } [ [XML <a>pple</a> XML] dispatch-doc ] unit-test
{ "apple" } [ <XML <a>pple</a> XML> body>> dispatch-doc ] unit-test

! Make sure nested XML documents interpolate correctly
{
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?><color><blue>it's blue!</blue></color>"
} [
    "it's blue!" <XML <blue><-></blue> XML>
    <XML <color><-></color> XML> xml>string
] unit-test

{
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?><a>asdf<asdf/>asdf2</a>"
} [
    default-prolog
    "asdf"
    "asdf" f f <tag>
    "asdf2" <xml>
    <XML <a><-></a> XML> xml>string
] unit-test
