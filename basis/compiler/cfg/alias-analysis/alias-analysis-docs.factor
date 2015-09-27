USING: compiler.cfg.instructions help.markup help.syntax kernel ;
IN: compiler.cfg.alias-analysis

HELP: useless-compare?
{ $values
  { "insn" "a " { $link ##compare } " instruction" }
  { "?" boolean }
}
{ $description "Checks if the comparison instruction is required." } ;

ARTICLE: "compiler.cfg.alias-analysis"
"Alias analysis for stack operations, array elements and tuple slots"
"We try to eliminate redundant slot operations using some simple heuristics."
$nl
"All heap-allocated objects which are loaded from the stack, or other object slots are pessimistically assumed to belong to the same alias class."
$nl
"Freshly-allocated objects get their own alias class."
$nl
"Simple pseudo-C example showing load elimination:"
{ $code
  "int *x, *y, z: inputs"
  "int a, b, c, d, e: locals"
}
"Before alias analysis:"
{ $code
  "a = x[2]"
  "b = x[2]"
  "c = x[3]"
  "y[2] = z"
  "d = x[2]"
  "e = y[2]"
  "f = x[3]"
}
"After alias analysis:"
{ $code
  "a = x[2]"
  "b = a /* ELIMINATED */"
  "c = x[3]"
  "y[2] = z"
  "d = x[2] /* if x=y, d=z, if x!=y, d=b; NOT ELIMINATED */"
  "e = z /* ELIMINATED */"
  "f = c /* ELIMINATED */"
}
"Simple pseudo-C example showing store elimination:"
$nl
"Before alias analysis:"
{ $code
  "x[0] = a"
  "b = x[n]"
  "x[0] = c"
  "x[1] = d"
  "e = x[0]"
  "x[1] = c"
}
"After alias analysis:"
{ $code
  "x[0] = a /* dead if n = 0, live otherwise; NOT ELIMINATED */"
  "b = x[n]"
  "x[0] = c"
  "/* x[1] = d */  /* ELIMINATED */"
  "e = c"
  "x[1] = c"
} ;

ABOUT: "compiler.cfg.alias-analysis"
