USING: vocabs.loader ;
IN: vocabs.loader.test.q

! q already exists here, but r must wait for the definition below.
<< { "vocabs.loader.test.q" } "vocabs.loader.test.r" require-when >>

: defined-after-require-when ( -- n ) 42 ;
