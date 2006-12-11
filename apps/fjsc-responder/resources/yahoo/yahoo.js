/*                                                                                                                                                      
Copyright (c) 2006, Yahoo! Inc. All rights reserved.                                                                                                    
Code licensed under the BSD License:                                                                                                                    
http://developer.yahoo.net/yui/license.txt                                                                                                              
version: 0.10.0                                                                                                                                         
*/ 

/* Copyright (c) 2006 Yahoo! Inc. All rights reserved. */

/**
 * The Yahoo global namespace
 * @constructor
 */
var YAHOO = window.YAHOO || {};

/**
 * Returns the namespace specified and creates it if it doesn't exist
 *
 * YAHOO.namespace("property.package");
 * YAHOO.namespace("YAHOO.property.package");
 *
 * Either of the above would create YAHOO.property, then
 * YAHOO.property.package
 *
 * @param  {String} sNameSpace String representation of the desired 
 *                             namespace
 * @return {Object}            A reference to the namespace object
 */
YAHOO.namespace = function( sNameSpace ) {

    if (!sNameSpace || !sNameSpace.length) {
        return null;
    }

    var levels = sNameSpace.split(".");

    var currentNS = YAHOO;

    // YAHOO is implied, so it is ignored if it is included
    for (var i=(levels[0] == "YAHOO") ? 1 : 0; i<levels.length; ++i) {
        currentNS[levels[i]] = currentNS[levels[i]] || {};
        currentNS = currentNS[levels[i]];
    }

    return currentNS;
};

/**
 * Global log method.
 */
YAHOO.log = function(sMsg,sCategory) {
    if(YAHOO.widget.Logger) {
        YAHOO.widget.Logger.log(null, sMsg, sCategory);
    } else {
        return false;
    }
};

YAHOO.namespace("util");
YAHOO.namespace("widget");
YAHOO.namespace("example");
