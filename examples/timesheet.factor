! Contractor timesheet example

IN: timesheet
USING: errors kernel lists math namespaces sequences stdio
strings unparser vectors ;

! Adding a new entry to the time sheet.

: measure-duration ( -- duration )
    millis
    read drop
    millis swap - 1000 /i 60 /i ;

: add-entry-prompt ( -- duration description )
    "Start work on the task now. Press ENTER when done." print
    measure-duration
    "Please enter a description:" print
    read ;

: add-entry ( timesheet -- )
    add-entry-prompt cons swap push ;

! Printing the timesheet.

: hh ( duration -- str ) 60 /i ;
: mm ( duration -- str ) 60 mod unparse 2 "0" pad ;
: hh:mm ( millis -- str ) [ dup hh , ":" , mm , ] make-string ;

: pad-string ( len str -- str )
    length - " " fill ;

: print-entry ( duration description -- )
    dup write
    60 swap pad-string write
    hh:mm print ;

: print-timesheet ( timesheet -- )
    "TIMESHEET:" print
    [ uncons print-entry ] each ;

! Displaying a menu

: print-menu ( menu -- )
    terpri [ cdr car print ] each terpri
    "Enter a letter between ( ) to execute that action." print ;

: menu-prompt ( menu -- )
    read swap assoc dup [
        cdr call
    ] [
        "Invalid input: " swap unparse cat2 throw
    ] ifte ;

: menu ( menu -- )
    dup print-menu menu-prompt ;

! Main menu

: main-menu ( timesheet -- )
    [
        [ "e" "(E)xit" drop ]
        [ "a" "(A)dd entry" dup add-entry main-menu ]
        [ "p" "(P)rint timesheet" dup print-timesheet main-menu ]
    ] menu ;

: timesheet-app ( -- )
    10 <vector> main-menu ;
