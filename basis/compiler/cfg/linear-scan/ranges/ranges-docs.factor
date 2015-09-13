USING: compiler.cfg help.syntax help.markup ;
IN: compiler.cfg.linear-scan.ranges

HELP: live-range
{ $class-description "Represents a range in the " { $link cfg } " in which a vreg is live." } ;

ARTICLE: "compiler.cfg.linear-scan.ranges" "Live ranges utilities"
"Utilities for dealing with the live range part of live intervals. A sequence of " { $link live-range } " tuples encodes where in the cfg a virtual register is live."
$nl
"Constructors:" { $subsections <live-range> live-range } ;

ABOUT: "compiler.cfg.linear-scan.ranges"
