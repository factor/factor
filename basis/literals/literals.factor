! (c) Joe Groff, see license for details
USING: accessors continuations kernel parser words quotations
combinators.smart vectors sequences fry ;
IN: literals

<PRIVATE

! Use def>> call so that CONSTANT:s defined in the same file can
! be called

: expand-literal ( seq obj -- seq' )
    '[ _ dup word? [ def>> call ] when ] with-datastack ;

: expand-literals ( seq -- seq' )
    [ [ { } ] dip expand-literal ] map concat ;

PRIVATE>

SYNTAX: $ scan-word expand-literal >vector ;
SYNTAX: $[ parse-quotation with-datastack >vector ;
SYNTAX: ${ \ } [ expand-literals ] parse-literal ;
