! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup io.encodings.8-bit.private
strings ;
IN: io.encodings.8-bit

ARTICLE: "io.encodings.8-bit" "Legacy 8-bit encodings"
"Many encodings are a simple mapping of bytes onto characters. The " { $vocab-link "io.encodings.8-bit" } " vocabulary implements these generically using existing resource files. These encodings should be used with extreme caution, as fully general Unicode encodings like UTF-8 are nearly always more appropriate. The following 8-bit encodings are available:"
{ $list
    { $vocab-link "io.encodings.8-bit.ebcdic" }
    { $vocab-link "io.encodings.8-bit.latin1" }
    { $vocab-link "io.encodings.8-bit.latin2" }
    { $vocab-link "io.encodings.8-bit.latin3" }
    { $vocab-link "io.encodings.8-bit.latin4" }
    { $vocab-link "io.encodings.8-bit.cyrillic" }
    { $vocab-link "io.encodings.8-bit.arabic" }
    { $vocab-link "io.encodings.8-bit.greek" }
    { $vocab-link "io.encodings.8-bit.hebrew" }
    { $vocab-link "io.encodings.8-bit.latin5" }
    { $vocab-link "io.encodings.8-bit.latin6" }
    { $vocab-link "io.encodings.8-bit.thai" }
    { $vocab-link "io.encodings.8-bit.latin7" }
    { $vocab-link "io.encodings.8-bit.latin8" }
    { $vocab-link "io.encodings.8-bit.latin9" }
    { $vocab-link "io.encodings.8-bit.koi8-r" }
    { $vocab-link "io.encodings.8-bit.mac-roman" }
    { $vocab-link "io.encodings.8-bit.windows-1250" }
    { $vocab-link "io.encodings.8-bit.windows-1251" }
    { $vocab-link "io.encodings.8-bit.windows-1252" }
    { $vocab-link "io.encodings.8-bit.windows-1253" }
    { $vocab-link "io.encodings.8-bit.windows-1254" }
    { $vocab-link "io.encodings.8-bit.windows-1255" }
    { $vocab-link "io.encodings.8-bit.windows-1256" }
    { $vocab-link "io.encodings.8-bit.windows-1257" }
    { $vocab-link "io.encodings.8-bit.windows-1258" }
} ;

ABOUT: "io.encodings.8-bit"
