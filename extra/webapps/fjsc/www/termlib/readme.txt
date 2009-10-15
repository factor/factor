****  mass:werk termlib.js - JS-WebTerminal Object v1.07  ****

  (c) Norbert Landsteiner 2003-2005
  mass:werk - media environments
  <http://www.masswerk.at>




Contents:

   1  About
   2  Creating a new Terminal Instance
      2.1 Configuration Values
   3  Using the Terminal
      3.1  The Default Handler
      3.2  Input Modes
           3.2.1  Normal Line Input (Command Line Mode)
                  3.2.1.2 Special Keys (ctrlHandler)
           3.2.2  Raw Mode
           3.2.3  Character Mode
      3.3  Other Handlers
           3.3.1  initHandler
           3.3.2  exitHandler
      3.4  Flags for Behaviour Control
   4  Output Methods
           4.1 Terminal.type()
           4.2 Terminal.write()
           4.3 Terminal.typeAt()
           4.4 Terminal.setChar()
           4.5 Terminal.newLine()
           4.6 Terminal.clear()
           4.7 Terminal.statusLine()
           4.8 Terminal.printRowFromString()
           4.9 Terminal.redraw()
   5  Cursor Methods and Editing
           5.1 Terminal.cursorOn()
           5.2 Terminal.cursorOff()
           5.3 Terminal.cursorSet()
           5.4 Terminal.cursorLeft()
           5.5 Terminal.cursorRight()
           5.6 Terminal.backspace()
           5.7 Terminal.fwdDelete()
           5.8 Terminal.isPrintable()
   6  Other Methods of the Terminal Object
           6.1 Terminal.prompt()
           6.2 Terminal.reset()
           6.3 Terminal.open()
           6.4 Terminal.close()
           6.5 Terminal.focus()
           6.6 Terminal.moveTo()
           6.7 Terminal.resizeTo()
           6.8 Terminal.getDimensions()
           6.9 Terminal.rebuild()
   7  Global Static Methods (TermGlobals)
           7.1 TermGlobals.setFocus()
           7.2 TermGlobals.keylock (Global Locking Flag)
           7.3 TermGlobalsText Methods
               7.3.1 TermGlobals.normalize()
               7.3.2 TermGlobals.fillLeft()
               7.3.3 TermGlobals.center()
               7.3.4 TermGlobals.stringReplace()
   8  Localization
   9  Cross Browser Functions
  10  Architecture, Internals
      10.1  Global Entities
      10.2  I/O Architecture
      10.3  Compatibility
  11  History
  12  Example for a Command Line Parser
  13  License
  14  Disclaimer
  15  References




1  About

The Terminal library "termlib.js" provides an object oriented constructor and control
methods for a terminal-like DHTML interface.

"termlib.js" features direct keyboard input and powerful output methods for multiple
instances of the `Terminal' object (including focus control).

The library was written with the aim of simple usage and a maximum of compatibility with
minimal foot print in the global namespace.


A simple example:

  // creating a terminal and using it

  var term = new Terminal( {handler: termHandler} );
  term.open();

  function termHandler() {
    var line = this.lineBuffer;
    this.newLine();
    if (line == "help") {
      this.write(helpPage)
    }
    else if (line == "exit") {
      this.close();
      return;
    }
    else if (line != "") {
      this.write("You typed: "+line);
    }
    this.prompt();
  }

  var helpPage = [
    "This is the monstrous help page for my groovy terminal.",
    "Commands available:",
    "   help ... print this monstrous help page",
    "   exit ... leave this groovy terminal",
    " ",
    "Have fun!"
  ];


You should provide CSS font definitions for the classes ".term" (normal video) and
".termReverse" (reverse video) in a monospaced font.
A sample stylesheet "term_styles.css" comes with this library.

See the sample application "multiterm_test.html" for a demo of multiple terminals.

v.1.01: If you configure to use another font class (see 2.1 Configuration Values),
        you must provide a subclass ".termReverse" for reversed video.

        p.e.: .myFontClass .termReverse {
                /* your definitions for reverse video here */
              }
        
        With the addition of `conf.fontClass' you can now create multiple
        instances with independend appearences.




2   Creating a new Terminal Instance

Use the `new' constructor to create a new instance of the Terminal object. You will want
to supply a configuration object as an argument to the constructor. If the `new'
constructor is called without an object as its first argument, default values are used.

p.e.:

  // creating a new instance of Terminal

  var conf= {
    x: 100,
    y: 100,
    cols: 80,
    rows: 24
  }

  var term = new Term(conf);
  term.open();

`Terminal.open()' initializes the terminal and makes it visible to the user.
This is handled in by separate method to allow the re-initilization of instances
previously closed.

NOTE:
The division element (or NS-layer) that holds the terminal must be present when calling
`Terminal.open()'. So you must not call this method from the header of a HTML-document at
compile time.



2.1 Configuration Values

Set any of these values in your configuration object to override:

  
  LABEL                     DEFAULT VALUE    COMMENT
  
  x                                   100    terminal's position x in px
  y                                   100    terminal's position y in px
  divDiv                        'termDiv'    id of terminals CSS division
  bgColor                       '#181818'    background color (HTML hex value)
  frameColor                    '#555555'    frame color (HTML hex value)
  frameWidth                            1    frame border width in px
  fontClass                        'term'    class name of CSS font definition to use
  cols                                 80    number of cols per row
  rows                                 24    number of rows
  rowHeight                            15    a row's line-height in px
  blinkDelay                          500    delay for cursor blinking in milliseconds
  crsrBlinkMode                     false    true for blinking cursor
  crsrBlockMode                      true    true for block-cursor else underscore
  DELisBS                           false    handle <DEL> as <BACKSPACE>
  printTab                           true    handle <TAB> as printable (prints as space)
  printEuro                          true    handle unicode 0x20AC (Euro sign) as printable
  catchCtrlH                         true    handle ^H as <BACKSPACE>
  closeOnESC                         true    close terminal on <ESC>
  historyUnique                     false    prevent consecutive and identical entries in history
  id                                    0    terminal id
  ps                                  '>'    prompt string
  greeting      '%+r Terminal ready. %-r'    string for greeting if no initHandler is used
  handler              termDefaultHandler    reference to handler for command interpretation
  ctrlHandler                        null    reference to handler called on uncatched special keys
  initHandler                        null    reference to handler called at end of init()
  exitHandler                        null    reference to handler called on close()


At least you will want to specify `handler' to implement your own command parser.

Note: While `id' is not used by the Termninal object, it provides an easy way to identify
multiple terminals by the use of "this.id". (e.g.: "if (this.id == 1) startupterm = true;")

p.e.:

  // creating two individual Terminal instances

  var term1 = new Terminal(
    {
      id: 1,
      x: 200,
      y: 10,
      cols: 80,
      rows: 12,
      greeting: "*** This is Terminal 1 ***",
      handler: myTerminalHandler
    }
  );
  term1.open();

  var term2 = new Terminal(
    {
      id: 2,
      x, 200,
      y: 220,
      cols: 80
      rows: 12,
      greeting: "*** This is Terminal 2 ***",
      handler: myTerminalHandler
    }
  );
  term2.open();




3   Using the Terminal

There are 4 different handlers that are called by a Terminal instance to process input and
some flags to control the input mode and behaviour.



3.1 The Default Handler (a simlple example for input handling)

If no handlers are defined in the configuration object, a default handler is called to
handle a line of user input. The default command line handler `termDefaultHandler' just
closes the command line with a new line and echos the input back to the user:

  function termDefaultHandler() {
    this.newLine();
    if (this.lineBuffer != '') {
      this.type('You typed: '+this.lineBuffer);
      this.newLine();
    }
    this.prompt();
  }

First you may note that the instance is refered to as `this'. So you need not worry about
which Terminal instance is calling your handler. As the handler is entered, the terminal
is locked for user input and the cursor is off. The current input is available as a string
value in `this.lineBuffer'.

The method `type(<text>)' just does what it says and types a string at the current cursor
position to the terminal screen.

`newLine()' moves the cursor to a new line.

The method `prompt()' adds a new line if the cursor isn't at the start of a line, outputs
the prompt string (as specified in the configuration), activates the cursor, and unlocks
the terminal for further input. While you're doing normal command line processing, always
call `prompt()' when leaving your handler.

In fact this is all you need to create your own terminal application. Please see at least
the method `write()' for a more powerful output method.

Below we will refer to all methods of the Terminal object as `Terminal.<method>()'.
You can call them as `this.<method>()' in a handler or as methods of your named instance
in other context (e.g.: "myTerminal.close()").

[In technical terms these methods are methods of the Terminal's prototype object, while
the properties are properties of a Termninal instance. Since this doesn't make any
difference to your script, we'll refer to both as `Terminal.<method-or-property>'.]



3.2 Input Modes

3.2.1 Normal Line Input (Command Line Mode)

By default the terminal is in normal input mode. Any printable characters in the range of
ASCII 0x20 - 0xff are echoed to the terminal and may be edited with the use of the cursor
keys and the <BACKSPACE> key.
The cursor keys UP and DOWN let the user browse in the command line history (the list of
all commands issued previously in this Terminal instance).

If the user presses <CR> or <ENTER>, the line is read from the terminal buffer, converted
to a string, and placed in `Terminal.lineBuffer' (-> `this.lineBuffer') for further use.
The terminal is then locked for further input and the specified handler
(`Terminal.handler') is called.


3.2.1.2 Special Keys (ctrlHandler)

If a special character (ASCII<0x20) or an according combination of <CTRL> and a key is
pressed, which is not caught for editing or "enter", and a handler for `ctrlHandler' is
specified, this handler is called.
The ASCII value of the special character is available in `Terminal.inputChar'. Please note
that the terminal is neither locked, nor is the cursor off - all further actions have to
be controlled by `ctrlHandler'. (The tracking of <CTRL>-<key> combinations as "^C" usually
works but cannot be taken for granted.)

A named reference of the special control values in POSIX form (as well as the values of
the cursor keys [LEFT, RIGHT, UP, DOWN]) is available in the `termKey' object.

p.e.:

  // a simple ctrlHandler

  function myCtrlHandler() {
    if (this.inputChar == termKey.ETX) {
      // exit on ^C (^C == ASCII 0x03 == <ETX>)
      this.close();
    }
  }

If no `ctrlHandler' is specified, control keys are ignored (default).


3.2.2 Raw Mode

If the flag `Terminal.rawMode' is set to a value evaluating to `true', no special keys are
tracked but <CR> and <ENTER> (and <ESC>, if the flag `Terminal.closeOnESC' is set).
The input is NOT echoed to the terminal. All printable key values [0x20-0xff] are
transformed to characters and added to `Terminal.lineBuffer' sequentially. The command
line input is NOT added to the history.

This mode is especially suitable for password input.

p.e.:

  // using raw mode for password input

  function myTermHandler() {
    this.newLine();
    // we stored a flag in Terminal.env to track the status
    if (this.env.getpassword) {
      // leave raw mode
      this.rawMode = false;
      if (passwords[this.env.user] == this.lineBuffer) {
        // matched
        this.type('Welcome '+this.env.user);
        this.env.loggedin = true;
      }
      else {
        this.type('Sorry.');
      }
      this.env.getpassword = false;
    }
    else {
      // simple parsing
      var args = this.lineBuffer.split(' ');
      var cmd = args[0];
      if (cmd == 'login') {
        var user = args[1];
        if (!user) {
          this.type('usage: login <username>');
        }
        else {
          this.env.user = user;
          this.env.getpassword = true;
          this.type('password? ');
          // enter raw mode
          this.rawMode = true;
          // leave without prompt so we must unlock first
          this.lock = false;
          return;
        }
      }
      /*
        other actions ...
      */
    }
    this.prompt();
  }

In this example a handler is set up to process the command "login <username>" and ask for
a password for the given user name in raw mode. Note the use of the object `Terminal.env'
which is just an empty object set up at the creation of the Terminal instance. Its only
purpose is to provide an individual namespace for private data to be stored by a Terminal
instance.

NOTE: The flag `Terminal.lock' is used to control the keyboard locking. If we would not
set this to `false' before leaving in raw mode, we would be caught in dead-lock, since no
input could be entered and our handler wouldn't be called again. - A dreadful end of our
terminal session.

NOTE: Raw mode utilizes the property `Terminal.lastLine' to collect the input string.
This is normally emty, when a handler is called. This is not the case if your script left
the input process on a call of ctrlHandler. You should clear `Terminal.lastLine' in such
a case, if you're going to enter raw mode immediatly after this.


3.2.3 Character Mode

If the flag `Terminal.charMode' is set to a value evaluating to `true', the terminal is in
character mode. In this mode the numeric ASCII value of the next key typed is stored in
`Terminal.inputChar'. The input is NOT echoed to the terminal. NO locking or cursor
control is performed and left to the handler.
You can use this mode to implement your editor or a console game.
`Terminal.charMode' takes precedence over `Terminal.rawMode'.

p.e.: 

  // using char mode

  function myTermHandler() {
    // this is the normal handler
    this.newLine();
    // simple parsing
    var args = this.lineBuffer.split(' ');
    var cmd = args[0];
    if (cmd == 'edit') {
      // init the editor
      myEditor(this);
      // redirect the handler to editor
      this.handler = myEditor;
      // leave in char mode
      this.charMode = true;
      // show cursor
      this.cursorOn();
      // don't forget unlocking
      this.lock = false;
      return;
    }
    /*
      other actions ...
    */
    this.prompt();
  }

  function myEditor(initterm) {
    // our dummy editor (featuring modal behaviour)
    if (initterm) {
      // perform initialization tasks
      initterm.clear();
      initterm.write('this is a simple test editor; leave with <ESC> then "q"%n%n');
      initterm.env.mode = '';
      // store a reference of the calling handler
      initterm.env.handler = initterm.handler;
      return;
    }
    // called as handler -> lock first
    this.lock=true;
    // hide cursor
    this.cursorOff();
    var key = this.inputChar;
    if (this.env.mode == 'ctrl') {
      // control mode
      if (key == 113) {
        // "q" => quit
        // leave charMode and reset the handler to normal
        this.charMode = false;
        this.handler = this.env.handler;
        // clear the screen
        this.clear();
        // prompt and return
        this.prompt();
        return;
      }
      else {
        // leave control mode
        this.env.mode = '';
      }
    }
    else {
      // edit mode
      if (key == termKey.ESC) {
        // enter control mode
        // we'd better indicate this in a status line ...
        this.env.mode = 'ctrl';
      }
      else if (key == termKey.LEFT) {
        // cursor left
      }
      else if (key == termKey.RIGHT) {
        // cursor right
      }
      if (key == termKey.UP) {
        // cursor up
      }
      else if (key == termKey.DOWN) {
        // cursor down
      }
      else if (key == termKey.CR) {
        // cr or enter
      }
      else if (key == termKey.BS) {
        // backspace
      }
      else if (key == termKey.DEL) {
        // fwd delete
        // conf.DELisBS is not evaluated in charMode!
      }
      else if (this.isPrintable(key)) {
        // printable char - just type it
        var ch = String.fromCharCode(key);
        this.type(ch);
      }
    }
    // leave unlocked with cursor
    this.lock = false;
    this.cursorOn();
  }


Note the redirecting of the input handler to replace the command line handler by the
editor. The method `Terminal.clear()' clears the terminal.
`Terminal.cursorOn()' and `Terminal.cursorOff()' are used to show and hide the cursor.



3.3 Other Handlers

There are two more handlers that can be specified in the configuration object:


3.3.1 initHandler

`initHandler' is called at the end of the initialization triggered by `Terminal.open()'.
The default action - if no `initHandler' is specified - is:

  // default initilization

  this.write(this.conf.greeting);
  this.newLine();
  this.prompt();

Use `initHandler' to perform your own start up tasks (e.g. show a start up screen). Keep
in mind that you should unlock the terminal and possibly show a cursor to give the
impression of a usable terminal.


3.3.2  exitHandler

`exitHandler' is called by `Terminal.close()' just before hiding the terminal. You can use
this handler to implement any tasks to be performed on exit. Note that this handler is
called even if the terminal is closed on <ESC> outside of your inputHandlers control.

See the file "multiterm_test.html" for an example.



3.4   Overview: Flags for Behaviour Control

These falgs are accessible as `Terminal.<flag>' at runtime. If not stated else, the
initial value may be specified in the configuration object.
The configuration object and its properties are accessible at runtime via `Terminal.conf'.


  NAME                      DEFAULT VALUE    MEANING

  blink_delay                         500    delay for cursor blinking in milliseconds.

  crsrBlinkMode                     false    true for blinking cursor.
                                             if false, cursor is static.
  
  crsrBlockMode                      true    true for block-cursor else underscore.

  DELisBS                           false    handle <DEL> as <BACKSPACE>.

  printTab                           true    handle <TAB> as printable (prints as space)
                                             if false <TAB> is handled as a control character

  printEuro                          true    handle the euro sign as valid input char.
                                             if false char 0x20AC is printed, but not accepted
                                             in the command line

  catchCtrlH                         true    handle ^H as <BACKSPACE>.
                                             if false, ^H must be tracked by a custom
                                             ctrlHandler.

  closeOnESC                         true    close terminal on <ESC>.
                                             if true, <ESC> is not available for ctrHandler.


  historyUnique                     false    unique history entries.
                                             if true, entries that are identical to the last
                                             entry in the user history will not be added.

  charMode                          false    terminal in character mode (tracks next key-code).
                                             (runtime only)
 
  rawMode                           false    terminal in raw mode (no echo, no editing).
                                             (runtime only)


Not exactly a flag but useful:

  ps                                  '>'    prompt string.




4  Output Methods

Please note that any output to the terminal implies an advance of the cursor. This means,
that if your output reaches the last column of your terminal, the cursor is advanced and
a new line is opened automatically. This procedure may include scrolling to make room for
the new line. While this is not of much interest for most purposes, please note that, if
you output a string of length 80 to a 80-columns-terminal, and a new line, and another
string, this will result in an empty line between the two strings.


4.1  Terminal.type( <text> [,<stylevector>] )

Types the string <text> at the current cursor position to the terminal. Long lines are
broken where the last column of the terminal is reached and continued in the next line.
`Terminal.write()' does not support any kind of arbitrary line breaks. (This is just a
basic output routine. See `Terminal.write()' for a more powerful output method.)

A bitvector may be supplied as an optional second argument to represent a style or a
combination of styles. The meanings of the bits set are interpreted as follows:

<stylevector>:

   1 ... reverse    (2 power 0)
   2 ... underline  (2 power 1)
   4 ... italics    (2 power 2)
   8 ... strike     (2 power 3)

So "Terminal.type( 'text', 5 )" types "text" in italics and reverse video.

Note:
There is no bold, for most monospaced fonts (including Courier) tend to render wider in
bold. Since this would bring the terminal's layout out of balance, we just can't use bold
as a style. - Sorry.

The HTML-representation of this styles are defined in "TermGlobals.termStyleOpen" and
"TermGlobals.termStyleClose".


4.2  Terminal.write( <text> [,<usemore>] )

Writes a text with markup to the terminal. If an optional second argument evaluates to
true, a UN*X-style utility like `more' is used to page the text. The text may be supplied
as a single string (with newline character "\n") or as an array of lines. Any other input
is transformed to a string value before output.

4.2.1 Mark-up:

`Terminal.write()' employs a simple mark-up with the following syntax:

<markup>: %([+|-]<style>|n|CS|%)
   
   where "+" and '-' are used to switch on and off a style, where
   
   <style>:
   
      "i" ... italics
      "r" ... reverse
      "s" ... strike
      "u" ... underline
      
      "p" ... reset to plain ("%+p" == "%-p")
    
   styles may be combined and may overlap. (e.g. "This is %+rREVERSE%-r, %+uUNDER%+iSCORE%-u%-i.")
   
   "%n"  represents a new line (in fact "\n" is translated to "%n" before processing)
   
   "%CS" clears the terminal screen
   
   "%%"  represents the percent character ('%')


4.2.2 Buffering:

`Terminal.write()' writes via buffered output to the terminal. This means that the
provided text is rendered to a buffer first and then only the visible parts are transfered
to the terminal display buffers. This avoids scrolling delays for long output.

4.2.3 UseMore Mode:

The buffering of `Terminal.write()' allows for pagewise output, which may be specified by
a second boolean argument. If <usemore> evaluates to `true' and the output exceeds the
range of empty rows on the terminal screen, `Terminal.write()' performs like the UN*X
utility `more'. The next page may be accessed by hitting <SPACE> while <q> terminates
paging and returns with the prompt (-> `Terminal.prompt()').

To use this facillity make sure to return immediatly after calling `Terminal.write()' in
order to allow the more-routine to track the user input.
The terminal is set to "charMode == false" afterwards.

p.e.:

  // using Terminal.write as a pager

  function myTermHandler() {
    this.newLine();
    var args = this.lineBuffer.split(' ');
    var cmd = args[0];
    if (cmd == 'more') {
      var page = args[1];
      if (myPages[page]) {
        // Terminal.write as a pager
        this.write(myPages[page], true);
        return;
      }
      else {
        // Terminal.write for simple output
        this.write('no such page.');
      }
    }
    /*
      other actions ...
    */
    this.prompt();
  }


4.3  Terminal.typeAt( <r>, <c>, <text> [,<stylevector>] )

Output the string <text> at row <r>, col <c>.
For <stylevector> see `Terminal.type()'.
`Terminal.typeAt()' does not move the cursor.


4.4  Terminal.setChar( <charcode>, <r>, <c> [,<stylevector>] )

Output a single character represented by the ASCII value of <charcode> at row <r>, col <c>.
For <stylevector> see `Terminal.type()'.


4.5  Terminal.newLine()

Moves the cursor to the first column of the next line and performs scrolling, if needed.


4.6  Terminal.clear()

Clears the terminal screen. (Returns with cursor off.)


4.7  Terminal.statusLine( <text> [,<stylevector> [,<lineoffset>]] )

All output acts on a logical screen with the origin at row 0 / col 0. While the origin is
fixed, the logical width and height of the terminal are defined by `Terminal.maxCols' and
`Terminal.maxLines'. These are set to the configuration dimensions at initilization and by
`Terminal.reset()', but may be altered at any moment. Please note that there are no bounds
checked, so make sure that `Terminal.maxCols' and `Terminal.maxLines' are less or equal
to the configuration dimensions.

You may want to decrement `Terminal.maxLines' to keep space for a reserved status line.
`Terminal.statusLine( <text>, <style> )' offers a simple way to type a text to the last
line of the screen as defined by the configuration dimensions.

  // using statusLine()

  function myHandler() {
    // ...
    // reserve last line
    this.maxLines = term.conf.rows-1;
    // print to status line in reverse video
    this.statusLine("Status: <none>", 1);
    // ...
  }

For multiple status lines the optional argument <lineoffset> specifies the addressed row,
where 1 is the line closest to the bottom, 2 the second line from the bottom and so on.
(default: 1)


4.8  Terminal.printRowFromString( <r> , <text> [,<stylevector>] )

Outputs the string <text> to row <r> in the style of an optional <stylevector>.
If the string's length exceeds the length of the row  (up to `Terminal.conf.cols'), extra
characteres are ignored, else any extra space is filled with character code 0 (prints as
<SPACE>).
The valid range for <row> is: 0 >= <row> < `Terminal.maxLines'.
`Terminal.printRowFromString()' does not set the cursor.

You could, for example, use this method to output a line of a text editor's buffer.

p.e.:

  // page refresh function of a text editor

  function myEditorRefresh(termref, topline) {
    // termref: reference to Terminal instance
    // topline: index of first line to print
    // lines of text are stored in termref.env.lines
    for (var r=0; r<termref.maxLines; r++) {
      var i = topline + r;
      if (i < termref.env.lines.length) {
        // output stored line
        termref.printRowFromString(r, termref.env.lines[i]);
      }
      else {
        // output <tilde> for empty line
        termref.printRowFromString(r, '~');
      }
    }
    // set cursor to origin
    termref.r = termref.c = 0; // same as termref.cursorSet(0, 0);
  }


4.9  Terminal.redraw( <row> )

Basic function to redraw a terminal row <row> according to screen buffer values.
For hackers only. (e.g.: for a console game, hack screen buffers first and redraw all
changed rows at once.)




5  Cursor Methods and Editing


5.1  Terminal.cursorOn()

Show the cursor.


5.2  Terminal.cursorOff()

Hide the cursor.


5.3  Terminal.cursorSet( <r>, <c> )

Set the cursor position to row <r> column <c>.
`Terminal.cursorSet()' preserves the cursor's active state (on/off).


5.4  Terminal.cursorLeft()

Move the cursor left. (Movement is restricted to the logical input line.)
`Terminal.cursorLeft()' preserves the cursor's active state (on/off).


5.5  Terminal.cursorRight()

Move the cursor right. (Movement is restricted to the logical input line.)
`Terminal.cursorRight()' preserves the cursor's active state (on/off).


5.6  Terminal.backspace()

Delete the character left from the cursor, if the cursor is not in first position of the
logical input line.
`Terminal.backspace()' preserves the cursor's active state (on/off).


5.7  Terminal.fwdDelete()

Delete the character under the cursor.
`Terminal.fwdDelete()' preserves the cursor's active state (on/off).


5.8  Terminal.isPrintable( <key code> [,<unicode page 1 only>] )

Returns `true' if the character represented by <key code> is printable with the current
settings. An optional second argument <unicode page 1 only> limits the range of valid
values to 255 with the exception of the Euro sign, if the flag `Terminal.printEuro' is set.
(This second flag is used for input methods but not for output methods. So you may only
enter portable characters, but you may print others to the terminals screen.)




6  Other Methods of the Terminal Object

6.1  Terminal.prompt()

Performes the following actions:

  * advance the cursor to a new line, if the cursor is not at 1st column
  * type the prompt string (as specified in the configuaration object)
  * show the cursor
  * unlock the terminal

(The value of the prompt string can be accessed and changed in `Terminal.ps'.)


6.2  Terminal.reset()

Resets the terminal to sane values and clears the terminal screen.


6.3  Terminal.open()

Opens the terminal. If this is a fresh instance, the HTML code for the terminal is
generated. On re-entry the terminal's visibility is set to `true'. Initialization tasks
are performed and the optional initHandler called. If no initHandler is specified in the
configuration object, the greeting (configuration or default value) is shown and the user
is prompted for input.

v.1.01: `Terminal.open()' now checks for the existence of the DHTML element as defined in
        `Terminal.conf.termDiv' and returns success.


6.4  Terminal.close()

Closes the terminal and hides its visibility. An optional exitHandler (specified in the
configuration object) is called, and finally the flag `Terminal.closed' is set to true. So
you can check for existing terminal instances as you would check for a `window' object
created by `window.open()'.

p.e.:

  // check for a terminals state
  // let array "term" hold references to terminals

  if (term[n]) {
    if (term[n].closed) {
      // terminal exists and is closed
      // re-enter via "term[n].open()"
    }
    else {
      // terminal exists and is currently open
    }
  }
  else {
    // no such terminal
    // create it via "term[n] = new Terminal()"
  }


6.5  Terminal.focus()

Set the keyboard focus to this instance of Terminal. (As `window.focus()'.)


6.6  Terminal.moveTo( <x>, <y> )

Move the terminal to position <x>/<y> in px.
(As `window.moveTo()', but inside the HTML page.)


6.7  Terminal.resizeTo( <x>, <y> )

Resize the terminal to dimensions <x> cols and <y> rows.
<x> must be at least 4, <y> at least 2.
`Terminal.resizeTo()' resets `Terminal.conf.rows', `Terminal.conf.cols',
`Terminal.maxLines', and `Terminal.maxCols' to <y> and <x>, but leaves the instance' state
else unchanged. Clears the terminal's screen and returns success.

(A bit like `window.resizeTo()', but with rows and cols instead of px.)


6.8  Terminal.getDimensions()

Returns an object with properties "width" and "height" with numeric values for the
terminal's outer dimensions in px. Values are zero (0) if the element is not present or
if the method fails otherwise.


6.9  Terminal.rebuild()

Rebuilds the Terminal object's GUI preserving its state and content.
Use this to change the color theme on the fly.

p.e.:

   // change color settings on the fly
   // here: set bgColor to white and font style to "termWhite"
   // method rebuild() updates the GUI without side effects

   term.conf.bgColor = '#ffffff';
   term.conf.fontClass = 'termWhite';
   term.rebuild();




7   Global Static Methods (TermGlobals)


7.1  TermGlobals.setFocus( <termref> )

Sets the keyboard focus to the instance referenced by <termref>.
The focus is controlled by `TermGlobals.activeTerm' which may be accessed directly.
See also: `Terminal.focus()'


7.2  TermGlobals.keylock (Global Locking Flag)

The global flag `TermGlobals.keylock' allows temporary keyboard locking without any
other change of state. Use this to free the keyboard for any other resources.
(added in v.1.03)


7.3  TermGlobals Text Methods

There is a small set of methods for common terminal related string tasks:


7.3.1  TermGlobals.normalize( <n>, <fieldlength> )

Converts a number to a string, which is filled at its left with zeros ("0") to the total
length of <filedlength>. (e.g.: "TermGlobals.normalize(1, 2)" => "01")


7.3.2  TermGlobals.fillLeft( <value>, <fieldlength> )

Converts a value to a string and fills it to the left with blanks to <fieldlength>.


7.3.3  TermGlobals.center( <text>, <length> )

Adds blanks at the left of the string <text> until the text would be centered at a line
of length <length>. (No blanks are added to the the right.)


7.3.4  TermGlobals.stringReplace( <string1>, <string2>, <text> )

Replaces all occurences of the string <string1> in <text> with <string2>.
This is just a tiny work around for browsers with no support of RegExp.




8   Localization

The strings and key-codes used by the more utility of `Terminal.write()' are the only
properties of "termlib.js" that may need localization. These properties are defined in
`TermGlobals'. You may override them as needed:

PROPERTY                                      STANDARD VALUE                 COMMENT

TermGlobals.lcMorePrompt1                                    ' -- MORE -- '  1st string
TermGlobals.lcMorePromtp1Style                                            1  reverse
TermGlobals.lcMorePrompt2       ' (Type: space to continue, \'q\' to quit)'  appended string
TermGlobals.lcMorePrompt2Style                                            0  plain
TermGlobals.lcMoreKeyAbort                                              113  (key-code: q)
TermGlobals.lcMoreKeyContinue                                            32  (key-code <SPACE>)


As "TermGlobals.lcMorePrompt2" is appended to "TermGlobals.lcMorePrompt1" make sure that
the length of the combined strings does not exceed `Terminal.conf.cols'.




9   Cross Browser Functions

For DHTML rendering some methods - as needed by the Terminal library - are provided.
These may also be accessed for other purposes.


9.1  TermGlobals.writeElement( <element id>, <text> [,<NS4 parent document>] )

Writes <text> to the DHTML element with id/name <element id>. 
<NS4 parent document> is used for NS4 only and specifies an optional reference to a parent
document (default `window.document').

9.2  TermGlobals.setElementXY( <element id>, <x>, <y> )

Sets the DHTML element with id/name <element id> to position <x>/<y>.
For NS4 works only with children of the top document (window.document).


9.3  TermGlobals.setVisible( <element id>, <value> )

If <value> evaluates to `true' show DHTML element with id/name <element id> else hide it.
For NS4 works only with children of the top document (window.document).


9.4  Custom Fixes for Missing String Methods

Although `String.fromCharCode' and `String.prototype.charCodeAt' are defined by ECMA-262-2
specifications, a few number of browsers lack them in their JavaScript implementation. At
compile time custom methods are installed to fix this. Please note that they work only
with ASCII characters and values in the range of [0x20-0xff].


9.5  TermGlobals.setDisplay( <element id>, <value> )

Sets the style.display property of the element with id/name <element id> to the given
<value>. (added with v. 1.06)




10   Architecture, Internals

10.1  Global Entities

The library is designed to leave only a small foot print in the namespace while providing
suitable usability:

  Globals defined in this library:

    Terminal           (Terminal object, `new' constructor and prototype methods)
    TerminalDefaults   (default configuration, static object)
    termDefaultHandler (default command line handler, static function)
    TermGlobals        (common vars and code for all instances, static object and methods)
    termKey            (named mappings for special keys, static object)
    termDomKeyRef      (special key mapping for DOM key constants, static object)


  Globals defined for fixing String methods, if missing
  (String.fromCharCode, String.prototype.charCodeAt):

    termString_keyref, termString_keycoderef, termString_makeKeyref

  
  Required CSS classes for font definitions: ".term", ".termReverse".



10.2  I/O Architecture

The Terminal object renders keyboard input from keyCodes to a line buffer and/or to a
special keyCode buffer. In normal input mode printable input is echoed to the screen
buffers. Special characters like <LEFT>, <RIGHT>, <BACKSPACE> are processed for command
line editing by the internal key-handler `TermGlobals.keyHandler' and act directly on the
screen buffers. On <CR> or <ENTER> the start and end positions of the current line are
evaluated (terminated by ASCII 0x01 at the beginning which separates the prompt from the
user input, and any value less than ASCII 0x20 (<SPACE>) at the right end). Then the
character representation for the buffer values in this range are evaluated and
concatenated to a string stored in `Terminal.lineBuffer'. As this involves some
ASCII-to-String-transformations, the range of valid printable input characters is limited
to the first page of unicode characters (0x0020-0x00ff).

There are two screen buffers for output, one for character codes (ASCII values) and one
for style codes. Style codes represent combination of styles as a bitvector (see
`Terminal.type' for bit values.) The method `Terminal.redraw(<row>)' finally renders the
buffers values to a string of HTML code, which is written to the HTML entity holding the
according terminal row. The character buffer is a 2 dimensional array
`Terminal.charBuf[<row>][<col>]' with ranges for <row> from 0 to less than
`Terminal.conf.rows' and for <col> from 0 to less than `Terminal.conf.cols'. The style
buffer is a 2 dimensional array `Terminal.styleBuf[<row>][<col>]' with according ranges.

So every single character is represented by a ASCII code in `Terminal.charBuf' and a
style-vector in `Terminal.styleBuf'. The range of printable character codes is unlimitted
but should be kept to the first page of unicode characters (0x0020-0x00ff) for
compatibility purpose. (c.f. 8.4)

Keyboard input is first handled on the `KEYDOWN' event by the handler `TermGlobals.keyFix'
to remap the keyCodes of cursor keys to consistent values. (To make them distinctable from
any other possibly printable values, the values of POSIX <IS4> to <IS1> where chosen.)
The mapping of the cursor keys is stored in the properties LEFT, RIGHT, UP, and DOWN of
the global static object `termKey'.

The main keyboard handler `TermGlobals.keyHandler' (invoked on `KEYPRESS' or by
`TermGlobals.keyFix') does some final mapping first. Then the input is evaluated as
controlled by the flags `Terminal.rawMode' and `Terminal.charMode' with precedence of the
latter. In dependancy of the mode defined and the handlers currently defined, the input
either is ignored, or is internally processed for command line editing, or one of the
handlers is called.

In the case of the simultanous presecence of two instances of Terminal, the keyboard focus
is controlled via a reference stored in `TermGlobals.activeTerm'. This reference is also
used to evaluate the `this'-context of the key handlers which are methods of the static
Object `TermGlobals'.

A terminal's screen consists of a HTML-table element residing in the HTML/CSS division
spcified in `Terminal.conf.termDiv'. Any output is handled on a per row bases. The
individual rows are either nested sub-divisions of the main divisions (used for NS4 or
browsers not compatible to the "Gecko" engine) or the indiviual table data elements (<TD>)
of the terminal's inner table (used for browsers employing the "Gecko" engine).
(This implementation was chosen for rendering speed and in order to minimize any screen
flicker.) Any output or change of state in a raw results in the inner HTML contents of a
row's HTML element to be rewritten. Please note that as a result of this a blinking cursor
may cause a flicker in the line containing the cursor's position while displayed by a
browser, which employs the "Gecko" engine.



10.3  Compatibility

Standard web browsers with a JavaScript implementation compliant to ECMA-262 2nd edition
[ECMA262-2] and support for the anonymous array and object constructs and the anonymous
function construct in the form of "myfunc = function(x) {}" (c.f. ECMA-262 3rd edion
[ECMA262-3] for details). This comprises almost all current browsers but Konquerer (khtml)
and versions of Apple Safari for Mac OS 10.0-10.28 (Safari < 1.1) which lack support for
keyboard events.

To provide a maximum of compatibilty the extend of language keywords used was kept to a
minimum and does not exceed the lexical conventions of ECMA-262-2. Especially there is no
use of the `switch' statement or the `RegExp' method of the global object. Also the use of
advanced Array methods like `push', `shift', `splice' was avoided.




11   History

This library evolved from the terminal script "TermApp" ((c) N. Landsteiner 2003) and is
in its current form a down scaled spinn-off of the "JS/UIX" project [JS/UIX] (evolution
"JS/UIX v0.5"). c.f.: <http://www.masswerk.at/jsuix>

v 1.01: added Terminal.prototype.resizeTo(x,y)
        added Terminal.conf.fontClass (=> configureable class name)
        Terminal.prototype.open() now checks for element conf.termDiv in advance
          and returns success.

v 1.02: added support for <TAB> and Euro sign
          Terminal.conf.printTab
          Terminal.conf.printEuro
        and method Terminal.prototype.isPrintable(keycode)
        added support for getopt to sample parser ("parser_sample.html")


v 1.03: added global keyboard locking (TermGlobals.keylock)
        modified Terminal.prototype.redraw for speed (use of locals)


v 1.04: modified the key handler to fix a bug with MSIE5/Mac
        fixed a bug in TermGlobals.setVisible with older MSIE-alike browsers without
        DOM support.
        moved the script of the sample parser to an individual document
        => "termlib_parser.js" (HTML document is "parser_sample.html" as before)

v 1.05: added config flag historyUnique.

v 1.06: fixed CTRl+ALT (Windows alt gr) isn't CTRL any more
        -> better support for international keyboards with MSIE/Win.
        fixed double backspace bug for Safari;
        added TermGlobals.setDisplay for setting style.display props
        termlib.js now outputs lower case html (xhtml compatibility)
        (date: 12'2006)

v 1.07: added method Terminal.rebuild() to rebuild the GUI with new color settings.
        (date: 01'2007)




12  Example for a Command Line Parser

  // parser example, splits command line to args with quoting and escape
  // for use as `Terminal.handler'
  
  function commandHandler() {
    this.newLine();
    var argv = [''];     // arguments vector
    var argQL = [''];    // quoting level
    var argc = 0;        // arguments cursor
    var escape = false ; // escape flag
    for (var i=0; i<this.lineBuffer.length; i++) {
      var ch= this.lineBuffer.charAt(i);
      if (escape) {
        argv[argc] += ch;
        escape = false;
      }
      else if ((ch == '"') || (ch == "'") || (ch == "`")) {
        if (argQL[argc]) {
          if (argQL[argc] == ch) {
            argc ++;
            argv[argc] = argQL[argc] = '';
          }
          else {
            argv[argc] += ch;
          }
        }
        else {
          if (argv[argc] != '') {
            argc ++;
            argv[argc] = '';
            argQL[argc] = ch;
          }
          else {
            argQL[argc] = ch;
          }
        }
      }
      else if ((ch == ' ') || (ch == '\t')) {
        if (argQL[argc]) {
          argv[argc] += ch;
        }
        else if (argv[argc] != '') {
          argc++;
          argv[argc] = argQL[argc] = '';
        }
      }
      else if (ch == '\\') {
        escape = true;
      }
      else {
        argv[argc] += ch;
      }
    }
    if ((argv[argc] == '') && (!argQL[argc])) {
      argv.length--;
      argQL.length--;
    }
    if (argv.length == 0) {
      // no commmand line input
    }
    else if (argQL[0]) {
      // first argument quoted -> error
      this.write("Error: first argument quoted by "+argQL[0]);
    }
    else {
      argc = 0;
      var cmd = argv[argc++];
      /*
        parse commands
        1st argument is argv[argc]
        arguments' quoting levels in argQL[argc] are of (<empty> | ' | " | `)
      */
      if (cmd == 'help') {
        this.write(helpPage);
      }
      else if (cmd == 'clear') {
        this.clear();
      }
      else if (cmd == 'exit') {
        this.close();
        return;
      }
      else {
        // for test purpose just output argv as list
        // assemple a string of style-escaped lines and output it in more-mode
        s='   ARG  QL  VALUE%n';
        for (var i=0; i<argv.length; i++) {
          s += TermGlobals.stringReplace('%', '%%',
                 TermGlobals.fillLeft(i, 6) +
                 TermGlobals.fillLeft((argQL[i])? argQL[i]:'-', 4) +
                 '  "' + argv[i] + '"'
            ) + '%n';
        }
        this.write(s, 1);
        return;
      }
    }
    this.prompt();
  }


The file "parser_sample.html" features a stand-alone parser ("termlib_parser.js") very
much like this. You are free to use it according to the termlib-license (see sect. 13).
It provides configurable values for quotes and esape characters and imports the parsed
argument list into a Terminal instance's namespace. ("parser_sample.html" and
"termlib_parser.js" should accompany this file.)




13   License

This JavaScript-library is free for private and academic use.
Please include a readable copyright statement and a backlink to <http://www.masswerk.at>
in the web page. The library should always be accompanied by the 'readme.txt' and the
sample HTML-documents.

The term "private use" includes any personal or non-commercial use, which is not related
to commercial activites, but excludes intranet, extranet and/or public net applications
that are related to any kind of commercial or profit oriented activity.

For commercial use see <http://www.masswerk.at> for contact information.

Any changes to the library should be commented and be documented in the readme-file.
Any changes must be reflected in the `Terminal.version' string as
"Version.Subversion (compatibility)".




14   Disclaimer

This software is distributed AS IS and in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. The entire risk as to the quality and performance of the product is borne by the
user. No use of the product is authorized hereunder except under this disclaimer.




15   References

[ECMA262-2] "ECMAScript Language Specification" Standard ECMA-262 2nd Edition
            August 1998 (ISO/IEC 16262 - April 1998)

[ECMA262-3] "ECMAScript Language Specification" Standard ECMA-262 3rd Edition Final
            24 March 2000

[JS/UIX]     JS/UIX - JavaScript Uniplexed Interface eXtension
             <http://www.masswerk.at/jsuix>





Norbert Landsteiner / Vienna, August 2005
mass:werk - media environments
<http://www.masswerk.at>
See web site for contact information.
