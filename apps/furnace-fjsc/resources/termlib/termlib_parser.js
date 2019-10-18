/*
  termlib_parser.js  v.1.0
  command line parser for termlib.js
  (c) Norbert Landsteiner 2005
  mass:werk - media environments
  <http://www.masswerk.at>

  you are free to use this parser under the "termlib.js" license.

  usage:  call "parseLine(this)" from your Terminal handler
          parsed args in this.argv
          quoting levels per arg in this.argQL (value: quote char)
          this.argc: pointer to this.argv and this.argQL (used by parserGetopt)
          call parseretopt(this, "<options>") from your handler to get opts
          (returns an object with properties for every option flag. any float
          values are stored in Object.<flag>.value; illegal opts in array
          Object.illegals)

  configuration: you may want to overide the follow objects (or add properties):
          parserWhiteSpace: chars to be parsed as whitespace
          parserQuoteChars: chars to be parsed as quotes
          parserSingleEscapes: chars to escape a quote or escape expression
          parserOptionChars: chars that start an option
          parserEscapeExpressions: chars that start escape expressions
*/

// chars to be parsed as white space
var parserWhiteSpace = {
	' ': true,
	'\t': true
}

// chars to be parsed as quotes
var parserQuoteChars = {
	'"': true,
	"'": true,
	'`': true
};

// chars to be parsed as escape char
var parserSingleEscapes = {
	'\\': true
};

// chars that mark the start of an option-expression
// for use with parserGetopt
var parserOptionChars = {
	'-': true
}

// chars that start escape expressions (value = handler)
// plugin handlers for ascii escapes or variable substitution
var parserEscapeExpressions = {
	'%': parserHexExpression
}

function parserHexExpression(termref, pointer, echar, quotelevel) {
	/* example for parserEscapeExpressions
	   params:
	     termref: ref to Terminal instance
	     pointer: position in termref.lineBuffer (echar)
	     echar:   escape character found
	     quotelevel: current quoting level (quote char or empty)
	   char under pointer will be ignored
	   the return value is added to the current argument
	*/
	// convert hex values to chars (e.g. %20 => <SPACE>)
	if (termref.lineBuffer.length > pointer+2) {
		// get next 2 chars
		var hi = termref.lineBuffer.charAt(pointer+1);
		var lo = termref.lineBuffer.charAt(pointer+2);
		lo = lo.toUpperCase();
		hi = hi.toUpperCase();
		// check for valid hex digits
		if ((((hi>='0') && (hi<='9')) || ((hi>='A') && ((hi<='F')))) &&
		    (((lo>='0') && (lo<='9')) || ((lo>='A') && ((lo<='F'))))) {
			// next 2 chars are valid hex, so strip them from lineBuffer
			parserEscExprStrip(termref, pointer+1, pointer+3);
			// and return the char
			return String.fromCharCode(parseInt(hi+lo, 16));
		}
	}
	// if not handled return the escape character (=> no conversion)
	return echar;
}

function parserEscExprStrip(termref, from, to) {
	// strip characters from termref.lineBuffer (for use with escape expressions)
	termref.lineBuffer =
		termref.lineBuffer.substring(0, from) +
		termref.lineBuffer.substring(to);
}

function parserGetopt(termref, optsstring) {
    // scans argv form current position of argc for opts
    // arguments in argv must not be quoted
	// returns an object with a property for every option flag found
	// option values (absolute floats) are stored in Object.<opt>.value (default -1)
	// the property "illegals" contains an array of  all flags found but not in optstring
	// argc is set to first argument that is not an option
	var opts = { 'illegals':[] };
	while ((termref.argc < termref.argv.length) && (termref.argQL[termref.argc]==''))  {
		var a = termref.argv[termref.argc];
		if ((a.length>0) && (parserOptionChars[a.charAt(0)])) {
			var i = 1;
			while (i<a.length) {
				var c=a.charAt(i);
				var v = '';
				while (i<a.length-1) {
					var nc=a.charAt(i+1);
					if ((nc=='.') || ((nc>='0') && (nc<='9'))) {
						v += nc;
						i++;
					}
					else break;
				}
				if (optsstring.indexOf(c)>=0) {
					opts[c] = (v == '')? {value:-1} : (isNaN(v))? {value:0} : {value:parseFloat(v)};
				}
				else {
					opts.illegals[opts.illegals.length]=c;
				}
				i++;
			}
			termref.argc++;
		}
		else break;
	}
	return opts;
}

function parseLine(termref) {
	// stand-alone parser, takes a Terminal instance as argument
	// parses the command line and stores results as instance properties
	//   argv:  list of parsed arguments
	//   argQL: argument's quoting level (<empty> or quote character)
	//   argc:  cursur for argv, set initinally to zero (0)
	// open quote strings are not an error but automatically closed.
	var argv = [''];     // arguments vector
	var argQL = [''];    // quoting level
	var argc = 0;        // arguments cursor
	var escape = false ; // escape flag
	for (var i=0; i<termref.lineBuffer.length; i++) {
		var ch= termref.lineBuffer.charAt(i);
		if (escape) {
			argv[argc] += ch;
			escape = false;
		}
		else if (parserEscapeExpressions[ch]) {
			var v = parserEscapeExpressions[ch](termref, i, ch, argQL[argc]);
			if (typeof v != 'undefined') argv[argc] += v;
		}
		else if (parserQuoteChars[ch]) {
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
		else if (parserWhiteSpace[ch]) {
			if (argQL[argc]) {
				argv[argc] += ch;
			}
			else if (argv[argc] != '') {
				argc++;
				argv[argc] = argQL[argc] = '';
			}
		}
		else if (parserSingleEscapes[ch]) {
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
	termref.argv = argv;
	termref.argQL = argQL;
	termref.argc = 0;
}

// eof