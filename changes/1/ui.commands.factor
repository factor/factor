USING: accessors kernel sequences splitting ui.commands unicode
words ;
IN: ui.commands

M: word command-name
    name>> "com " ?head drop "." ?tail drop dup first Letter?
    [ rest ] unless (command-name) ;
