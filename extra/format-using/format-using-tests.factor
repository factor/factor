! Copyright (C) 2023 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: format-using qw tools.test ;

{ "USING:
    io.directories io.encodings.utf8 io.files io.pathnames
    kernel
    math math.parser
    namespaces sequences sorting unicode
    xml.syntax xml.writer
;" }
[
    qw{
        kernel
        io.directories io.encodings.utf8 xml.writer io.files math
        io.pathnames namespaces math.parser sequences sorting
        unicode xml.syntax
    } format-using
] unit-test

{ "USING:
    accessors bit-arrays bit-sets interval-sets kernel literals
    math math.parser
    prettyprint.custom prettyprint.sections
    sequences sets strings typed
;" }
[
    qw{
        accessors literals kernel typed interval-sets bit-sets bit-arrays
        math math.parser prettyprint.custom prettyprint.sections sets
        strings sequences
    } format-using
] unit-test
