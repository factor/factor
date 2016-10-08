USING: cpu.architecture help.markup help.syntax ;
IN: compiler.cfg.representations

ARTICLE: "compiler.cfg.representations" "Virtual register representation selection"
"Virtual register representation selection. This is where decisions about integer tagging and float and vector boxing are made. The appropriate conversion operations inserted after a cost analysis."
$nl
"Good representation selection is very important for Factor because it uses tagged pointers. If the best representations are selected, then the number of conversions between " { $link int-rep } " and " { $link tagged-rep } " is minimized." ;

ABOUT: "compiler.cfg.representations"
