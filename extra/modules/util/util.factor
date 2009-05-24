USING: accessors assocs kernel lexer locals namespaces sequences
vocabs vocabs.parser ;
IN: modules.util
SYNTAX: EXPORT-FROM: [let | v [ in get ] |
   v vocab words>> ";" parse-tokens
   [ load-vocab vocab-words [ clone v >>vocabulary ] assoc-map ] map
   assoc-combine update ] ;