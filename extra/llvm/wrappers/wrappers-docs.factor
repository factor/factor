! Copyright (C) 2017 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: llvm.wrappers

HELP: <provider>
{ $values { "module" module } { "provider" provider } }
{ $description "Creates a module provider from a given module. The provider takes ownership of the module." } ;
