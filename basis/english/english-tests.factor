USING: arrays assocs english help.markup kernel math sequences
strings tools.test ;
FROM: english => a/an ;

{ "record" }  [ "records" singularize ] unit-test
{ "record" }  [ "record" singularize ] unit-test
{ "baby" }    [ "babies" singularize ] unit-test
{ "baby" }    [ "baby" singularize ] unit-test
{ "FOOT" }    [ "FEET" singularize ] unit-test
{ "FOOT" }    [ "FOOT" singularize ] unit-test
{ "cactus" }  [ "cacti" singularize ] unit-test
{ "cactus" }  [ "cactuses" singularize ] unit-test
{ "octopus" } [ "octopi" singularize ] unit-test
{ "octopus" } [ "octopuses" singularize ] unit-test

{ "friends" } [ "friend" pluralize ] unit-test
{ "friendlies" } [ "friendly" pluralize ] unit-test
{ "friendlies" } [ "friendlies" pluralize ] unit-test
{ "enemies" } [ "enemy" pluralize ] unit-test
{ "Sheep" }   [ "Sheep" pluralize ] unit-test
{ "Moose" }   [ "Moose" pluralize ] unit-test
{ "cacti" }   [ "cactus" pluralize ] unit-test
{ "octopi" }  [ "octopus" pluralize ] unit-test

{ t } [ "singular" singular? ] unit-test
{ f } [ "singulars" singular? ] unit-test
{ t } [ "singularity" singular? ] unit-test
{ f } [ "singularities" singular? ] unit-test
{ t } [ "thesis" singular? ] unit-test
{ f } [ "theses" singular? ] unit-test
{ t } [ "goose" singular? ] unit-test
{ t } [ "baby" singular? ] unit-test
{ t } [ "bird" singular? ] unit-test
{ f } [ "birds" singular? ] unit-test
{ t } [ "octopus" singular? ] unit-test
{ f } [ "octopi" singular? ] unit-test

{ t } [ "geese" plural? ] unit-test
{ f } [ "goose" plural? ] unit-test
{ t } [ "birds" plural? ] unit-test
{ f } [ "bird" plural? ] unit-test
{ t } [ "cats" plural? ] unit-test
{ f } [ "cat" plural? ] unit-test
{ t } [ "babies" plural? ] unit-test
{ f } [ "baby" plural? ] unit-test
{ t } [ "octopi" plural? ] unit-test
{ f } [ "octopus" plural? ] unit-test

! they are both singular and plural
{ t } [ "moose" plural? ] unit-test
{ t } [ "moose" singular? ] unit-test
{ t } [ "sheep" plural? ] unit-test
{ t } [ "sheep" singular? ] unit-test

{ "3 babies" } [ 3 "baby" count-of-things ] unit-test
{ "2.5 cats" } [ 2.5 "cat" count-of-things ] unit-test
{ "2.5 CATS" } [ 2.5 "CAT" count-of-things ] unit-test
{ "1 pipe" }   [ 1 "pipe" count-of-things ] unit-test
{ "0 pipes" }  [ 0 "pipe" count-of-things ] unit-test

{ "babies" } [ 3 "baby" ?pluralize ] unit-test
{ "BABIES" } [ 3 "BABY" ?pluralize ] unit-test
{ "cats" } [ 2.5 "cat"  ?pluralize ] unit-test
{ "Cats" } [ 2.5 "Cat"  ?pluralize ] unit-test
{ "pipe" } [ 1 "pipe"   ?pluralize ] unit-test
{ "pipes" } [ 0 "pipe"  ?pluralize ] unit-test

{ "a5s" }     [ "address" a10n ] unit-test
{ "a10n" }    [ "abbreviation" a10n ] unit-test
{ "l10n" }    [ "localization" a10n ] unit-test
{ "i18n" }    [ "internationalization" a10n ] unit-test
{ "f28n" }    [ "floccinauccinihilipilification" a10n ] unit-test
{ "p43s" }    [ "pneumonoultramicroscopicsilicovolcanoconiosis" a10n ] unit-test
{ "a10000c" } [ 10000 CHAR: b <string> "a" "c" surround a10n ] unit-test

{ "an" } [ "object" a/an ] unit-test
{ "an" } [ "elephant" a/an ] unit-test
{ "a" }  [ "moose" a/an ] unit-test
{ "a" }  [ "xylophone" a/an ] unit-test

{ "the" } [ "objects" ?plural-article ] unit-test
{ "an" }  [ "object" ?plural-article ] unit-test
{ "the" } [ "elephants" ?plural-article ] unit-test
{ "an" }  [ "elephant" ?plural-article ] unit-test
{ "a" }   [ "moose" ?plural-article ] unit-test
{ "a" }   [ "goose" ?plural-article ] unit-test
{ "the" } [ "geese" ?plural-article ] unit-test
{ "a" }   [ "sheep" ?plural-article ] unit-test

{ { } } [ { } "or" comma-list ] unit-test

{ { "a" } } [ { "a" } "or" comma-list ] unit-test

{ { "a" " or " "b" } }
[ { "a" "b" } "or" comma-list ] unit-test

{ { "a" ", " "b" ", or " "c" } }
[ { "a" "b" "c" } "or" comma-list ] unit-test

{ { "a" ", " "b" ", " "x" ", and " "c" } }
[ { "a" "b" "x" "c" } "and" comma-list ] unit-test
