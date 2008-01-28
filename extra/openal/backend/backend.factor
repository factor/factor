USING: namespaces ;
IN: openal.backend

SYMBOL: openal-backend
HOOK: load-wav-file openal-backend ( filename -- format data size frequency )

TUPLE: other-openal-backend ;
T{ other-openal-backend } openal-backend set-global
