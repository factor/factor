! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: farkup kernel peg peg.ebnf tools.test namespaces xml
urls.encoding assocs xml.traversal xml.data sequences random
io continuations math ;
IN: farkup.tests

relative-link-prefix off
disable-images? off
link-no-follow? off

[ "Baz" ] [ "Foo/Bar/Baz" simple-link-title ] unit-test
[ "Baz" ] [ "Baz" simple-link-title ] unit-test

[ ] [
    "abcd-*strong*\nasdifj\nweouh23ouh23" parse-farkup drop
] unit-test

[ ] [
    "abcd-*strong*\nasdifj\nweouh23ouh23\n" parse-farkup drop
] unit-test

[ "<p>a-b</p>" ] [ "a-b" convert-farkup ] unit-test
[ "<p><strong>foo</strong></p><p>bar</p>" ] [ "*foo\nbar\n" convert-farkup ] unit-test
[ "<p><strong>Wow!</strong></p>" ] [ "*Wow!*" convert-farkup ] unit-test
[ "<p><em>Wow.</em></p>" ] [ "_Wow._" convert-farkup ] unit-test

[ "<p><strong></strong></p>" ] [ "*" convert-farkup ] unit-test
[ "<p>*</p>" ] [ "\\*" convert-farkup ] unit-test
[ "<p>*<strong></strong></p>" ] [ "\\**" convert-farkup ] unit-test

[ "<ul><li>a-b</li></ul>" ] [ "-a-b" convert-farkup ] unit-test
[ "<ul><li>foo</li></ul>" ] [ "-foo" convert-farkup ] unit-test
[ "<ul><li>foo</li></ul>" ] [ "-foo\n" convert-farkup ] unit-test
[ "<ul><li>foo</li><li>bar</li></ul>" ] [ "-foo\n-bar" convert-farkup ] unit-test
[ "<ul><li>foo</li><li>bar</li></ul>" ] [ "-foo\n-bar\n" convert-farkup ] unit-test

[ "<ul><li>foo</li></ul><p>bar</p>" ] [ "-foo\nbar\n" convert-farkup ] unit-test

[ "<ol><li>a-b</li></ol>" ] [ "#a-b" convert-farkup ] unit-test
[ "<ol><li>foo</li></ol>" ] [ "#foo" convert-farkup ] unit-test
[ "<ol><li>foo</li></ol>" ] [ "#foo\n" convert-farkup ] unit-test
[ "<ol><li>foo</li><li>bar</li></ol>" ] [ "#foo\n#bar" convert-farkup ] unit-test
[ "<ol><li>foo</li><li>bar</li></ol>" ] [ "#foo\n#bar\n" convert-farkup ] unit-test

[ "<ol><li>foo</li></ol><p>bar</p>" ] [ "#foo\nbar\n" convert-farkup ] unit-test


[ "" ] [ "\n\n" convert-farkup ] unit-test
[ "" ] [ "\r\n\r\n" convert-farkup ] unit-test
[ "" ] [ "\r\r\r\r" convert-farkup ] unit-test
[ "" ] [ "\r\r\r" convert-farkup ] unit-test
[ "" ] [ "\n\n\n" convert-farkup ] unit-test
[ "<p>foo</p><p>bar</p>" ] [ "foo\n\nbar" convert-farkup ] unit-test
[ "<p>foo</p><p>bar</p>" ] [ "foo\r\n\r\nbar" convert-farkup ] unit-test
[ "<p>foo</p><p>bar</p>" ] [ "foo\r\rbar" convert-farkup ] unit-test
[ "<p>foo</p><p>bar</p>" ] [ "foo\r\r\nbar" convert-farkup ] unit-test

[ "<p>bar</p>" ] [ "\nbar\n" convert-farkup ] unit-test
[ "<p>bar</p>" ] [ "\rbar\r" convert-farkup ] unit-test
[ "<p>bar</p>" ] [ "\r\nbar\r\n" convert-farkup ] unit-test

[ "<p>foo</p><p>bar</p>" ] [ "foo\n\n\nbar" convert-farkup ] unit-test

[ "" ] [ "" convert-farkup ] unit-test

[ "<table><tr><td>a</td></tr></table>" ]
[ "|a" convert-farkup ] unit-test

[ "<table><tr><td>a</td></tr></table>" ]
[ "|a|" convert-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr></table>" ]
[ "|a|b|" convert-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>d</td></tr></table>" ]
[ "|a|b|\n|c|d|" convert-farkup ] unit-test

[ "<table><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>d</td></tr></table>" ]
[ "|a|b|\n|c|d|\n" convert-farkup ] unit-test

[ "<p><strong>foo</strong></p><h1>aheading</h1><p>adfasd</p>" ]
[ "*foo*\n=aheading=\nadfasd" convert-farkup ] unit-test

[ "<h1>foo</h1>" ] [ "=foo=\n" convert-farkup ] unit-test
[ "<p>lol=foo=</p>" ] [ "lol=foo=\n" convert-farkup ] unit-test
[ "<p>=foo</p>" ] [ "=foo\n" convert-farkup ] unit-test
[ "<p>=foo</p>" ] [ "=foo" convert-farkup ] unit-test
[ "<p>==foo</p>" ] [ "==foo" convert-farkup ] unit-test
[ "<h1>foo</h1>" ] [ "==foo=" convert-farkup ] unit-test
[ "<h2>foo</h2>" ] [ "==foo==" convert-farkup ] unit-test
[ "<h2>foo</h2>" ] [ "==foo==" convert-farkup ] unit-test
[ "<h2>foo</h2>" ] [ "===foo==" convert-farkup ] unit-test
[ "<h1>foo</h1>" ] [ "=foo==" convert-farkup ] unit-test

[ "<pre><span class=\"KEYWORD3\">int</span> <span class=\"FUNCTION\">main</span><span class=\"OPERATOR\">(</span><span class=\"OPERATOR\">)</span></pre>" ]
[ "[c{int main()}]" convert-farkup ] unit-test

[ "<p><img src=\"lol.jpg\" alt=\"image:lol.jpg\"/></p>" ] [ "[[image:lol.jpg]]" convert-farkup ] unit-test
[ "<p><img src=\"lol.jpg\" alt=\"teh lol\"/></p>" ] [ "[[image:lol.jpg|teh lol]]" convert-farkup ] unit-test
[ "<p><a href=\"http://lol.com\">http://lol.com</a></p>" ] [ "[[http://lol.com]]" convert-farkup ] unit-test
[ "<p><a href=\"http://lol.com\">haha</a></p>" ] [ "[[http://lol.com|haha]]" convert-farkup ] unit-test
[ "<p><a href=\"http://lol.com/search?q=sex\">haha</a></p>" ] [ "[[http://lol.com/search?q=sex|haha]]" convert-farkup ] unit-test
[ "<p><a href=\"Foo/Bar\">Bar</a></p>" ] [ "[[Foo/Bar]]" convert-farkup ] unit-test

"/wiki/view/" relative-link-prefix [
    [ "<p><a href=\"/wiki/view/Foo/Bar\">Bar</a></p>" ] [ "[[Foo/Bar]]" convert-farkup ] unit-test
] with-variable

[ ] [ "[{}]" convert-farkup drop ] unit-test

[ "<pre>hello</pre>" ] [ "[{hello}]" convert-farkup ] unit-test

[
    "<p>Feature comparison:</p><table><tr><td>a</td><td>Factor</td><td>Java</td><td>Lisp</td></tr><tr><td>Coolness</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Badass</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Enterprise</td><td>Yes</td><td>Yes</td><td>No</td></tr><tr><td>Kosher</td><td>Yes</td><td>No</td><td>Yes</td></tr></table>"
] [ "Feature comparison:\n|a|Factor|Java|Lisp|\n|Coolness|Yes|No|No|\n|Badass|Yes|No|No|\n|Enterprise|Yes|Yes|No|\n|Kosher|Yes|No|Yes|\n" convert-farkup ] unit-test

[
    "<p>Feature comparison:</p><table><tr><td>a</td><td>Factor</td><td>Java</td><td>Lisp</td></tr><tr><td>Coolness</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Badass</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>Enterprise</td><td>Yes</td><td>Yes</td><td>No</td></tr><tr><td>Kosher</td><td>Yes</td><td>No</td><td>Yes</td></tr></table>"
] [ "Feature comparison:\n\n|a|Factor|Java|Lisp|\n|Coolness|Yes|No|No|\n|Badass|Yes|No|No|\n|Enterprise|Yes|Yes|No|\n|Kosher|Yes|No|Yes|\n" convert-farkup ] unit-test

[
    "<p>This wiki is written in <a href=\"Factor\">Factor</a> and is hosted on a <a href=\"http://linode.com\">http://linode.com</a> virtual server.</p>"
] [
    "This wiki is written in [[Factor]] and is hosted on a [[http://linode.com|http://linode.com]] virtual server."
    convert-farkup
] unit-test

[ "<p><a href=\"a\">a</a> <a href=\"b\">c</a></p>" ] [ "[[a]] [[b|c]]" convert-farkup ] unit-test

[ "<p><a href=\"C%2b%2b\">C++</a></p>" ] [ "[[C++]]" convert-farkup ] unit-test

[ "<p>&lt;foo&gt;</p>" ] [ "<foo>" convert-farkup ] unit-test

[ "<p>asdf</p><ul><li>lol</li><li>haha</li></ul>" ] [ "asdf\n-lol\n-haha" convert-farkup ] unit-test

[ "<p>asdf</p><ul><li>lol</li><li>haha</li></ul>" ]
 [ "asdf\n\n-lol\n-haha" convert-farkup ] unit-test

[ "<hr/>" ] [ "___" convert-farkup ] unit-test
[ "<hr/>" ] [ "___\n" convert-farkup ] unit-test

[ "<p>before:</p><pre><span class=\"OPERATOR\">{</span> <span class=\"DIGIT\">1</span> <span class=\"DIGIT\">2</span> <span class=\"DIGIT\">3</span> <span class=\"OPERATOR\">}</span> <span class=\"DIGIT\">1</span> tail</pre>" ] 
[ "before:\n[factor{{ 1 2 3 } 1 tail}]" convert-farkup ] unit-test
 
[ "<p><a href=\"Factor\">Factor</a>-rific!</p>" ]
[ "[[Factor]]-rific!" convert-farkup ] unit-test

[ "<pre> 1 2 3 </pre>" ]
[ "[ factor { 1 2 3 }]" convert-farkup ] unit-test

[ "<p>paragraph</p><hr/>" ]
[ "paragraph\n___" convert-farkup ] unit-test

[ "<p>paragraph</p><p> a <em></em><em> b</em></p>" ]
[ "paragraph\n a ___ b" convert-farkup ] unit-test

[ "<ul><li> a</li></ul><hr/>" ]
[ "\n- a\n___" convert-farkup ] unit-test

[ "<p>hello<em>world how are you today?</em></p><ul><li> hello<em>world how are you today?</em></li></ul>" ]
[ "hello_world how are you today?\n- hello_world how are you today?" convert-farkup ] unit-test

: check-link-escaping ( string -- link )
    convert-farkup string>xml-chunk
    "a" deep-tag-named "href" attr url-decode ;

[ "Trader Joe\"s" ] [ "[[Trader Joe\"s]]" check-link-escaping ] unit-test
[ "<foo>" ] [ "[[<foo>]]" check-link-escaping ] unit-test
[ "&blah;" ] [ "[[&blah;]]" check-link-escaping ] unit-test
[ "C++" ] [ "[[C++]]" check-link-escaping ] unit-test

[ "<h1>The <em>important</em> thing</h1>" ] [ "=The _important_ thing=" convert-farkup ] unit-test
[ "<p><a href=\"Foo\"><strong>emphasized</strong> text</a></p>" ] [ "[[Foo|*emphasized* text]]" convert-farkup ] unit-test
[ "<table><tr><td><strong>bold</strong></td><td><em>italics</em></td></tr></table>" ]
[ "|*bold*|_italics_|" convert-farkup ] unit-test
[ "<p><em>italics<strong>both</strong></em></p>" ] [ "_italics*both" convert-farkup ] unit-test
[ "<p><em>italics<strong>both</strong></em></p>" ] [ "_italics*both*" convert-farkup ] unit-test
[ "<p><em>italics<strong>both</strong></em></p>" ] [ "_italics*both*_" convert-farkup ] unit-test
[ "<p><em>italics<strong>both</strong></em></p>" ] [ "_italics*both_" convert-farkup ] unit-test
[ "<p><em>italics<strong>both</strong></em>after<strong></strong></p>" ] [ "_italics*both_after*" convert-farkup ] unit-test
[ "<table><tr><td>foo|bar</td></tr></table>" ] [ "|foo\\|bar|" convert-farkup ] unit-test
[ "<p></p>" ] [ "\\" convert-farkup ] unit-test

! [ "<p>[abc]</p>" ] [ "[abc]" convert-farkup ] unit-test

: random-markup ( -- string )
    10 [
        2 random 1 = [
            {
                "[["
                "*"
                "_"
                "|"
                "-"
                "[{"
                "\n"
            } random
        ] [
            "abc"
        ] if
    ] replicate concat ;

[ t ] [
    100 [
        drop random-markup
        [ convert-farkup drop t ] [ drop print f ] recover
    ] all?
] unit-test
