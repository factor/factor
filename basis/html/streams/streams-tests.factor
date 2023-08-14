USING: html.streams html.streams.private accessors io
io.streams.string io.styles kernel multiline namespaces
tools.test sbufs sequences inspector colors xml.writer
classes.predicate prettyprint ;
IN: html.streams.tests

: make-html-string ( quot -- string )
    [ with-html-writer write-xml ] with-string-writer ; inline

[ [ ] make-html-string ] must-infer

{ "" } [
    [ "" write ] make-html-string
] unit-test

{ "a" } [
    [ CHAR: a write1 ] make-html-string
] unit-test

{ "&lt;" } [
    [ "<" write ] make-html-string
] unit-test

TUPLE: funky town ;

M: funky url-of "http://www.funky-town.com/" swap town>> append ;

{ "<a href=\"http://www.funky-town.com/austin\">&lt;</a>" } [
    [
        "<" "austin" funky boa write-object
    ] make-html-string
] unit-test

{ "<span style=\"font-family: monospace; \">car</span>" }
[
    [
        "car"
        H{ { font-name "monospace" } }
        format
    ] make-html-string
] unit-test

{ "<span style=\"color: #ff00ff; \">car</span>" }
[
    [
        "car"
        H{ { foreground T{ rgba f 1 0 1 1 } } }
        format
    ] make-html-string
] unit-test

{ "<div style=\"background-color: #ff00ff; display: inline-block; \">cdr</div>" }
[
    [
        H{ { page-color T{ rgba f 1 0 1 1 } } }
        [ "cdr" write ] with-nesting
    ] make-html-string
] unit-test

{ "<div style=\"display: inline-block; \"></div><br/>" } [
    [ H{ } [ ] with-nesting nl ] make-html-string
] unit-test

{ [=[
array with 3 elements
<br/>
<table style="display: inline-table; border-collapse: collapse;">
  <tr>
    <td valign="top" style="border: 1px solid #cccccc; padding: 2px; ">
      <div style="display: inline-block; ">
        0
      </div>
    </td>
    <td valign="top" style="border: 1px solid #cccccc; padding: 2px; ">
      <div style="display: inline-block; ">
        1
      </div>
    </td>
  </tr>
  <tr>
    <td valign="top" style="border: 1px solid #cccccc; padding: 2px; ">
      <div style="display: inline-block; ">
        1
      </div>
    </td>
    <td valign="top" style="border: 1px solid #cccccc; padding: 2px; ">
      <div style="display: inline-block; ">
        2
      </div>
    </td>
  </tr>
  <tr>
    <td valign="top" style="border: 1px solid #cccccc; padding: 2px; ">
      <div style="display: inline-block; ">
        2
      </div>
    </td>
    <td valign="top" style="border: 1px solid #cccccc; padding: 2px; ">
      <div style="display: inline-block; ">
        3
      </div>
    </td>
  </tr>
</table>
<br/>]=]
} [ [ { 1 2 3 } describe ] with-html-writer pprint-xml>string ] unit-test
