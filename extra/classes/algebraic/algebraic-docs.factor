USING: help.markup help.syntax ;
IN: classes.algebraic
HELP: DATA:
{ $syntax "DATA: class constructor | constructor arg ... | ... ;" }
{ $description "Creates a haskell style algebraic data type.  For each constructor, a seperate tuple is created, and the resulting tuples are added to a union class." } ;