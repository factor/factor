USING: calendar calendar.windows kernel tools.test
windows.time ;
IN: windows.time.tests

{ t } [ windows-1601 [ timestamp>FILETIME FILETIME>timestamp ] keep = ] unit-test
{ t } [ windows-time [ windows-time>FILETIME FILETIME>windows-time ] keep = ] unit-test
{ t } [ windows-1601 400 years time+ [ timestamp>FILETIME FILETIME>timestamp ] keep = ] unit-test
