! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: unicode.categories.syntax sequences unicode.data ;
IN: unicode.categories

CATEGORY: blank Zs Zl Zp | "\r\n\t" member? ;
CATEGORY: letter Ll | "Other_Lowercase" property? ;
CATEGORY: LETTER Lu | "Other_Uppercase" property? ;
CATEGORY: Letter Lu Ll Lt Lm Lo Nl ;
CATEGORY: digit Nd Nl No ;
CATEGORY-NOT: printable Cc Cf Cs Co Cn ;
CATEGORY: alpha Lu Ll Lt Lm Lo Nd Nl No | "Other_Alphabetic" property? ;
CATEGORY: control Cc ;
CATEGORY-NOT: uncased Lu Ll Lt Lm Mn Me ;
CATEGORY-NOT: character Cn ;
CATEGORY: math Sm | "Other_Math" property? ;
