
USING: kernel namespaces sequences assocs sequences.deep obj ;

IN: obj.misc

: related ( obj -- seq )
  objects dupd remove [ get values flatten member? ] with filter ;

