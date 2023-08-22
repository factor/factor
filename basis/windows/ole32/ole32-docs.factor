! Copyright (C) 2016 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel windows.kernel32 ;
IN: windows.ole32

HELP: create-guid
{ $values
    { "GUID" GUID }
}
{ $description "Generate a new random " { $link GUID } " value." } ;
