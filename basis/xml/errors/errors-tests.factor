USING: continuations xml xml.errors tools.test kernel arrays
xml.data quotations fry byte-arrays ;
IN: xml.errors.tests

: xml-error-test ( expected-error xml-string -- )
    '[ _ string>xml ] swap '[ _ = ] must-fail-with ;

T{ no-entity f 1 10 "nbsp" } "<x>&nbsp;</x>" xml-error-test
T{ mismatched f 1 7 T{ name f "" "x" "" } T{ name f "" "y" "" } }
    "<x></y>" xml-error-test
T{ unclosed f 1 3 V{ T{ name f "" "x" "" } } } "<x>" xml-error-test
T{ nonexist-ns f 1 5 "x" } "<x:y/>" xml-error-test
T{ unopened f 1 4 } "</x>" xml-error-test
T{ not-yes/no f 1 41 "maybe" }
    "<?xml version='1.0' standalone='maybe'?><x/>" xml-error-test
T{ extra-attrs f 1 32 { T{ name f "" "foo" f } }
} "<?xml version='1.1' foo='bar'?><x/>" xml-error-test
T{ bad-version f 1 28 "5 million" }
    "<?xml version='5 million'?><x/>" xml-error-test
T{ notags f } "" xml-error-test
T{ multitags } "<x/><y/>" xml-error-test
T{ bad-prolog  f 1 25 T{ prolog f "1.0" "UTF-8" f } }
    "<x/><?xml version='1.0'?>" xml-error-test
T{ capitalized-prolog f 1 6 "XmL" } "<?XmL version='1.0'?><x/>"
    xml-error-test
T{ pre/post-content f "x" t } "x<y/>" xml-error-test
T{ versionless-prolog f 1 8 } "<?xml?><x/>" xml-error-test
T{ unclosed-quote f 1 12 } "<x value='/>" xml-error-test
T{ bad-name f 1 3 "-" } "<-/>" xml-error-test
T{ quoteless-attr f 1 12 } "<x value=<->/>" xml-error-test
T{ quoteless-attr f 1 10 } "<x value=3/>" xml-error-test
T{ attr-w/< f 1 11 } "<x value='<'/>" xml-error-test
T{ text-w/]]> f 1 6 } "<x>]]></x>" xml-error-test
T{ duplicate-attr f 1 21 T{ name { space "" } { main "this" } } V{ "a" "b" } } "<x this='a' this='b'/>" xml-error-test
T{ bad-cdata f 1 3 } "<![CDATA[]]><x/>" xml-error-test
T{ bad-cdata f 1 7 } "<x/><![CDATA[]]>" xml-error-test
T{ pre/post-content f "&" t } "&#32;<x/>" xml-error-test
T{ bad-doctype f 1 17 "a" } "<!DOCTYPE foo [ a ]><x/>" xml-error-test
T{ bad-doctype f 1 22 T{ opener { name T{ name f "" "foo" "" } } { attrs T{ attrs } } } } "<!DOCTYPE foo [ <foo> ]><x/>" xml-error-test
T{ disallowed-char f 1 4 1 } "<x>\u000001</x>" xml-error-test
T{ missing-close f 1 8 } "<!-- foo" xml-error-test
T{ misplaced-directive f 1 9 "ENTITY" } "<!ENTITY foo 'bar'><x/>" xml-error-test
[ "<?xml version='1.0' encoding='foobar'?>" >byte-array bytes>xml ] [ T{ bad-encoding f 1 39 "foobar" } = ] must-fail-with
