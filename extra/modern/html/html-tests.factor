! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.encodings.utf8 io.files kernel make math modern.html
multiline sequences tools.test ;
IN: modern.html.tests

[
    [[ <html>]] string>html
] [ unmatched-open-tags-error? ] must-fail-with

[
    [[ <html><body></html>]] string>html
] [ unmatched-open-tags-error? ] must-fail-with

[
    [[ <html><body><html/>]] string>html
] [ unmatched-open-tags-error? ] must-fail-with

[
    [[ </html>]] string>html
] [ unmatched-closing-tag-error? ] must-fail-with

[
    [[ <html></html123>]] string>html
] [ unmatched-closing-tag-error? ] must-fail-with

{ [[ <html><head>omg</head><body><asdf a b c="d"> <a/></asdf></body></html>]] } [
    [[ <html><head>omg</head><body><asdf a b c="d" > <a/></asdf></body></html>]] string>html html>string
] unit-test

[
    [[ <html><head>omg<body></body></html>]] string>html html>string
] [ unmatched-open-tags-error? ] must-fail-with

{ [[ <!-- omg omg -->]] }
[ [[ <!-- omg omg -->]] string>html html>string ] unit-test

{ "<div> <div>  <a/> <b/> <c/> </div> </div>" }
[ "<div> <div>  <a/> <b/> <c/> </div> </div>" string>html html>string ] unit-test

{ "<?xml version='1.0'?>" }
[ [[ <?xml version='1.0'?> ]] string>html html>string ] unit-test

{ "<?xml version='1.0'?>" }
[ [[ <?xml version='1.0' ?> ]] string>html html>string ] unit-test

{
    V{
        T{ doctype
            { open "<!DOCTYPE" }
            { close ">" }
            { values
                V{
                    "plist"
                    "PUBLIC"
                    T{ dquote
                        { payload "-//Apple//DTD PLIST 1.0//EN" }
                    }
                    T{ dquote
                        { payload
                            "https://www.apple.com/DTDs/PropertyList-1.0.dtd"
                        }
                    }
                }
            }
        }
    }
} [
    [[ <!DOCTYPE plist PUBLIC
    "-//Apple//DTD PLIST 1.0//EN"
    "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
    ]]
    string>html
] unit-test

{
    V{ T{ comment { open "<!--" } { payload " comment " } { close "-->" } } }
} [ [[ <!-- comment --> ]] string>html ] unit-test

! From wikipedia factor article
! https://en.wikipedia.org/w/index.php?title=Factor_(programming_language)&offset=&limit=500&action=history"
{
    V{
        "\n    "
        T{ doctype
            { open "<!DOCTYPE" }
            { close ">" }
            { values V{ "html" } }
        }
        "\n    "
        T{ open-tag
            { open "<" }
            { name "html" }
            { props
                V{
                    {
                        "class"
                        T{ dquote { payload "client-nojs" } }
                    }
                    { "lang" T{ dquote { payload "en" } } }
                    { "dir" T{ dquote { payload "ltr" } } }
                }
            }
            { close ">" }
            { children
                V{
                    "\n\n    "
                    T{ open-tag
                        { open "<" }
                        { name "head" }
                        { props V{ } }
                        { close ">" }
                        { children
                            V{
                                " "
                                T{ open-tag
                                    { open "<" }
                                    { name "title" }
                                    { props V{ } }
                                    { close ">" }
                                    { children V{ "omg" } }
                                    { close-tag
                                        T{ close-tag
                                            { name "title" }
                                        }
                                    }
                                }
                            }
                        }
                        { close-tag T{ close-tag { name "head" } } }
                    }
                    "\n    "
                    T{ open-tag
                        { open "<" }
                        { name "body" }
                        { props V{ } }
                        { close ">" }
                        { children
                            V{
                                "\n    "
                                T{ open-tag
                                    { open "<" }
                                    { name "div" }
                                    { props
                                        V{
                                            {
                                                "id"
                                                T{ squote
                                                    { payload
                                                        "ooui-php-6"
                                                    }
                                                }
                                            }
                                            {
                                                "data-ooui"
                                                T{ squote
                                                    { payload
                                                        "{\"_\":\"mw.htmlform.FieldLayout\",\"fieldWidget\":{\"tag\":\"tagfilter\"},\"align\":\"top\",\"helpInline\":true,\"$overlay\":true,\"label\":{\"html\":\"&lt;a href=\\\"\\/wiki\\/Special:Tags\\\" title=\\\"Special:Tags\\\"&gt;Tag&lt;\\/a&gt; filter:\"},\"classes\":[\"mw-htmlform-field-HTMLTagFilter\",\"mw-htmlform-autoinfuse\"]}"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    { close ">" }
                                    { children V{ "\n    " } }
                                    { close-tag
                                        T{ close-tag
                                            { name "div" }
                                        }
                                    }
                                }
                                "\n    "
                            }
                        }
                        { close-tag T{ close-tag { name "body" } } }
                    }
                    "\n    "
                }
            }
            { close-tag T{ close-tag { name "html" } } }
        }
    }
} [
    [[
    <!DOCTYPE html>
    <html class="client-nojs" lang="en" dir="ltr">

    <head> <title>omg</title></head>
    <body>
    <div id='ooui-php-6'
    data-ooui='{"_":"mw.htmlform.FieldLayout","fieldWidget":{"tag":"tagfilter"},"align":"top","helpInline":true,"$overlay":true,"label":{"html":"&lt;a href=\"\/wiki\/Special:Tags\" title=\"Special:Tags\"&gt;Tag&lt;\/a&gt; filter:"},"classes":["mw-htmlform-field-HTMLTagFilter","mw-htmlform-autoinfuse"]}'
    >
    </div>
    </body>
    </html>
    ]] string>html
] unit-test


! Handle tabs
{
    V{
    "\n\t"
    T{ open-tag
        { open "<" }
        { name "label" }
        { props
            V{
                {
                    "id"
                    T{ dquote { payload "p-personal-label" } }
                }
                {
                    "class"
                    T{ dquote
                        { payload "vector-menu-heading " }
                    }
                }
            }
        }
        { close ">" }
        { children
            V{
                "\n\t\t"
                T{ open-tag
                    { open "<" }
                    { name "span" }
                    { props
                        V{
                            {
                                "class"
                                T{ dquote
                                    { payload
                                        "vector-menu-heading-label"
                                    }
                                }
                            }
                        }
                    }
                    { close ">" }
                    { children V{ "Personal tools" } }
                    { close-tag T{ close-tag { name "span" } } }
                }
                "\n\t"
            }
        }
        { close-tag T{ close-tag { name "label" } } }
    }
}
} [
[[
	<label
		id="p-personal-label"
		
		class="vector-menu-heading "
	>
		<span class="vector-menu-heading-label">Personal tools</span>
	</label>
]] string>html
] unit-test

! Ensure we can parse <%factor "hi" print %> embedded code
{ t } [
    "resource:extra/websites/factorcode/index.fhtml" utf8 file-contents
    string>html [ [ dup embedded-language? [ , ] [ drop ] if ] walk-html ] { } make length 0 >
] unit-test
