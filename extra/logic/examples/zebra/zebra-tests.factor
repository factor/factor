! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test logic lists logic.examples.zebra ;

{
    {
        H{
            {
                Hs
                L{
                    T{ house
                       { color yellow }
                       { nationality norwegian }
                       { drink water }
                       { smoke dunhill }
                       { pet cat }
                     }
                    T{ house
                       { color blue }
                       { nationality dane }
                       { drink tea }
                       { smoke blend }
                       { pet horse }
                     }
                    T{ house
                       { color red }
                       { nationality english }
                       { drink milk }
                       { smoke pall-mall }
                       { pet birds }
                     }
                    T{ house
                       { color green }
                       { nationality german }
                       { drink coffee }
                       { smoke prince }
                       { pet zebra }
                     }
                    T{ house
                       { color white }
                       { nationality swede }
                       { drink beer }
                       { smoke blue-master }
                       { pet dog }
                     }
                }
            }
            { X norwegian }
            { Y german }
        }
    }
}
[ { houseso Hs X Y } query ] unit-test
