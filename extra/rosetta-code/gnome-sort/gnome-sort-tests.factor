! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test rosetta-code.gnome-sort ;
IN: rosetta-code.gnome-sort.tests

{ V{ } } [ V{ } gnome-sort ] unit-test
{ V{ 0 } } [ V{ 0 } gnome-sort ] unit-test
{ V{ 0 1 2 3 4 5 } } [ V{ 0 1 2 3 4 5 } gnome-sort ] unit-test
{ V{ 0 1 2 3 4 5 } } [ V{ 5 4 3 2 1 0 } gnome-sort ] unit-test
{ V{ 0 1 2 3 4 5 } } [ V{ 2 4 5 1 3 0 } gnome-sort ] unit-test
