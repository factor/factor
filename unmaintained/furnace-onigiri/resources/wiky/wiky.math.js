/*	This work is licensed under Creative Commons GNU LGPL License.

	License: http://creativecommons.org/licenses/LGPL/2.1/

	Author:  Stefan Goessner/2005-06
	Web:     http://goessner.net/ 
   inspired by: http://xml-maiden.com/
*/
Wiky.rules.math = {
   version: 0.95,
   preshortcuts: [
//      { rex:/[ ]/g, tmplt:"`"},   // omit due to charset support ie6
      { rex:/\+\-/g, tmplt:"&#177;"},
      { rex:/\/O|\\Oslash/g, tmplt:"&#216;"},
      { rex:/\/o|\\oslash/g, tmplt:"&#248;"},
      { rex:/<->|\\harr/g, tmplt:"&#8596;"},
      { rex:/<-|\\larr/g, tmplt:"&#8592;"},
      { rex:/->|\\rarr/g, tmplt:"&#8594;"},
      { rex:/<=>|\\hArr/g, tmplt:"&#8660;"},
      { rex:/=>|\\rArr/g, tmplt:"&#8658;"},
      { rex:/-=|\\equiv/g, tmplt:"&#8801;"},
      { rex:/<=|\\le/g, tmplt:"&#8804;"},
      { rex:/>=|\\ge/g, tmplt:"&#8805;"},
      { rex:/</g, tmplt:"&lt;"},
      { rex:/>/g, tmplt:"&gt;"}
   ],
   postshortcuts: [
      { rex:/\*|\\middot/g, tmplt:"&#183;"},
      { rex:/\\x|\\times/g, tmplt:"&#215;"},
      { rex:/~=|\\cong/g, tmplt:"&#8773;"},
      { rex:/~~|\\asymp/g, tmplt:"&#8776;"},
      { rex:/~|\\sim/g, tmplt:"&#8764;"},
      { rex:/!=|\\neq|\\ne/g, tmplt:"&#8800;"},
      { rex:/\.\.\.|\\ldots/g, tmplt:"&#8230;"},
      { rex:/\\in|\\isin/g, tmplt:"&#8712;"},
      { rex:/([0-9])x([0-9])/g, tmplt:"$1&#215;$2"}, 
      { rex:/([A-Za-z]) x ([A-Za-z])/g, tmplt:"$1&#215;$2"},
//      { rex:/[`]{4}/g, tmplt:"&#8195;"},  // omit due to charset support ie6
//      { rex:/[`]{3}/g, tmplt:"&#8194;"},
//      { rex:/[`]{2}/g, tmplt:"  "},
//      { rex:/[`]/g, tmplt:"&#8201;"},
      { rex:/\{/g, tmplt:"&#8206;"},  // unvisible left-to-right mark,
      { rex:/\}/g, tmplt:"&#8207;"}   // unvisible right-to-left mark,
   ],
   expr: [
      { rex:/\^\^/g, tmplt:"^&#94;"},  // ^ overindex
      { rex:/(\\sum|\\prod|\\int)_([-]?[a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})\^([-]?[a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})/g, tmplt:"<span class=\"o\"><span class=\"x\">$3</span>$1<span class=\"x\">$2</span></span>"}, // over-/underscript (\sum, \prod, \int)
      { rex:/(\\sum|\\prod|\\int)\^([-]?[a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})/g, tmplt:"<span class=\"o\"><span class=\"x\">$2</span>$1<span>&#160;</span></span>"},
      { rex:/(\\sum|\\prod|\\int)_([-]?[a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})/g, tmplt:"<span class=\"o\"><span>&#160;</span>$1<span class=\"x\">$2</span></span>"},
      { rex:/_([-]?[a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})\^([-]?[a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})/g, tmplt:"<span class=\"s\"><span class=\"i\">$2</span><span class=\"i\">$1</span></span>"}, // over-/underindex
      { rex:/\^([-]?[a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})/g, tmplt:"<sup class=\"i\">$1</sup>"}, // overindex
      { rex:/_([-]?[a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})/g, tmplt:"<sub class=\"i\">$1</sub>"}, // underindex
      { rex:/-/g, tmplt:"&#8722;"},
      { rex:/([a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})\/([a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})/g, tmplt:"<span class=\"f\"><span class=\"n\">$1</span><span class=\"d\">$2</span></span>"},  // fraction
      { rex:/([a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})\/\/([a-zA-Z0-9\.&;#\\]+|\{@[0-9]+@\})/g, tmplt:"<sup>$1</sup>&#8260;<sub>$2</sub>"}, // fraction 
      { rex:/\[((\[(([^,\]]+[,]){1,}[^\]]+)\][ \n]*){1,})\]/g, tmplt:function($0,$1){var m=Wiky.math.transpose($1.replace(/(^\[|\]$)/g,"").replace(/(\][ \n]*\[)/g,"|").split("|")),sz=" style=\"font-size:"+(m.len)+"00%;\"";/*alert("{("+m.mat.join(")}\n{(").split(",").join(")(")+")}");*/ return "<span class=\"lb\""+sz+">"+Wiky.math.fence()+"</span><span class=\"m\"><span class=\"e\">"+m.mat.join("</span></span>\n<span class=\"m\"><span class=\"e\">").split(",").join("</span><span class=\"e\">")+"</span></span><span class=\"rb\""+sz+">"+Wiky.math.fence()+"</span>";}}, // matrix
      { rex:/\[((?:[^,\]]){1,}[^\]]+)\]/g, tmplt:function($0,$1){var v=$1.split(","),sz=" style=\"font-size:"+v.length+"00%;\""; return "<span class=\"lb\""+sz+">"+Wiky.math.fence()+"</span><span class=\"v\"><span class=\"e\">"+v.join("</span><span class=\"e\">")+"</span></span><span class=\"rb\""+sz+">"+Wiky.math.fence()+"</span>";}}, // vector
      { rex:/!([a-zA-Z0-9\.&;]+)/g, tmplt:"<span class=\"b\">$1</span>" }, // bold vector symbol ..
      { rex:/\\prod/g, tmplt:"<span class=\"h\">&#8719;</span>"},
      { rex:/\\sum/g, tmplt:"<span class=\"h\">&#8721;</span>"},
      { rex:/\\int/g, tmplt:"<span class=\"h\">&#8747;</span>"},
      "Wiky.rules.math.postshortcuts"
   ],
   symbols: [
      { rex:/\\Alpha/g, tmplt:"&#913;"},
      { rex:/\\Beta/g, tmplt:"&#914;"},
      { rex:/\\Gamma/g, tmplt:"&#915;"},
      { rex:/\\Delta/g, tmplt:"&#916;"},
      { rex:/\\Epsilon/g, tmplt:"&#917;"},
      { rex:/\\Zeta/g, tmplt:"&#918;"},
      { rex:/\\Eta/g, tmplt:"&#919;"},
      { rex:/\\Theta/g, tmplt:"&#920;"},
      { rex:/\\Iota/g, tmplt:"&#921;"},
      { rex:/\\Kappa/g, tmplt:"&#922;"},
      { rex:/\\Lambda/g, tmplt:"&#923;"},
      { rex:/\\Mu/g, tmplt:"&#924;"},
      { rex:/\\Nu/g, tmplt:"&#925;"},
      { rex:/\\Xi/g, tmplt:"&#926;"},
      { rex:/\\Omicron/g, tmplt:"&#927;"},
      { rex:/\\Pi/g, tmplt:"&#928;"},
      { rex:/\\Rho/g, tmplt:"&#929;"},
      { rex:/\\Sigma/g, tmplt:"&#931;"},
      { rex:/\\Tau/g, tmplt:"&#932;"},
      { rex:/\\Upsilon/g, tmplt:"&#933;"},
      { rex:/\\Phi/g, tmplt:"&#934;"},
      { rex:/\\Chi/g, tmplt:"&#935;"},
      { rex:/\\Psi/g, tmplt:"&#936;"},
      { rex:/\\Omega/g, tmplt:"&#937;"},
      { rex:/\\alpha/g, tmplt:"&#945;"},
      { rex:/\\beta/g, tmplt:"&#946;"},
      { rex:/\\gamma/g, tmplt:"&#947;"},
      { rex:/\\delta/g, tmplt:"&#948;"},
      { rex:/\\epsilon/g, tmplt:"&#949;"},
      { rex:/\\zeta/g, tmplt:"&#950;"},
      { rex:/\\eta/g, tmplt:"&#951;"},
      { rex:/\\thetasym/g, tmplt:"&#977;"},
      { rex:/\\theta/g, tmplt:"&#952;"},
      { rex:/\\iota/g, tmplt:"&#953;"},
      { rex:/\\kappa/g, tmplt:"&#954;"},
      { rex:/\\lambda/g, tmplt:"&#955;"},
      { rex:/\\mu/g, tmplt:"&#956;"},
      { rex:/\\nu/g, tmplt:"&#957;"},
      { rex:/\\xi/g, tmplt:"&#958;"},
      { rex:/\\omicron/g, tmplt:"&#959;"},
      { rex:/\\piv/g, tmplt:"&#982;"},
      { rex:/\\pi/g, tmplt:"&#960;"},
      { rex:/\\rho/g, tmplt:"&#961;"},
      { rex:/\\sigmaf/g, tmplt:"&#962;"},
      { rex:/\\sigma/g, tmplt:"&#963;"},
      { rex:/\\tau/g, tmplt:"&#964;"},
      { rex:/\\upsilon/g, tmplt:"&#965;"},
      { rex:/\\phi/g, tmplt:"&#966;"},
      { rex:/\\chi/g, tmplt:"&#967;"},
      { rex:/\\psi/g, tmplt:"&#968;"},
      { rex:/\\omega/g, tmplt:"&#969;"},
      { rex:/\\upsih/g, tmplt:"&#978;"},
      // miscellaneous symbols
      { rex:/\\bull/g, tmplt:"&#8226;"},
      { rex:/\\uarr/g, tmplt:"&#8593;"},
      { rex:/\\darr/g, tmplt:"&#8595;"},
      { rex:/\\crarr/g, tmplt:"&#8629;"},
      { rex:/\\lArr/g, tmplt:"&#8656;"},
      { rex:/\\uArr/g, tmplt:"&#8657;"},
      { rex:/\\dArr/g, tmplt:"&#8659;"},
      { rex:/\\forall/g, tmplt:"&#8704;"},
      { rex:/\\part/g, tmplt:"&#8706;"},
      { rex:/\\exist/g, tmplt:"&#8707;"},
      { rex:/\\empty/g, tmplt:"&#8709;"},
      { rex:/\\nabla/g, tmplt:"&#8711;"},
      { rex:/\\notin/g, tmplt:"&#8713;"},
      { rex:/\\ni/g, tmplt:"&#8715;"},
      { rex:/\\minus/g, tmplt:"&#8722;"},
      { rex:/\\lowast/g, tmplt:"&#8727;"},
      { rex:/\\sqrt|\\radic/g, tmplt:"&#8730;"},
      { rex:/\\prop/g, tmplt:"&#8733;"},
      { rex:/\\infin/g, tmplt:"&#8734;"},
      { rex:/\\ang/g, tmplt:"&#8736;"},
      { rex:/\\and/g, tmplt:"&#8743;"},
      { rex:/\\or/g, tmplt:"&#8744;"},
      { rex:/\\cap/g, tmplt:"&#8745;"},
      { rex:/\\cup/g, tmplt:"&#8746;"},
      { rex:/\\there4/g, tmplt:"&#8756;"},
      { rex:/\\sub/g, tmplt:"&#8834;"},
      { rex:/\\sup/g, tmplt:"&#8835;"},
      { rex:/\\nsub/g, tmplt:"&#8836;"},
      { rex:/\\sube/g, tmplt:"&#8838;"},
      { rex:/\\supe/g, tmplt:"&#8839;"},
      { rex:/\\oplus/g, tmplt:"&#8853;"},
      { rex:/\\otimes/g, tmplt:"&#8855;"},
      { rex:/\\perp/g, tmplt:"&#8869;"},
      { rex:/\\sdot/g, tmplt:"&#8901;"}
   ]
};

Wiky.inverse.math = {
   pre: [
      { rex:/&#8722;|\u2212/g, tmplt:"-"},
      { rex:/&#8201;|\u2009/g, tmplt:"&#8201;"},
      { rex:/&#8206;|\u200E/g, tmplt:"{"},
      { rex:/&#8207;|\u200F/g, tmplt:"}"}
   ],
   post: [
//      { rex:/([$])/g, tmplt:"\\$1" },
      { rex:/&#94;|\x5E/g, tmplt:"^"},
      { rex:/&lt;/g, tmplt:"<"},
      { rex:/&gt;/g, tmplt:">"}
   ],
   shortcuts: [
//      { rex:/&#8195;|\u2003/g, tmplt:"    "}, // omit due to charset support ie6
//      { rex:/&#8194;|\u2002/g, tmplt:"   "},
//      { rex:/&#8201;|\u2009/g, tmplt:" "},
      { rex:/&#177;|\xB1/g, tmplt:"+-"},
      { rex:/&#183;|\xB7/g, tmplt:"*"},
      { rex:/&#215;|\xD7/g, tmplt:"\\x"},
      { rex:/&#216;|\xD8/g, tmplt:"/O"},
      { rex:/&#248;|\xF8/g, tmplt:"/o"},
      { rex:/&#8592;|\u2190/g, tmplt:"&lt;-"},
      { rex:/&#8594;|\u2192/g, tmplt:"-&gt;"},
      { rex:/&#8596;|\u2194/g, tmplt:"&lt;-&gt;"},
      { rex:/&#8658;|\u21D2/g, tmplt:"=&gt;"},
      { rex:/&#8660;|\u21D4/g, tmplt:"&lt;=&gt;"},
      { rex:/&#8764;|\u223C/g, tmplt:"~"},
      { rex:/&#8773;|\u2245/g, tmplt:"~="},
      { rex:/&#8776;|\u2248/g, tmplt:"~~"},
      { rex:/&#8800;|\u2260/g, tmplt:"!="},
      { rex:/&#8230;/g, tmplt:"..."},
      { rex:/&#8801;|\u2261/g, tmplt:"-="},
      { rex:/&#8804;|\u2264/g, tmplt:"&lt;="},
      { rex:/&#8805;|\u2265/g, tmplt:"&gt;="}
   ],
   expr: [
      { rex:/<span class=\"s\"><span class=\"i\">(\{?@[0-9]+@\}?)<\/span><span class="i">(\{?@[0-9]+@\}?)<\/span><\/span>/g, tmplt:"_$2^$1"}, // superscript + subscript
      { rex:/<span class=\"o\"><span class=\"x\">(\{?@[0-9]+@\}?)<\/span>(\\prod|\\sum|\\int)<span class=\"x\">(\{?@[0-9]+@\}?)<\/span><\/span>/g, tmplt:"$2_$3^$1"},  // overscript + underscript
      { rex:/<span class=\"o\"><span>@[0-9]+@<\/span>(\\prod|\\sum|\\int)<span class=\"x\">(\{?@[0-9]+@\}?)<\/span><\/span>/mgi, tmplt:"$1_$2", dbg:true},  // underscript
      { rex:/<span class=\"o\"><span class=\"x\">(\{?@[0-9]+@\}?)<\/span>(\\prod|\\sum|\\int)<span>@[0-9]+@<\/span><\/span>/mgi, tmplt:"$2^$1"},  // overscript
      { rex:/<span class=\"f\"><span class=\"n\">(\{?@[0-9]+@\}?)<\/span><span class="d">(\{?@[0-9]+@\}?)<\/span><\/span>/mgi, tmplt:"$1/$2"},  // fraction
      { rex:/<span class=\"lb\"[^>]*>&[^;]+;<\/span><span class=\"v\">((?:<span class=\"e\">[^>]*<\/span>){2,})<\/span><span class=\"rb\"[^>]*>&[^;]+;<\/span>/mgi, tmplt:function($0,$1){return "["+$1.replace(/(?:^<span class=\"e\">|<\/span>$)/g,"").replace(/<\/span><span class=\"e\">/g,",")+"]";}}, // vector ..
      { rex:/<span class=\"lb\"[^>]*>&[^;]+;<\/span>((?:<span class=\"m\">(?:(?:<span class=\"e\">[^>]*<\/span>){2,})<\/span>[^>]*){2,})<span class=\"rb\"[^>]*>&[^;]+;<\/span>/mgi, tmplt:function($0,$1){return "[["+Wiky.math.transpose($1.replace(/(?:^<span class=\"m\"><span class=\"e\">|<\/span><\/span>$)/g,"").replace(/<\/span><span class=\"e\">/g,",").replace(/<\/span><\/span>[^>]*<span class=\"m\"><span class=\"e\">/g,"|").split("|")).mat.join("][")+"]]";}}, // matrix ..
      { rex:/<span class=\"b\">(@[0-9]+@)<\/span>/mgi, tmplt:"!$1"}, // bold vector ..
      { rex:/<sup>(\{?@[0-9]+@\}?)<\/sup>&#8260;<sub>(\{?@[0-9]+@\}?)<\/sub>/mgi, tmplt:"$1//$2"},
      { rex:/<sup class=\"i\">(\{?@[0-9]+@\}?)<\/sup>/mgi, tmplt:"^$1" }, 
      { rex:/<sub class=\"i\">(\{?@[0-9]+@\}?)<\/sub>/mgi, tmplt:"_$1" }
   ],
   symbols: [
      // greek symbols
      { rex:/&#913;|\u391/g, tmplt:"\\Alpha"},
      { rex:/&#914;|\u392/g, tmplt:"\\Beta"},
      { rex:/&#915;|\u393/g, tmplt:"\\Gamma"},
      { rex:/&#916;|\u394/g, tmplt:"\\Delta"},
      { rex:/&#917;|\u395/g, tmplt:"\\Epsilon"},
      { rex:/&#918;|\u396/g, tmplt:"\\Zeta"},
      { rex:/&#919;|\u397/g, tmplt:"\\Eta"},
      { rex:/&#920;|\u398/g, tmplt:"\\Theta"},
      { rex:/&#921;|\u399/g, tmplt:"\\Iota"},
      { rex:/&#922;|\u39A/g, tmplt:"\\Kappa"},
      { rex:/&#923;|\u39B/g, tmplt:"\\Lambda"},
      { rex:/&#924;|\u39C/g, tmplt:"\\Mu"},
      { rex:/&#925;|\u39D/g, tmplt:"\\Nu"},
      { rex:/&#926;|\u39E/g, tmplt:"\\Xi"},
      { rex:/&#927;|\u39F/g, tmplt:"\\Omicron"},
      { rex:/&#928;|\u3A0/g, tmplt:"\\Pi"},
      { rex:/&#929;|\u3A1/g, tmplt:"\\Rho"},
      { rex:/&#931;|\u3A3/g, tmplt:"\\Sigma"},
      { rex:/&#932;|\u3A4/g, tmplt:"\\Tau"},
      { rex:/&#933;|\u3A5/g, tmplt:"\\Upsilon"},
      { rex:/&#934;|\u3A6/g, tmplt:"\\Phi"},
      { rex:/&#935;|\u3A7/g, tmplt:"\\Chi"},
      { rex:/&#936;|\u3A8/g, tmplt:"\\Psi"},
      { rex:/&#937;|\u3A9/g, tmplt:"\\Omega"},
      { rex:/&#945;|\u3B1/g, tmplt:"\\alpha"},
      { rex:/&#946;|\u3B2/g, tmplt:"\\beta"},
      { rex:/&#947;|\u3B3/g, tmplt:"\\gamma"},
      { rex:/&#948;|\u3B4/g, tmplt:"\\delta"},
      { rex:/&#949;|\u3B5/g, tmplt:"\\epsilon"},
      { rex:/&#950;|\u3B6/g, tmplt:"\\zeta"},
      { rex:/&#951;|\u3B7/g, tmplt:"\\eta"},
      { rex:/&#977;|\u3D1/g, tmplt:"\\thetasym"},
      { rex:/&#952;|\u3B8/g, tmplt:"\\theta"},
      { rex:/&#953;|\u3B9/g, tmplt:"\\iota"},
      { rex:/&#954;|\u3BA/g, tmplt:"\\kappa"},
      { rex:/&#955;|\u3BB/g, tmplt:"\\lambda"},
      { rex:/&#956;|\u3BC/g, tmplt:"\\mu"},
      { rex:/&#957;|\u3BD/g, tmplt:"\\nu"},
      { rex:/&#958;|\u3BE/g, tmplt:"\\xi"},
      { rex:/&#959;|\u3BF/g, tmplt:"\\omicron"},
      { rex:/&#960;|\u3C0/g, tmplt:"\\pi"},
      { rex:/&#961;|\u3C1/g, tmplt:"\\rho"},
      { rex:/&#962;|\u3C2/g, tmplt:"\\sigmaf"},
      { rex:/&#963;|\u3C3/g, tmplt:"\\sigma"},
      { rex:/&#964;|\u3C4/g, tmplt:"\\tau"},
      { rex:/&#965;|\u3C5/g, tmplt:"\\upsilon"},
      { rex:/&#966;|\u3C6/g, tmplt:"\\phi"},
      { rex:/&#967;|\u3C7/g, tmplt:"\\chi"},
      { rex:/&#968;|\u3C8/g, tmplt:"\\psi"},
      { rex:/&#969;|\u3C9/g, tmplt:"\\omega"},
      // miscellaneous symbols
      { rex:/&#978;|\u3D2/g, tmplt:"\\upsih"},
      { rex:/&#982;|\u3D6/g, tmplt:"\\piv"},
      { rex:/&#8226;|\u2022/g, tmplt:"\\bull"},
      { rex:/&#8593;|\u2191/g, tmplt:"\\uarr"},
      { rex:/&#8595;|\u2193/g, tmplt:"\\darr"},
      { rex:/&#8629;|\u21B5/g, tmplt:"\\crarr"},
      { rex:/&#8656;|\u21D0/g, tmplt:"\\lArr"},
      { rex:/&#8657;|\u21D1/g, tmplt:"\\uArr"},
      { rex:/&#8659;|\u21D3/g, tmplt:"\\dArr"},
      { rex:/&#8704;|\u2200/g, tmplt:"\\forall"},
      { rex:/&#8706;|\u2202/g, tmplt:"\\part"},
      { rex:/&#8707;|\u2203/g, tmplt:"\\exist"},
      { rex:/&#8709;|\u2205/g, tmplt:"\\empty"},
      { rex:/&#8711;|\u2207/g, tmplt:"\\nabla"},
      { rex:/&#8712;|\u2208/g, tmplt:"\\isin"},
      { rex:/&#8713;|\u2209/g, tmplt:"\\notin"},
      { rex:/&#8715;|\u220B/g, tmplt:"\\ni"},
      { rex:/<span class=\"h\">(&#8719;|\u220F)<\/span>/g, tmplt:"\\prod"},
      { rex:/<span class=\"h\">(&#8721;|\u2211)<\/span>/g, tmplt:"\\sum"},
      { rex:/&#8727;|\u2217/g, tmplt:"\\lowast"},
      { rex:/&#8730;|\u221A/g, tmplt:"\\sqrt"},
      { rex:/&#8733;|\u221D/g, tmplt:"\\prop"},
      { rex:/&#8734;|\u221E/g, tmplt:"\\infin"},
      { rex:/&#8736;|\u2220/g, tmplt:"\\ang"},
      { rex:/&#8743;|\u2227/g, tmplt:"\\and"},
      { rex:/&#8744;|\u2228/g, tmplt:"\\or"},
      { rex:/&#8745;|\u2229/g, tmplt:"\\cap"},
      { rex:/&#8746;|\u222A/g, tmplt:"\\cup"},
      { rex:/<span class=\"h\">(?:&#8747;|\u222B)<\/span>/g, tmplt:"\\int"},
      { rex:/&#8756;|\u2234/g, tmplt:"\\there4"},
      { rex:/&#8834;|\u2282/g, tmplt:"\\sub"},
      { rex:/&#8835;|\u2283/g, tmplt:"\\sup"},
      { rex:/&#8836;|\u2284/g, tmplt:"\\nsub"},
      { rex:/&#8838;|\u2286/g, tmplt:"\\sube"},
      { rex:/&#8839;|\u2287/g, tmplt:"\\supe"},
      { rex:/&#8853;|\u2295/g, tmplt:"\\oplus"},
      { rex:/&#8855;|\u2297/g, tmplt:"\\otimes"},
      { rex:/&#8869;|\u22A5/g, tmplt:"\\perp"},
      { rex:/&#8901;|\u22C5/g, tmplt:"\\sdot"}
   ]
};

Wiky.math = {
   toHtml: function(str) {
      var expr = function(itr) {  // region from "{" to "}", nesting allowed ..
         var s = "";
         for (var c = itr.str.charAt(itr.pos++); itr.pos <= itr.str.length && c != "}"; c = itr.str.charAt(itr.pos++))
            s += (c == "{") ? ("{"+expr(itr)+"}") : c;
         return Wiky.store(Wiky.apply(s, Wiky.rules.math.expr));
      };
      str = Wiky.apply(str, Wiky.rules.math.preshortcuts);
      str = Wiky.apply(str, Wiky.rules.math.symbols);
      str = expr({str:str,pos:0});
      return str;
   },
   toWiki: function(str) {
      var parseTree = function(itr, endtag) {
         var c, s="",gt,nam,idxof=function(s,c,p){var i=s.indexOf(c,p);return i>=0?i:s.length;}
         for (itr.buf=itr.str.substr(itr.pos,endtag.length); 
              itr.pos<itr.str.length && (!endtag || itr.buf!=endtag); 
              itr.buf=itr.str.substr(++itr.pos,endtag.length)) {
            if ((c=itr.str.charAt(itr.pos))=="<" && (gt=idxof(itr.str,">",itr.pos)) < idxof(itr.str,"/",itr.pos)) { // start tags .. no empty elements or endtags ..
               nam = itr.str.substring(itr.pos+1,Math.min(idxof(itr.str," ",itr.pos),gt));
               s += itr.str.substring(itr.pos,itr.pos=gt+1) + parseTree(itr, "</" + nam + ">") + "</" + nam + ">";
               itr.pos += nam.length+3;
            }
            else
               s += c;
         }
         itr.pos--;
         return Wiky.store(s, true);
      };
      str = Wiky.apply(str, Wiky.inverse.math.pre);
      str = Wiky.apply(str, Wiky.inverse.math.symbols);
      str = parseTree({str:str,pos:0,buf:null}, "");
      while (str.match(/@[0-9]+@/g) != null)
         str = Wiky.apply(str.replace(/@([0-9]+)@/g, function($0,$1){return Wiky.restore($1);}), Wiky.inverse.math.expr);
      str = Wiky.apply(str, Wiky.inverse.math.shortcuts);
      str = Wiky.apply(str, Wiky.inverse.math.post);
      return str;
   },
   fence: function(str) {
      return window && window.ActiveXObject ? "&#160;" : "&#8201;";
   },
   transpose: function (m) {
      var t=[];
      for (var i in m) {
         m[i] = m[i].split(",");
         for (var j in m[i]) {
            if (!t[j]) t[j]=[];
            t[j][i] = m[i][j];
         }
      }
      for (var i in t)
         t[i] = t[i].join(",");
     return {mat:t, len:m.length};
  }
};

Wiky.rules.pre = Wiky.rules.pre.concat({ rex:/\\([$])/g, tmplt:function($0,$1){return Wiky.store($1);} });
Wiky.rules.nonwikiblocks = Wiky.rules.nonwikiblocks.concat(
[
    { rex:/\[\(([a-zA-Z0-9\.-]+)\)\$([^$]*)\$\]/g, tmplt:function($0,$1,$2){return ":p]<div class=\"eq\"><a name=\"eq"+$1+"\">("+$1+")</a>" + Wiky.math.toHtml($2) + "</div>[p:";} }, // numbered equation
    { rex:/\[\$([^$]*)\$\]/g, tmplt:function($0,$1){return ":p]<div class=\"eq\">" + Wiky.math.toHtml($1) + "</div>[p:";} }, // equation
]);
Wiky.rules.nonwikiinlines = Wiky.rules.nonwikiinlines.concat(
    { rex:/\$([^$]*)\$/g, tmplt:function($0,$1){return "<dfn>" + Wiky.math.toHtml($1) + "</dfn>";} } // inline equation
);

Wiky.inverse.pre = Wiky.inverse.pre.concat({ rex:/([\$])/g, tmplt:"\\$1" });
Wiky.inverse.nonwikiblocks = Wiky.inverse.nonwikiblocks.concat(
[
    { rex:/<div class=\"eq\"><a name=\"eq([0-9]+)\">(?:.*?)<\/a>(.*?)<\/div>/g, tmplt:function($0,$1,$2){return Wiky.store("[("+$1+")$"+Wiky.math.toWiki($2)+"$]");} }, // numbered equation
    { rex:/<div class=\"eq\">(.*?)<\/div>/g, tmplt:function($0,$1){return Wiky.store("[$"+Wiky.math.toWiki($1)+"$]");} }, // equation
]);
Wiky.inverse.nonwikiinlines = Wiky.inverse.nonwikiinlines.concat(
    { rex:/<dfn>(.*?)<\/dfn>/g, tmplt:function($0,$1){return Wiky.store("$"+Wiky.math.toWiki($1)+"$");} } // inline equation
);
