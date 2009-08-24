! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax quotations ;
IN: tools.destructors

HELP: disposables.
{ $description "Print the number of disposable objects of each class." } ;

HELP: leaks
{ $values
    { "quot" quotation }
}
{ $description "Runs a quotation, printing any increases in the number of disposable objects after the quotation returns." } ;

ARTICLE: "tools.destructors" "Destructor tools"
"The " { $vocab-link "tools.destructors" } " vocabulary provides words for tracking down resource leaks."
{ $subsection disposables. }
{ $subsection leaks }
{ $see-also "destructors" } ;

ABOUT: "tools.destructors"
