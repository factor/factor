! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel windows.ole32 ;
IN: windows.dropfiles

HELP: filecount-from-hdrop
{ $values
    { "hdrop" null }
    { "n" null }
}
{ $description "" } ;

HELP: filenames-from-hdrop
{ $values
    { "hdrop" null }
    { "filenames" null }
}
{ $description "" } ;
