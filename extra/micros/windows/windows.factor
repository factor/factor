IN: micros.windows
USING: system kernel windows.time math math.functions ;

! 116444736000000000 is the windowstime epoch offset
! since windowstime starts at 1600 and unix epoch is 1970
M: windows (micros)
  windows-time 116444736000000000 - 10 / truncate ;