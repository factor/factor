USING: continuations xml xml.errors tools.test kernel arrays xml.data state-parser quotations ;
IN: xml.tests

: xml-error-test ( expected-error xml-string -- )
    [ string>xml ] curry swap [ = ] curry must-fail-with ;

T{ no-entity T{ parsing-error f 1 10 } "nbsp" } "<x>&nbsp;</x>" xml-error-test
T{ mismatched T{ parsing-error f 1 8 } T{ name f "" "x" "" } T{ name f "" "y" "" }
} "<x></y>" xml-error-test
T{ unclosed f V{ T{ name f "" "x" "" } } } "<x>" xml-error-test
T{ nonexist-ns T{ parsing-error f 1 5 } "x" } "<x:y/>" xml-error-test
T{ unopened T{ parsing-error f 1 5 } } "</x>" xml-error-test
T{ not-yes/no T{ parsing-error f 1 41 } "maybe" } "<?xml version='1.0' standalone='maybe'?><x/>" xml-error-test
T{ extra-attrs T{ parsing-error f 1 32 } V{ T{ name f "" "foo" f } }
} "<?xml version='1.1' foo='bar'?><x/>" xml-error-test
T{ bad-version T{ parsing-error f 1 28 } "5 million" } "<?xml version='5 million'?><x/>" xml-error-test
T{ notags f } "" xml-error-test
T{ multitags f } "<x/><y/>" xml-error-test
T{ bad-prolog T{ parsing-error f 1 26 } T{ prolog f "1.0" "UTF-8" f }
} "<x/><?xml version='1.0'?>" xml-error-test
T{ capitalized-prolog T{ parsing-error f 1 6 } "XmL" } "<?XmL version='1.0'?><x/>"
xml-error-test
T{ pre/post-content f "x" t } "x<y/>" xml-error-test
T{ versionless-prolog T{ parsing-error f 1 8 } } "<?xml?><x/>" xml-error-test
T{ bad-instruction T{ parsing-error f 1 11 } T{ instruction f "xsl" }
} "<x><?xsl?></x>" xml-error-test
T{ bad-directive T{ parsing-error f 1 15 } T{ directive f "DOCTYPE" }
} "<x/><!DOCTYPE>" xml-error-test
