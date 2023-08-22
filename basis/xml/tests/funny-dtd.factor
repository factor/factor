! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
IN: xml.tests
USING: xml xml.writer io.files io.encodings.utf8 tools.test kernel ;

[ t ] [
    "vocab:xml/tests/funny-dtd.xml" utf8 file-contents string>xml
    dup xml>string string>xml =
] unit-test
