
USING: accessors effects.parser kernel lexer multi-methods
       parser sequences words ;

IN: multi-method-syntax

! A nicer specializer syntax to hold us over till multi-methods go in
! officially.
!
! Use both 'multi-methods' and 'multi-method-syntax' in that order.

: scan-specializer ( -- specializer )

  scan drop ! eat opening parenthesis

  ")" parse-effect in>> [ search ] map ;

: CREATE-METHOD ( -- method )
  scan-word scan-specializer swap create-method-in ;

: (METHOD:) ( -- method def ) CREATE-METHOD parse-definition ;

: METHOD: (METHOD:) define ; parsing