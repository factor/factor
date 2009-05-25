USING: accessors assocs kernel lexer locals namespaces sequences
vocabs vocabs.parser ;
IN: modules.util
SYNTAX: EXPORT-FROM: [let | v [ current-vocab ] |
   v words>> ";" parse-tokens
   [ load-vocab vocab-words [ clone v name>> >>vocabulary ] assoc-map ] map
   assoc-combine update ] ;