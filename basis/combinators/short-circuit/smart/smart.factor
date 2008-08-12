
USING: kernel sequences math stack-checker accessors macros
       combinators.short-circuit ;

IN: combinators.short-circuit.smart

MACRO: && ( quots -- quot )
  dup first infer [ in>> ] [ out>> ] bi - 1+ n&&-rewrite ;

MACRO: || ( quots -- quot )
  dup first infer [ in>> ] [ out>> ] bi - 1+ n||-rewrite ;
