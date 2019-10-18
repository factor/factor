/*	This work is licensed under Creative Commons GNU LGPL License.

	License: http://creativecommons.org/licenses/LGPL/2.1/

	Author:  Stefan Goessner/2005-06
	Web:     http://goessner.net/

   credits: http://www.regular-expressions.info/examplesprogrammer.html
*/
Wiky.rules.lang.js = [
      "Wiky.rules.code",
      { rex:/"([^"\\\xB6]*(\\.[^"\\\xB6]*)*)"/g, tmplt:function($0,$1){return Wiky.store("<span class=\"str\">\""+$1+"\"</span>");}}, // string delimited by '"' with '\"' allowed ..
      { rex:/'([^'\\\xB6]*(\\.[^'\\\xB6]*)*)'/g, tmplt:function($0,$1){return Wiky.store("<span class=\"str\">\'"+$1+"\'</span>");}}, // string delimited by "'" with "\'" allowed ..
      { rex:/\/\/(.*?)(?:\xB6|$)/g, tmplt:function($0,$1){return Wiky.store("<span class\=\"cmt\">//"+$1+"</span>\xB6");}}, // single line comment
      { rex:/\/\*(.*?)\*\//g, tmplt:function($0,$1){return Wiky.store("<span class\=\"cmt\">\/*"+$1+"*\/</span>");}}, // multi-line comment
//       { rex:/([\]\[\-+\|*!%<>=\{\}?:,\)\(]+)|(&#34;|&#47;|&#61;)+/g, tmplt:"<span class=\"op\">$1</span>"}, // operators
      { rex:/\b(break|case|catch|continue|do|else|false|for|function|if|in|new|return|switch|this|throw|true|try|var|while|with)\b/g, tmplt:"<span class=\"kwd\">$1</span>" }, // keywords
      { rex:/\b(arguments|Array|Boolean|Date|Error|Function|Global|Math|Number|Object|RegExp|String)\b/g, tmplt:"<span class=\"obj\">$1</span>" }, // objects
      { rex:/\.(abs|acos|anchor|arguments|asin|atan|atan2|big|blink|bold|callee|caller|ceil|charAt|charCodeAt|concat|constructor|cos|E|escape|eval|exp|fixed|floor|fontcolor|fontsize|fromCharCode|getDate|getDay|getFullYear|getHours|getMilliseconds|getMinutes|getMonth|getSeconds|getTime|getTimezoneOffset|getUTCDate|getUTCDay|getUTCFullYear|getUTCHours|getUTCMilliseconds|getUTCMinutes|getUTCMonth|getUTCSeconds|getVarDate|getYear|index|indexOf|Infinity|input|isFinite|isNaN|italics|join|lastIndex|lastIndexOf|lastMatch|lastParen|leftContext|length|link|LN10|LN2|log|LOG10E|LOG2E|match|max|MAX_VALUE|min|MIN_VALUE|NaN|NaN|NEGATIVE_INFINITY|parse|parseFloat|parseInt|PI|pop|POSITIVE_INFINITY|pow|prototype|push|random|replace|reverse|rightContext|round|search|setDate|setFullYear|setHours|setMilliseconds|setMinutes|setMonth|setSeconds|setTime|setUTCDate|setUTCFullYear|setUTCHours|setUTCMilliseconds|setUTCMinutes|setUTCMonth|setUTCSeconds|setYear|shift|sin|slice|slice|small|sort|splice|split|sqrt|SQRT1_2|SQRT2|strike|sub|substr|substring|sup|tan|toGMTString|toLocaleString|toLowerCase|toString|toUpperCase|toUTCString|unescape|unshift|UTC|valueOf)\b/g, tmplt:".<span class=\"mbr\">$1</span>" }, // members
];
Wiky.rules.lang.xml = [
      { rex:/<script([^>]*)>(.*?)<\/script>/g, tmplt:function($0,$1,$2){return "<script"+$1+">"+Wiky.store(Wiky.apply($2, Wiky.rules.lang.js))+"</script>";} }, // script blocks ..
      { rex:/<!\[CDATA\[(.*?)\]\]>/g, tmplt:function($0,$1){return Wiky.store("&lt;![CDATA["+$1+"]]&gt;");} }, // CDATA sections, ..
      { rex:/<!(.*?)>/g, tmplt:function($0,$1){return Wiky.store("<span class=\"cmt\">&lt;!"+$1+"&gt;</span>");} }, // inline xml comments, doctypes, ..
      { rex:/</g, tmplt:"\xAB"}, // replace '<' by '«'
      { rex:/>/g, tmplt:"\xBB"}, // replace '>' by '»'
      { rex:/([-A-Za-z0-9_:]+)[ ]*=[ ]*\"(.*?)\"/g, tmplt:"<span class=\"xnam\">$1</span>=<span class=\"xval\">&quot;$2&quot;</span>"}, // "xml attribute value strings ..
      { rex:/(\xAB[\/]?)([-A-Za-z0-9_:]+)/g, tmplt:"$1<span class=\"xtag\">$2</span>"}, // "xml tag ..
      { rex:/\xAB/g, tmplt:"&lt;"}, // replace '«' by '<'
      { rex:/\xBB/g, tmplt:"&gt;"}, // replace '»' by '>'
];
Wiky.inverse.lang.js = [
     { rex:/<span class=\"?(cmt|kwd|mbr|obj|str)\"?>|<\/span>/mgi, tmplt:"" },
     { rex:/<strong>(.*?)<\/strong>/mgi, tmplt:"[*$1*]" },
      "Wiky.inverse.code"
];
Wiky.inverse.lang.xml = [
     { rex:/<span class=\"?(cmt|xtag|xnam|xval)\"?>|<\/span>/mgi, tmplt:"" },
     "Wiky.inverse.lang.js"
];
