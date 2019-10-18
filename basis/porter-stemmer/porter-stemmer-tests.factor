USING: arrays assocs io kernel porter-stemmer sequences
tools.test io.files io.encodings.utf8 ;

{ 0 } [ "xa" consonant-seq ] unit-test
{ 0 } [ "xxaa" consonant-seq ] unit-test
{ 1 } [ "xaxa" consonant-seq ] unit-test
{ 2 } [ "xaxaxa" consonant-seq ] unit-test
{ 3 } [ "xaxaxaxa" consonant-seq ] unit-test
{ 3 } [ "zzzzxaxaxaxaeee" consonant-seq ] unit-test

{ t } [ 0 "fish" consonant? ] unit-test
{ f } [ 0 "and" consonant? ] unit-test
{ t } [ 0 "yes" consonant? ] unit-test
{ f } [ 1 "gym" consonant? ] unit-test

{ t } [ 5 "splitting" double-consonant? ] unit-test
{ f } [ 2 "feel" double-consonant? ] unit-test

{ f } [ "xxxz" stem-vowel? ] unit-test
{ t } [ "baobab" stem-vowel? ] unit-test

{ t } [ "hop" cvc? ] unit-test
{ t } [ "cav" cvc? ] unit-test
{ t } [ "lov" cvc? ] unit-test
{ t } [ "crim" cvc? ] unit-test
{ f } [ "show" cvc? ] unit-test
{ f } [ "box" cvc? ] unit-test
{ f } [ "tray" cvc? ] unit-test
{ f } [ "meet" cvc? ] unit-test

{ "caress" } [ "caresses" step1a step1b "" like ] unit-test
{ "poni" } [ "ponies" step1a step1b "" like ] unit-test
{ "ti" } [ "ties" step1a step1b "" like ] unit-test
{ "caress" } [ "caress" step1a step1b "" like ] unit-test
{ "cat" } [ "cats" step1a step1b "" like ] unit-test
{ "feed" } [ "feed" step1a step1b "" like ] unit-test
{ "agree" } [ "agreed" step1a step1b "" like ] unit-test
{ "disable" } [ "disabled" step1a step1b "" like ] unit-test
{ "mat" } [ "matting" step1a step1b "" like ] unit-test
{ "mate" } [ "mating" step1a step1b "" like ] unit-test
{ "meet" } [ "meeting" step1a step1b "" like ] unit-test
{ "mill" } [ "milling" step1a step1b "" like ] unit-test
{ "mess" } [ "messing" step1a step1b "" like ] unit-test
{ "meet" } [ "meetings" step1a step1b "" like ] unit-test

{ "fishi" } [ "fishy" step1c ] unit-test
{ "by" } [ "by" step1c ] unit-test

{ "realizat" } [ "realization" step4 ] unit-test
{ "ion" } [ "ion" step4 ] unit-test
{ "able" } [ "able" step4 ] unit-test

{ "fear" } [ "feare" step5 "" like ] unit-test
{ "mate" } [ "mate" step5 "" like ] unit-test
{ "hell" } [ "hell" step5 "" like ] unit-test
{ "mate" } [ "mate" step5 "" like ] unit-test

{ { } } [
    "vocab:porter-stemmer/test/voc.txt" utf8 file-lines
    [ stem ] map
    "vocab:porter-stemmer/test/output.txt" utf8 file-lines
    zip [ = ] assoc-reject
] unit-test
