! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs io kernel math.parser sequences
sorting ;
IN: rosetta-code.top-rank

! https://rosettacode.org/wiki/Top_rank_per_group

! Find the top N salaries in each department, where N is
! provided as a parameter.

! Use this data as a formatted internal data structure (adapt it
! to your language-native idioms, rather than parse at runtime),
! or identify your external data source:

! Employee Name,Employee ID,Salary,Department
! Tyler Bennett,E10297,32000,D101
! John Rappl,E21437,47000,D050
! George Woltman,E00127,53500,D101
! Adam Smith,E63535,18000,D202
! Claire Buckman,E39876,27800,D202
! David McClellan,E04242,41500,D101
! Rich Holcomb,E01234,49500,D202
! Nathan Adams,E41298,21900,D050
! Richard Potter,E43128,15900,D101
! David Motsinger,E27002,19250,D202
! Tim Sampair,E03033,27000,D101
! Kim Arlich,E10001,57000,D190
! Timothy Grove,E16398,29900,D190

TUPLE: employee name id salary department ;

CONSTANT: employees {
        T{ employee f "Tyler Bennett" "E10297" 32000 "D101" }
        T{ employee f "John Rappl" "E21437" 47000 "D050" }
        T{ employee f "George Woltman" "E00127" 53500 "D101" }
        T{ employee f "Adam Smith" "E63535" 18000 "D202" }
        T{ employee f "Claire Buckman" "E39876" 27800 "D202" }
        T{ employee f "David McClellan" "E04242" 41500 "D101" }
        T{ employee f "Rich Holcomb" "E01234" 49500 "D202" }
        T{ employee f "Nathan Adams" "E41298" 21900 "D050" }
        T{ employee f "Richard Potter" "E43128" 15900 "D101" }
        T{ employee f "David Motsinger" "E27002" 19250 "D202" }
        T{ employee f "Tim Sampair" "E03033" 27000 "D101" }
        T{ employee f "Kim Arlich" "E10001" 57000 "D190" }
        T{ employee f "Timothy Grove" "E16398" 29900 "D190" }
    }

: prepare-departments ( seq -- departments )
    [ department>> ] collect-by
    [ [ salary>> ] inv-sort-by ] assoc-map ;

: first-n-each ( seq n quot -- )
    [ index-or-length head-slice ] dip each ; inline

: top-rank-main ( -- )
    employees prepare-departments [
        [ "Department " write write ":" print ] dip
        3 [
            [ id>> write "  $" write ]
            [ salary>> number>string write "  " write ]
            [ name>> print ] tri
        ] first-n-each
        nl
    ] assoc-each ;

MAIN: top-rank-main
