USING: cuesheet tools.test ;

{
    T{ cuesheet
        { files
            {
                T{ file
                    { name "Faithless - Live in Berlin.mp3" }
                    { type "MP3" }
                    { tracks
                        {
                            T{ track
                                { number 1 }
                                { datatype "AUDIO" }
                                { title "Reverence" }
                                { performer "Faithless" }
                                { indices
                                    {
                                        T{ index
                                            { number 1 }
                                            { duration "00:00:00" }
                                        }
                                    }
                                }
                            }
                            T{ track
                                { number 2 }
                                { datatype "AUDIO" }
                                { title "She's My Baby" }
                                { performer "Faithless" }
                                { indices
                                    {
                                        T{ index
                                            { number 1 }
                                            { duration "06:42:00" }
                                        }
                                    }
                                }
                            }
                            T{ track
                                { number 3 }
                                { datatype "AUDIO" }
                                { title "Take the Long Way Home" }
                                { performer "Faithless" }
                                { indices
                                    {
                                        T{ index
                                            { number 1 }
                                            { duration "10:54:00" }
                                        }
                                    }
                                }
                            }
                            T{ track
                                { number 4 }
                                { datatype "AUDIO" }
                                { title "Insomnia" }
                                { performer "Faithless" }
                                { indices
                                    {
                                        T{ index
                                            { number 1 }
                                            { duration "17:04:00" }
                                        }
                                    }
                                }
                            }
                            T{ track
                                { number 5 }
                                { datatype "AUDIO" }
                                { title "Bring the Family Back" }
                                { performer "Faithless" }
                                { indices
                                    {
                                        T{ index
                                            { number 1 }
                                            { duration "25:44:00" }
                                        }
                                    }
                                }
                            }
                            T{ track
                                { number 6 }
                                { datatype "AUDIO" }
                                { title "Salva Mea" }
                                { performer "Faithless" }
                                { indices
                                    {
                                        T{ index
                                            { number 1 }
                                            { duration "30:50:00" }
                                        }
                                    }
                                }
                            }
                            T{ track
                                { number 7 }
                                { datatype "AUDIO" }
                                { title "Dirty Old Man" }
                                { performer "Faithless" }
                                { indices
                                    {
                                        T{ index
                                            { number 1 }
                                            { duration "38:24:00" }
                                        }
                                    }
                                }
                            }
                            T{ track
                                { number 8 }
                                { datatype "AUDIO" }
                                { title "God\"Is a DJ" }
                                { performer "Faithless" }
                                { indices
                                    {
                                        T{ index
                                            { number 1 }
                                            { duration "42:35:00" }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        { remarks { "GENRE \"Electronica\"" "DATE \"1998\"" } }
        { performer "Faithless" }
        { title "Live in Berlin" }
    }
} [
    "
     REM GENRE \"Electronica\"
     REM DATE \"1998\"
     PERFORMER \"Faithless\"
     TITLE \"Live in Berlin\"
     FILE \"Faithless - Live in Berlin.mp3\" MP3
       TRACK 01 AUDIO
         TITLE \"Reverence\"
         PERFORMER \"Faithless\"
         INDEX 01 00:00:00
       TRACK 02 AUDIO
         TITLE \"She's My Baby\"
         PERFORMER \"Faithless\"
         INDEX 01 06:42:00
       TRACK 03 AUDIO
         TITLE \"Take the Long Way Home\"
         PERFORMER \"Faithless\"
         INDEX 01 10:54:00
       TRACK 04 AUDIO
         TITLE \"Insomnia\"
         PERFORMER \"Faithless\"
         INDEX 01 17:04:00
       TRACK 05 AUDIO
         TITLE \"Bring the Family Back\"
         PERFORMER \"Faithless\"
         INDEX 01 25:44:00
       TRACK 06 AUDIO
         TITLE \"Salva Mea\"
         PERFORMER \"Faithless\"
         INDEX 01 30:50:00
       TRACK 07 AUDIO
         TITLE \"Dirty Old Man\"
         PERFORMER \"Faithless\"
         INDEX 01 38:24:00
       TRACK 08 AUDIO
         TITLE \"God\"Is a DJ\"
         PERFORMER \"Faithless\"
         INDEX 01 42:35:00
    " string>cuesheet
] unit-test
