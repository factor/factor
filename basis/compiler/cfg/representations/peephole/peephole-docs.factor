USING: compiler.cfg.instructions help.markup help.syntax kernel ;
IN: compiler.cfg.representations.peephole

HELP: convert-to-zero-vector?
{ $values { "insn" insn } { "?" boolean } }
{ $description "When a literal zeroes/ones vector is unboxed, we replace the " { $link ##load-reference } " with a " { $link ##zero-vector } " or " { $link ##fill-vector } " instruction since this is more efficient." } ;


ARTICLE: "compiler.cfg.representations.peephole" "Peephole optimizations"
"Representation selection performs some peephole optimizations when inserting conversions to optimize for a few common cases." ;

ABOUT: "compiler.cfg.representations.peephole"
