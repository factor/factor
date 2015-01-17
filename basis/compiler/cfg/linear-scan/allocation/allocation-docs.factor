USING: compiler.cfg compiler.cfg.linear-scan.allocation help.markup
help.syntax sequences ;

HELP: (allocate-registers)
{ $values { "unhandled-min-heap" "stuff" } }
{ $description "Register allocation works by emptying the unhandled intervals and sync points." } ;
