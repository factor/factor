USING: assocs compiler.cfg help.markup help.syntax ;
IN: compiler.cfg.linear-scan

HELP: admissible-registers
{ $values { "cfg" cfg } { "regs" assoc } }
{ $description "Lists all registers usable by the cfg by register class. In general, that's all registers except the frame pointer register that might be used by the cfg for other purposes." } ;
