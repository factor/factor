USING: system ;
IN: openal.alut.backend

HOOK: load-wav-file os ( filename -- format data size frequency )
