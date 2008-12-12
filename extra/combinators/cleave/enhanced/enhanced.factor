
USING: combinators.cleave fry kernel macros parser quotations ;

IN: combinators.cleave.enhanced

: \\
  scan-word literalize parsed
  scan-word literalize parsed ; parsing

MACRO: bi ( p q -- quot )
  [ >quot ] dip
    >quot
  '[ _ _ [ keep ] dip call ] ;

MACRO: tri ( p q r -- quot )
  [ >quot ] 2dip
  [ >quot ] dip
    >quot
  '[ _ _ _ [ [ keep ] dip keep ] dip call ] ;

MACRO: bi* ( p q -- quot )
  [ >quot ] dip
    >quot
  '[ _ _ [ dip ] dip call ] ;

MACRO: tri* ( p q r -- quot )
  [ >quot ] 2dip
  [ >quot ] dip
    >quot
  '[ _ _ _ [ [ 2dip ] dip dip ] dip call ] ;

