! Copyright (C) 2010 Maximilian Lupke.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel strings ;
IN: semantic-versioning

HELP: version<
{ $values
    { "version1" string } { "version2" string }
    { "?" boolean }
} ;

HELP: version<=
{ $values
    { "version1" string } { "version2" string }
    { "?" boolean }
} ;

HELP: version<=>
{ $values
    { "version1" string } { "version2" string }
    { "<=>" string }
} ;

HELP: version=
{ $values
    { "version1" string } { "version2" string }
    { "?" boolean }
} ;

HELP: version>
{ $values
    { "version1" string } { "version2" string }
    { "?" boolean }
} ;

HELP: version>=
{ $values
    { "version1" string } { "version2" string }
    { "?" boolean }
} ;

ARTICLE: "semantic-versioning" "Semantic Versioning"
{ $vocab-link "semantic-versioning" }
$nl
{ "See " { $url "http://semver.org/" } " for a detailed description of semantic versioning." }
;

ABOUT: "semantic-versioning"
