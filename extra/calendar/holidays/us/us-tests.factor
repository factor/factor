! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar calendar.holidays calendar.holidays.us kernel
sequences tools.test ;

{ 10 } [ 2009 us-federal holidays length ] unit-test

{
    {
        T{ timestamp
            { year 2020 }
            { month 1 }
            { day 1 }
            { gmt-offset T{ duration { hour -6 } } }
        }
        T{ timestamp
            { year 2020 }
            { month 1 }
            { day 20 }
            { gmt-offset T{ duration { hour -6 } } }
        }
        T{ timestamp
            { year 2020 }
            { month 2 }
            { day 17 }
            { gmt-offset T{ duration { hour -6 } } }
        }
        T{ timestamp
            { year 2020 }
            { month 5 }
            { day 25 }
            { gmt-offset T{ duration { hour -6 } } }
        }
        T{ timestamp
            { year 2020 }
            { month 7 }
            { day 3 }
            { gmt-offset T{ duration { hour -6 } } }
        }
        T{ timestamp
            { year 2020 }
            { month 9 }
            { day 7 }
            { gmt-offset T{ duration { hour -6 } } }
        }
        T{ timestamp
            { year 2020 }
            { month 10 }
            { day 12 }
            { gmt-offset T{ duration { hour -6 } } }
        }
        T{ timestamp
            { year 2020 }
            { month 11 }
            { day 11 }
            { gmt-offset T{ duration { hour -6 } } }
        }
        T{ timestamp
            { year 2020 }
            { month 11 }
            { day 26 }
            { gmt-offset T{ duration { hour -6 } } }
        }
        T{ timestamp
            { year 2020 }
            { month 12 }
            { day 25 }
            { gmt-offset T{ duration { hour -6 } } }
        }
    }
} [
    2020 <year> timestamp>year-dates [ us-federal holiday? ] filter
] unit-test