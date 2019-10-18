
USING: kernel lexer parser words quotations compiler.units ;

IN: sto

! Use 'sto' to bind a value on the stack to a word.
!
! Example:
!
!   10 sto A

: sto
  \ 1quotation parsed
  scan
    current-vocab create
    dup set-word
  literalize parsed
  \ swap parsed
  [ define ] parsed
  \ with-compilation-unit parsed ;                              parsing
