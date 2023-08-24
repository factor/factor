USING: compiler.cfg.instructions help.markup help.syntax kernel ;
IN: compiler.cfg.value-numbering.comparisons

HELP: >test-branch
{ $values { "insn" insn } { "insn'" ##test-branch } }
{ $description "Converts a " { $link ##compare-integer-imm-branch } " instruction into a " { $link ##test-branch } " instruction." } ;

HELP: rewrite-into-test?
{ $values { "insn" insn } { "?" boolean } }
{ $description "Whether the comparison instruction can be trivially rewritten into a test instruction." } ;

ARTICLE: "compiler.cfg.value-numbering.comparisons" "Comparisons GVN"
"Optimizations performed here:"
$nl
{ $list
  "Eliminating intermediate boolean values when the result of a comparison is used by a compare-branch."
  "Folding comparisons where both inputs are literal."
  "Folding comparisons where both inputs are congruent."
  "Converting compare instructions into compare-imm instructions."
} ;


ABOUT: "compiler.cfg.value-numbering.comparisons"
