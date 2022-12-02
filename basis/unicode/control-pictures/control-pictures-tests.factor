USING: sequences strings tools.test unicode.control-pictures ;

{ "␀␁␂␃␄␅␆␇␈␉␊␋␌␍␎␏␐␑␒␓␔␕␖␗␘␙␚␛␜␝␞␟ !\"#$%&'()*+,-./" } [
    48 <iota> >string control-pictures
] unit-test

{ "␡" } [ "\x7f" control-pictures ] unit-test
{ "a␡b" } [ "a\x7fb" control-pictures ] unit-test
{ "a␡b" } [ "a\x7fb" control-pictures* ] unit-test

{ "␀␁␂␃␄␅␆␇␈␉␊␋␌␍␎␏␐␑␒␓␔␕␖␗␘␙␚␛␜␝␞␟␠!\"#$%&'()*+,-./" } [
    48 <iota> >string control-pictures*
] unit-test
