USING: destructors io.windows kernel windows.kernel32
windows.winsock ;
IN: detructors.windows

M: windows-io (handle-destructor) ( obj -- )
    destructor-obj CloseHandle drop ;

M: windows-io (socket-destructor) ( obj -- )
    destructor-obj closesocket drop ;


