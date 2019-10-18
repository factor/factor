! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax help.tips quotations destructors ;
IN: tools.destructors

HELP: disposables.
{ $description "Print the number of disposable objects of each class." } ;

HELP: leaks
{ $values
    { "quot" quotation }
}
{ $description "Runs a quotation, printing any increases in the number of disposable objects after the quotation returns. The " { $link debug-leaks? } " variable is also switched on while the quotation runs, recording the current continuation in every newly-created disposable object." } ;

TIP: "Use the " { $link leaks } " combinator to track down resource leaks." ;

ARTICLE: "tools.destructors" "Destructor tools"
"The " { $vocab-link "tools.destructors" } " vocabulary provides words for tracking down resource leaks."
{ $subsections
    debug-leaks?
    disposables.
    leaks
}
{ $see-also "destructors" } ;

ABOUT: "tools.destructors"
