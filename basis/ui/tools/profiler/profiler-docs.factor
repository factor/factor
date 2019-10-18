IN: ui.tools.profiler
USING: help.markup help.syntax ui.operations ui.commands help.tips ;

ARTICLE: "ui.tools.profiler" "UI profiler tool" 
"The " { $vocab-link "ui.tools.profiler" } " vocabulary implements a graphical tool for viewing profiling results (see " { $link "profiling" } ")."
$nl
"To use the profiler, enter a piece of code in the listener input area and press " { $operation com-profile } "."
$nl
"Clicking on a vocabulary in the vocabulary list narrows down the word list to only include words from that vocabulary. The sorting options control the order of elements in the vocabulary and word lists. The search fields narrow down the list to only include words or vocabularies whose names contain a substring."
$nl
"Consult " { $link "profiling" } " for details about the profiler itself." ;

TIP: "Press " { $operation com-profile } " to run the code in the input field with profiling enabled (" { $link "ui.tools.profiler" } ")." ;

ABOUT: "ui.tools.profiler"