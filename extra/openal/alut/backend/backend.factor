USING: system ;
IN: openal.alut.backend

HOOK: load-wav-file os ( filename -- format data size frequency )
HOOK: init-alut os ( -- )
HOOK: exit-alut os ( -- )
HOOK: load-alut-buffer os ( filename -- buffer )
HOOK: load-wav-buffer os ( filename -- buffer )
