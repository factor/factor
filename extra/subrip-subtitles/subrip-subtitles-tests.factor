! Copyright (C) 2014 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar subrip-subtitles tools.test ;

{
    {
        T{ srt-chunk
            { id 1 }
            { begin-time T{ duration { second 10.5 } } }
            { end-time T{ duration { second 13.0 } } }
            { text "Elephant's Dream" }
        }
        T{ srt-chunk
            { id 2 }
            { begin-time T{ duration { second 15.0 } } }
            { end-time T{ duration { second 18.0 } } }
            { text "At the left we can see..." }
        }
    }
} [
"1
00:00:10,500 --> 00:00:13,000
Elephant's Dream

2
00:00:15,000 --> 00:00:18,000
At the left we can see..."
    parse-srt-string
] unit-test

{
    {
        T{ srt-chunk
            { id 1 }
            { begin-time T{ duration { second 10.5 } } }
            { end-time T{ duration { second 13.0 } } }
            { rect { { 63 43 } { 223 58 } } }
            { text "<i>Elephant's Dream</i>" }
        }
        T{ srt-chunk
            { id 2 }
            { begin-time T{ duration { second 15.0 } } }
            { end-time T{ duration { second 18.0 } } }
            { rect { { 53 438 } { 303 453 } } }
            { text
                "<font color=\"cyan\">At the left we can see...</font>"
            }
        }
    }
} [
"1
00:00:10,500 --> 00:00:13,000  X1:63 X2:223 Y1:43 Y2:58
<i>Elephant's Dream</i>

2
00:00:15,000 --> 00:00:18,000  X1:53 X2:303 Y1:438 Y2:453
<font color=\"cyan\">At the left we can see...</font>"
    parse-srt-string
] unit-test
