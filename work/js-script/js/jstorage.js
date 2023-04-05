/**
 * ----------------------------- JSTORAGE -------------------------------------
 * Simple local storage wrapper to save data on the browser side, supporting
 * all major browsers - IE6+, Firefox2+, Safari4+, Chrome4+ and Opera 10.5+
 *
 * Copyright (c) 2010 Andris Reinman, andris.reinman@gmail.com
 * Project homepage: www.jstorage.info
 *
 * Licensed under MIT-style license:
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 
/**
 * USAGE:
 * 
 * jStorage requires Prototype, MooTools or jQuery! If jQuery is used, then
 * jQuery-JSON (http://code.google.com/p/jquery-json/) is also needed.
 * (jQuery-JSON needs to be loaded BEFORE jStorage!)
 * 
 * Methods:
 * 
 * -set(key, value)
 * $.jStorage.set(key, value) -> saves a value
 * 
 * -get(key[, default])
 * value = $.jStorage.get(key [, default]) -> 
 * 		retrieves value if key exists, or default if it doesn't
 * 
 * -deleteKey(key)
 * $.jStorage.deleteKey(key) -> removes a key from the storage
 * 
 * -flush()
 * $.jStorage.flush() -> clears the cache
 * 
 * <value> can be any JSON-able value, including objects and arrays.
 * 
 */

(function($){
	if(!$ || !($.toJSON || Object.toJSON || window.JSON))
		throw new Error("jQuery, MooTools or Prototype needs to be loaded before jStorage!");
	$.jStorage = {
			
			/* Version number */
			version: "0.1.2",
			
			/* This is the object, that holds the cached values */
			_storage: {},
			
			/* Actual browser storage (localStorage or globalStorage['domain']) */
			_storage_service: {jStorage:"{}"},
			
			/* DOM element for older IE versions, holds userData behavior */
			_storage_elm: null,
			
			/* function to encode objects to JSON strings */
			json_encode: $.toJSON || Object.toJSON || (window.JSON && JSON.encode),
			
			/* function to decode objects from JSON strings */
			json_decode: $.evalJSON || (window.JSON && JSON.decode) || function(str){
				return String(str).evalJSON();
			},
			
			////////////////////////// PRIVATE METHODS ////////////////////////
			
			/**
			 * Initialization function. Detects if the browser supports DOM Storage
			 * or userData behavior and behaves accordingly.
			 * @returns undefined
			 */
			_init: function(){
				/* Check if browser supports localStorage */
				if("localStorage" in window){
					this._storage_service = window.localStorage;
				}
				/* Check if browser supports globalStorage */
				else if("globalStorage" in window){
					this._storage_service = window.globalStorage[document.domain]
				}
				/* Check if browser supports userData behavior */
				else{
					this._storage_elm = document.createElement('link')
					if("addBehavior" in this._storage_elm){
						
						/* Use a DOM element to act as userData storage */
						this._storage_elm.style.behavior = 'url(#default#userData)';
						
						/* userData element needs to be inserted into the DOM! */
						document.getElementsByTagName('head')[0].appendChild(this._storage_elm);
						
						this._storage_elm.load("jStorage");
						try{
							var data = this._storage_elm.getAttribute("jStorage")
						}catch(E){var data = "{}"}
						if(data && data.length){
							this._storage_service.jStorage = data;
						}
					}else{
						this._storage_elm = null;
						return;
					}
				}
				/* if jStorage string is retrieved, then decode it */ 
				if("jStorage" in this._storage_service && this._storage_service.jStorage){
					try{
						this._storage = this.json_decode(this._storage_service.jStorage);
					}catch(E){this._storage_service.jStorage = "{}";}
				}else{
					this._storage_service.jStorage = "{}";
				}
			},
			
			/**
			 * This functions provides the "save" mechanism to store the jStorage object
			 * @returns undefined
			 */
			_save:function(){
				if(this._storage_service){
					try{
						this._storage_service.jStorage = this.json_encode(this._storage);
					}catch(E){/* probably cache is full, nothing is saved this way*/}
					// If userData is used as the storage engine, additional
					if(this._storage_elm){
						try{
							this._storage_elm.setAttribute("jStorage",this._storage_service.jStorage)
							this._storage_elm.save("jStorage");
						}catch(E){/* probably cache is full, nothing is saved this way*/}
					}
				}
			},
			
			/**
			 * Function checks if a key is set and is string or numberic
			 */
			_checkKey: function(key){
				if(!key || (typeof key != "string" && typeof key != "number")){
					throw new TypeError('Key name must be string or numeric');
				}
				return true;
			},
			
			////////////////////////// PUBLIC METHODS /////////////////////////
			
			/**
			 * Sets a key's value.
			 * @param {String} key - Key to set. If this value is not set or not
			 * 						a string an exception is raised.
			 * @param value - Value to set. This can be any value that is JSON 
			 * 				 compatible (Numbers, Strings, Objects etc.).
			 * @returns the used value
			 */
			set: function(key, value){
				this._checkKey(key);
				this._storage[key] = value;
				this._save();
				return value;
			},
			/**
			 * Looks up a key in cache
			 * @param {String} key - Key to look up.
			 * @param {mixed} def - Default value to return, if key didn't exist.
			 * @returns the key value, default value or <null>
			 */
			get: function(key, def){
				this._checkKey(key);
				if(key in this._storage)
					return this._storage[key];
				return def?def:null;
			},
			/**
			 * Deletes a key from cache.
			 * @param {String} key - Key to delete.
			 * @returns true if key existed or false if it didn't
			 */
			deleteKey: function(key){
				this._checkKey(key);
				if(key in this._storage){
					delete this._storage[key];
					this._save();
					return true;
				}
				return false;
			},
			/**
			 * Deletes everything in cache.
			 * @returns true
			 */
			flush: function(){
				this._storage = {};
				this._save();
				return true;
			}
		}
	// load saved data from browser
	$.jStorage._init();
})(typeof jQuery != "undefined" && jQuery || $);
