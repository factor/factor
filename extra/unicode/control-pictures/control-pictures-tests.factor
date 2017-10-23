USING: sequences strings tools.test unicode.control-pictures ;

{ "␀␁␂␃␄␅␆␇␈␉␊␋␌␍␎␏␐␑␒␓␔␕␖␗␘␙␚␛␜␝␞␟ !\"#$%&'()*+,-./" } [
    48 <iota> >string control-pictures
] unit-test
