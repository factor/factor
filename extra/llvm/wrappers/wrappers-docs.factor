! Copyright (C) 2017 Björn Lindqvist.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: llvm.wrappers

HELP: <provider>
{ $values { "module" module } { "provider" provider } }
{ $description "Creates a module provider from a given module. The provider takes ownership of the module." } ;

HELP: <engine>
{ $values { "module" module } { "engine" engine } }
{ $description "Creates a engine from a given module. The engine takes ownership of the module and disposes it." } ;
