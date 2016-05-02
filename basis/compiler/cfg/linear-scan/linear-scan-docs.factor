USING: assocs compiler.cfg help.markup help.syntax ;
IN: compiler.cfg.linear-scan

HELP: admissible-registers
{ $values { "cfg" cfg } { "regs" assoc } }
{ $description "Lists all registers usable by the cfg by register class. In general, that's all registers except the frame pointer register that might be used by the cfg for other purposes." } ;

HELP: allocate-and-assign-registers
{ $values { "cfg" cfg } }
{ $description "Allocates and assigns registers and spill slots to SSA values in the cfg." } ;

HELP: linear-scan
{ $values { "cfg" cfg } }
{ $description "Entry point for the linear scan register allocation pass." } ;

ARTICLE: "compiler.cfg.linear-scan" "Linear-scan register allocation"
"Linear scan to assign physical registers. SSA liveness must have been computed already. It also spills registers that are live during gc calls."
{ $heading "References" }
{ $list
  "Linear Scan Register Allocation by Massimiliano Poletto and Vivek Sarkar http://www.cs.ucla.edu/~palsberg/course/cs132/linearscan.pdf"
  "Linear Scan Register Allocation for the Java HotSpot Client Compiler by Christian Wimmer and http://www.ssw.uni-linz.ac.at/Research/Papers/Wimmer04Master/"
  "Quality and Speed in Linear-scan Register Allocation by Omri Traub, Glenn Holloway, Michael D. Smith http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.34.8435"
}
"Optimization pass entry point:"
{ $subsections linear-scan } ;

ABOUT: "compiler.cfg.linear-scan"
