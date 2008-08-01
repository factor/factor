
USING: kernel sequences math inference accessors macros
       combinators.short-circuit ;

IN: combinators.short-circuit.smart

MACRO: && ( quots -- quot )
  dup first infer [ in>> ] [ out>> ] bi - 1+ n&&-rewrite ;

MACRO: || ( quots -- quot )
  dup first infer [ in>> ] [ out>> ] bi - 1+ n||-rewrite ;
