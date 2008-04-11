USING: namespaces system ;
IN: openal.backend

HOOK: load-wav-file os ( filename -- format data size frequency )
