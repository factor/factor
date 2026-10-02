USING: help.markup help.syntax ;
IN: ui.operations.syntax

HELP: OPERATION:
{ $syntax "OPERATION: command [ predicate ] H{ flags }" }
{ $description "Defines a named operation for an existing command word. Reloading replaces the definition even when the predicate changes; removing the definition from its source file unregisters it. Each command has one named operation, and its predicate may combine several conditions." } ;
