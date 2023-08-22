! Copyright (C) 2008 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup ;
IN: io.encodings.8-bit

HELP: ebcdic
{ $var-description "EBCDIC is an 8-bit legacy encoding designed for IBM mainframes like System/360 in the 1960s. It has since fallen into disuse. It contains large unallocated regions, and the version included here (code page 37) contains auxiliary characters in this region for English- and Portugese-speaking countries." }
{ $see-also "encodings-introduction" } ;

HELP: koi8-r
{ $var-description "KOI8-R is an 8-bit superset of ASCII which encodes the Cyrillic alphabet, as used in Russian and Bulgarian. Characters are in such an order that, if the eight bit is stripped, text is still interpretable as ASCII. Block-building characters also exist." }
{ $see-also "encodings-introduction" } ;

HELP: latin/arabic
{ $var-description "This is the ISO-8859-6 encoding, also called Latin/Arabic. It is an 8-bit superset of ASCII and provides the characters necessary for Arabic, though not other languages which use Arabic script." }
{ $see-also "encodings-introduction" } ;

HELP: latin/cyrillic
{ $var-description "This is the ISO-8859-5 encoding, also called Latin/Cyrillic. It is an 8-bit superset of ASCII and provides the characters necessary for most languages which use Cyrilic, including Russian, Macedonian, Belarusian, Bulgarian, Serbian, and Ukrainian. KOI8-R is used much more commonly." }
{ $see-also "encodings-introduction" } ;

HELP: latin/greek
{ $description "This is the ISO-8859-7 encoding, also called Latin/Greek. It is an 8-bit superset of ASCII and provides the characters necessary for Greek written in modern monotonic orthography, or ancient Greek without accent marks." }
{ $see-also "encodings-introduction" } ;

HELP: latin/hebrew
{ $var-description "This is the ISO-8859-8 encoding, also called Latin/Hebrew. It is an 8-bit superset of ASCII and provides the characters necessary for modern Hebrew without explicit vowels. Generally, this is interpreted in logical order, making it ISO-8859-8-I, technically." }
{ $see-also "encodings-introduction" } ;

HELP: latin/thai
{ $var-description "This is the ISO-8859-11 encoding, also called Latin/Thai. It is an 8-bit superset of ASCII containing the characters necessary to represent Thai. It is basically identical to TIS-620." }
{ $see-also "encodings-introduction" } ;

HELP: latin2
{ $var-description "This is the ISO-8859-2 encoding, also called Latin-2: Eastern European. It is an 8-bit superset of ASCII and provides the characters necessary for most eastern European languages." }
{ $see-also "encodings-introduction" } ;

HELP: latin3
{ $var-description "This is the ISO-8859-3 encoding, also called Latin-3: South European. It is an 8-bit superset of ASCII and provides the characters necessary for Turkish, Maltese and Esperanto." }
{ $see-also "encodings-introduction" } ;

HELP: latin4
{ $description "This is the ISO-8859-4 encoding, also called Latin-4: North European. It is an 8-bit superset of ASCII and provides the characters necessary for Latvian, Lithuanian, Estonian, Greenlandic and Sami." }
{ $see-also "encodings-introduction" } ;

HELP: latin5
{ $var-description "This is the ISO-8859-9 encoding, also called Latin-5: Turkish. It is an 8-bit superset of ASCII and provides the characters necessary for Turkish, similar to Latin-1 but replacing the spots used for Icelandic with characters used in Turkish." }
{ $see-also "encodings-introduction" } ;

HELP: latin6
{ $var-description "This is the ISO-8859-10 encoding, also called Latin-6: Nordic. It is an 8-bit superset of ASCII containing the same characters as Latin-4, but rearranged to be of better use to nordic languages." }
{ $see-also "encodings-introduction" } ;

HELP: latin7
{ $var-description "This is the ISO-8859-13 encoding, also called Latin-7: Baltic Rim. It is an 8-bit superset of ASCII containing all characters necessary to represent Baltic Rim languages, as previous character sets were incomplete." }
{ $see-also "encodings-introduction" } ;

HELP: latin8
{ $var-description "This is the ISO-8859-14 encoding, also called Latin-8: Celtic. It is an 8-bit superset of ASCII designed for Celtic languages like Gaelic and Breton." }
{ $see-also "encodings-introduction" } ;

HELP: latin9
{ $var-description "This is the ISO-8859-15 encoding, also called Latin-9 and unofficially as Latin-0. It is an 8-bit superset of ASCII designed as a modification of Latin-1, removing little-used characters in favor of the Euro symbol and other characters." }
{ $see-also "encodings-introduction" } ;

HELP: latin10
{ $var-description "This is the ISO-8859-16 encoding, also called Latin-10: South-Eastern European. It is an 8-bit superset of ASCII." }
{ $see-also "encodings-introduction" } ;

HELP: cp437
{ $var-description "This is the IBM437 encoding, also called CP437. It is an 8-bit superset of ASCII and provides the original DOS character set with the box-drawing characters used to draw windows and frames on the text terminals back in the day." }
{ $see-also "encodings-introduction" } ;

HELP: mac-roman
{ $var-description "Mac Roman is an 8-bit superset of ASCII which was the standard encoding on Mac OS prior to version 10. It is incompatible with Latin-1 in all but a few places and ASCII, and it is suitable for encoding many Western European languages." }
{ $see-also "encodings-introduction" } ;

HELP: windows-1252
{ $var-description "Windows 1252 is an 8-bit superset of ASCII which is closely related to Latin-1. Control characters in the 0x80 to 0x9F range are replaced with printable characters such as the Euro symbol." }
{ $see-also "encodings-introduction" } ;

ARTICLE: "io.encodings.8-bit" "Legacy 8-bit encodings"
"Many encodings are a simple mapping of bytes onto characters. The " { $vocab-link "io.encodings.8-bit" } " vocabulary implements these generically using existing resource files. These encodings should be used with extreme caution, as fully general Unicode encodings like UTF-8 are nearly always more appropriate." ;

ABOUT: "io.encodings.8-bit"
