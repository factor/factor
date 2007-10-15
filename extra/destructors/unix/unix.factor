USING: destructors io.windows kernel qualified ;
QUALIFIED: unix
IN: detructors.unix

M: unix-io (handle-destructor) ( obj -- )
    destructor-obj close drop ;



