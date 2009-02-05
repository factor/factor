! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup ;
IN: io.encodings.chinese

ARTICLE: "io.encodings.chinese" "Chinese text encodings"
"The " { $vocab-link "io.encodings.chinese" } " vocabulary implements encodings used for Chinese text besides the standard UTF encodings for Unicode strings."
{ $subsection gb18030 } ;

ABOUT: "io.encodings.chinese"

HELP: gb18030
{ $class-description "The encoding descriptor for GB 18030, a Chinese national standard for text encoding. GB 18030 consists of a unique encoding for each Unicode code point, and for this reason has been described as a UTF. It is backwards compatible with the earlier encodings GB 2312 and GBK." }
{ $see-also "encodings-introduction" } ;
