USING: unicode.syntax hash2 assocs unicode.load kernel parser ;
IN: unicode

: canonical-entry ( char -- seq ) canonical-map at ;
: combine-chars ( a b -- char/f ) combine-map hash2 ;
: compat-entry ( char -- seq ) compat-map at  ;
: combining-class ( char -- n ) class-map at ;
: non-starter? ( char -- ? ) class-map key? ;
: name>char ( string -- char ) name-map at ;
: char>name ( char -- string ) name-map value-at ;

CATEGORY: blank Zs Zl Zp ;
CATEGORY: letter Ll ;
CATEGORY: LETTER Lu ;
CATEGORY: Letter Lu Ll Lt Lm Lo ;
CATEGORY: digit Nd Nl No ;
CATEGORY-NOT: printable Cc Cf Cs Co Cn ;
CATEGORY: alpha Lu Ll Lt Lm Lo Nd Nl No ;
CATEGORY: control Cc ;
CATEGORY-NOT: uncased Lu Ll Lt Lm Mn Me ; 
CATEGORY-NOT: character Cn ;

: UNICHAR:
    ! This should be part of CHAR:
    scan name>char [ parsed ] [ "Invalid character" throw ] if* ; parsing
