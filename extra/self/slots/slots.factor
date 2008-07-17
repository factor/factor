
USING: kernel words lexer parser sequences accessors self ;

IN: self.slots

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: define-self-slot-reader ( slot -- )
  [ "->" append current-vocab create dup set-word ]
  [ ">>" append search [ self> ] swap suffix      ] bi
  (( -- value )) define-declared ;

: define-self-slot-writer ( slot -- )
  [ "->" prepend current-vocab create dup set-word ]
  [ ">>" prepend search [ self> swap ] swap suffix [ drop ] append ] bi
  (( value -- )) define-declared ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: define-self-slot-accessors ( class -- )
  "slots" word-prop
  [ name>> ] map
  [ [ define-self-slot-reader ] [ define-self-slot-writer ] bi ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: SELF-SLOTS: scan-word define-self-slot-accessors ; parsing