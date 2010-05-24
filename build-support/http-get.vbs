if WScript.Arguments.Count < 2 then
    WScript.Echo "usage: http-get.vbs source-url dest-file"
    WScript.Quit 1
else
    source_url = WScript.Arguments.Item(0)
    dest_filename = WScript.Arguments.Item(1)

    dim http, source_data
    set http = CreateObject("WinHttp.WinHttpRequest.5.1")
    http.Open "GET", source_url, false
    http.Send

    if http.Status = 200 then
        dim dest_stream
        set dest_stream = CreateObject("ADODB.Stream")

        dest_stream.Type = 1 ' adTypeBinary
        dest_stream.Open
        dest_stream.Write http.ResponseBody
        dest_stream.SaveToFile dest_filename, 2 ' adSaveCreateOverWrite

        set dest_stream = nothing
    else
        WScript.Echo CStr(http.Status) + " " + http.StatusText + " when fetching " + source_url
        WScript.Quit 1
    end if

    set http = nothing
end if
