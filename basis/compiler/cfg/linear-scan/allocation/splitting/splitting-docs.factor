USING: compiler.cfg.linear-scan.live-intervals help.markup help.syntax
math ;
IN: compiler.cfg.linear-scan.allocation.splitting

HELP: split-interval
{ $values
  { "live-interval" live-interval-state }
  { "n" integer }
  { "before" live-interval-state }
  { "after" live-interval-state }
} { $description "Splits the interval in two around the flow point 'n'." } ;

ARTICLE: "compiler.cfg.linear-scan.allocation.splitting" "Live interval splitting"
"This vocab splits live intervals." ;

ABOUT: "compiler.cfg.linear-scan.allocation.splitting"
