! (c) Joe Groff, see license for details
USING: accessors continuations fry kernel lexer math parser
sequences vectors words words.alias ;
IN: literals

<PRIVATE

! Use def>> call so that CONSTANT:s defined in the same file can
! be called

: expand-alias ( obj -- obj' )
    dup alias? [ def>> first expand-alias ] when ;

: expand-literal ( seq obj -- seq' )
    '[
        _ expand-alias dup word? [ def>> call ] when
    ] with-datastack ;

: expand-literals ( seq -- seq' )
    { } [ expand-literal ] reduce ;

PRIVATE>

SYNTAX: $ scan-word expand-literal >vector ;
SYNTAX: $[ parse-quotation with-datastack >vector ;
SYNTAX: ${ \ } [ expand-literals ] parse-literal ;
SYNTAX: flags{
    \ } [
        expand-literals
        0 [ bitor ] reduce
    ] parse-literal ;
