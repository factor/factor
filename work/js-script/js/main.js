function initMain () {
	var generic = JSFACTOR_GENERIC;
	var commandHistory = JSFACTOR_COMMAND_HISTORY;
	var examples = JSFACTOR_EXAMPLES;
	
	var output = {
		'clear': clearResult,
		'append': showResult,
		'refresh': refresh
	};
	
	var interpreter = initializeInterpreter(output);
	interpreter.setSelf(interpreter); //FIXME hack
	
	function escapeHTML (string) {
		var div = document.createElement('div');
		var text = document.createTextNode(string);
		div.appendChild(text);
		return div.innerHTML;
  }
	
	function clearResult() {
		$('#result').val('');
	}
	
	function showResult(value) {
		$('#result').val($('#result').val() + value + "\n");
	}
	
	function refreshResultScrollbar() {
		$('#result').attr('scrollTop', 99999);
	}
	
	function appendToStack(value) {
		$('#stack').prepend('<div>'+ value + '</div>');
	}
	
	function clearStack() {
		$('#stack').html('');
	}

	function appendToWords(name, definition) {
		$('#words').prepend(
		'<div class="customword">' +
		  '<div class="remove">x</div>' +
		  '<div class="word_name">' + escapeHTML(name) + '</div>' +
		  '<div class="word_definition">' + escapeHTML(definition) + '</div>' +
		'</div>');
	}

	function clearWords() {
		$('#words').html('');
	}

	function appendToNativeWords(categoryElem, name, stack_effect, description) {
		var result = 
			'<div class="nativeword" style="display: none;">'+
			  '<div class="stack_effect">' +
			    escapeHTML(stack_effect) +
			  '</div>' +
			  '<div class="description">' +
			    description +
			  '</div>' +			  
			  '<div class="wordname">' +
			    escapeHTML(name) +
			  '</div>' +
			'</div>';
			
			if(categoryElem !== undefined) {
			  categoryElem.append(result);
			} else {
				//throw 'word category undefined for '+ name;
			}
	}

	function clearNativeWords() {
		$('#nativewords').html('');
	}
	
	function appendCategory(categoryName, description) {
		var html = 
			'<div class="word_category">' + 
			  '<div class="categoryname">' +
			    categoryName +
			  '</div>' +
			  '<div class="categorydescription">' +
			    description +
			  '</div>' +
			'</div>';
		return  $('#nativewords').append(html).find('.word_category:last');
	}


	function findCategoryElem(wordName, categoryData, categories) {
		for(var category in categories) {
			var cArray = categories[category].operations;

			for(var w = 0; w < cArray.length; ++w) {
				var wName = cArray[w];
				if(wordName === wName) return categoryData[category];
			}
		}
	}
	
	function print_native_words() {
		clearNativeWords();
		
		var categories = interpreter.categories();
		var categoryData = {}
		
		for(var category in categories) {
			var elem = appendCategory(category, categories[category].description);
			categoryData[category] = elem;
		}
		
		var words = interpreter.native_words();

		for(var w in words) {
			var categoryElem = findCategoryElem(w, categoryData, categories);
			appendToNativeWords(categoryElem, w, words[w].stack_effect, words[w].description);
		}

		$('.nativeword:odd').addClass('oddRow');
		$('.nativeword:even').addClass('evenRow');
		
		$('.word_category:first').click();
	}

	function getCustomWordDefinitionsAsString() {
		var result = "";
		
		$('.customword').each(function() {
				var name = $(this).find('.word_name').text();
				var definition = $(this).find('.word_definition').text();
				result += ": " + name + " " + definition + " ;";
				result += " ";
		});
		
		return $.trim(result);
	}

	function bindGetCustomWordDefinitions() {	
		$('.all_custom_words').click(function() {
			appendToCommand(getCustomWordDefinitionsAsString());
		});
	}
	
	function refresh() {
		function showStackReversed() {
			$('#stack').prepend('<div id="filler"></div>');
			$('#stack > div:odd').addClass('stack_row_odd');
			$('#stack > div:even').addClass('stack_row_even');
			$('#filler').css('height', 400 - (25+2 /*margin*/) * ($('#stack > div').length - 1));
		}
		
		function print_stack() {
			clearStack();
			generic.for_each(interpreter.stack(), function(elem) { appendToStack(interpreter.toString(elem)) });
			showStackReversed();
		}
	
		function print_words() {
			clearWords();
			
			var words = interpreter.words();
			
			for(var name in words) {
				appendToWords(name, interpreter.toString(words[name]));
			}

			$('#words > div:odd').addClass('oddRow');
			$('#words > div:even').addClass('evenRow');
		}

		print_stack();
		print_words();
		
		refreshResultScrollbar();
	}
	
	function clearCommand() {
		$('#command').val("");
	}
	
	function clearAll() {	
		clearResult();
		clearStack();
		clearWords();
		$('#command').focus();
	}

	function appendToCommand(value) {
		var old = $('#command').val();
		old += old === "" ? "" : " ";
		$('#command').val(old  + value); 			
	}
	
	function bindNativeWordHover() {
		$('.nativeword').live('click', function(elem) {
			appendToCommand($(this).find('.wordname').text());
			return false; // don't let the click event escape
		});

		$('.nativeword').live('mouseover', function(elem) {
			var wordname = $(this).find('.wordname').text();
			var description = $(this).find('.description').text();
			var stack_effect = $(this).find('.stack_effect').text();
			
			var top = $(this).offset().top - 2;
			var left = $(this).offset().left + 200 - 2;
			
			$(this).addClass('hovered');
			
			$('.main .popup').html(
				"<p class='popup_word'>" + escapeHTML(wordname) + "</p><p class='popup_stackeffect'>" + escapeHTML(stack_effect) + "</p><p class='popup_decription'>" + description + "</p>"
			)
			.css('top', top)
			.css('left', left)
			.show();
			return false;
		});
		
		$('.nativeword').live('mouseout', function(elem) {
				$(this).removeClass('hovered');
				$('.popup').hide();
		});
	}
	
	function bindCustomWordHover() {
		$('.customword').live('click', function(elem) {
			appendToCommand($(this).find('.word_name').text());
			return false; // don't let the click event escape
		});

		$('.customword').live('mouseover', function(elem) {
			var wordname = $(this).find('.word_name').text();
			var definition = $(this).find('.word_definition').text();
			
			$(this).addClass('hovered');
			
			var popup = $('.main .popup').html(
				"<p class='popup_word'>" + escapeHTML(wordname) + "</p><p class='popup_definition'>" + escapeHTML(definition) + "</p>"
			).addClass('customword_popup'); 


			var top = $(this).offset().top - 2;
			var left = $(this).offset().left - popup.width() - 20;
			
			popup
			.css('top', top)
			.css('left', left)
			.show();			
		});
		
		$('.customword').live('mouseout', function(elem) {
				removeHoverForCustomWord($(this));
		});
	}


	function bindWordCategoryHover() {
		$('.word_category').live('mouseover', function(elem) {
			var categoryname = $(this).find('.categoryname').text();
			var description = $(this).find('.categorydescription').text();
			
			var top = $(this).offset().top - 2;
			var left = $(this).offset().left + 200 - 2;
			
			$('.main .popup').html(
				"<p class='popup_categoryname'>" + categoryname + "</p><p class='popup_description'>" + description + "</p>"
			)
			.css('top', top)
			.css('left', left)
			.show();
			
		});
		
		$('.word_category').live('mouseout', function(elem) {
				$('.popup').hide();
		});
	}


	
	function removeHoverForCustomWord(elem) {
		$(elem)
			.removeClass('hovered')
		$('.popup')
			.removeClass('customword_popup')
			.hide();
	}
	
	
	function bindWhatsThisHover() {
		$('.whatsthis').live('mouseover', function(elem) {
		var popup = $(this).parent().parent().find('.whatsthis_popup');

		var parent = $(this).parent();
		var top = parent.position().top + 25;
		var left = parent.position().left; // + $(this).width();
		if(left > -$(popup).width() + $('body').width() + $('body').offset().left) {
			left = parent.position().left - $(popup).width() - 50;
		}

		popup
			.css('top', top)
			.css('left', left)
			.show();			
		});
		
		$('.whatsthis').live('mouseout', function(elem) {
			$(this).removeClass('hovered');
			$('.whatsthis_popup').hide();
		});

	}
	
	function getKeyCode(event) {
		return event.keyCode ? event.keyCode : event.which;
	}
	
	function isESCKey(event) {
		var ESC = 27;
		return getKeyCode(event) === ESC;
	}
	
	function isUpKey(event) {
		var UP_KEY = 38;
		return getKeyCode(event) === UP_KEY;
	}
	
	function isDownKey(event) {
		var DOWN_KEY = 40;
		return getKeyCode(event) === DOWN_KEY;
	}
	
	function bindHistoryBrowsing() {
		
		$('#command').keyup(function(event) {
				var code = getKeyCode(event);

				if(isUpKey(event)) {
					$('#command').val(commandHistory.get());
					commandHistory.older();
				} else if(isDownKey(event)) {
					commandHistory.newer();
					$('#command').val(commandHistory.get());
				} else if(isESCKey(event)) {
					$('#command').val('');
				}
		});
	}
	
	function bindClickWordCategory() {
		$('.word_category').live('click', function(elem) {
				var showWords = $(this).hasClass('showWords');
				
				$('.word_category').removeClass('showWords');
				$('#nativewords').find('.nativeword').hide();

				if(showWords) {
					$(this).find('.nativeword').hide();
				} else {
					$(this).find('.nativeword').show();
					$(this).addClass('showWords');
				}
				
		});
	}

	function generalPopupOpen() {
		$('#general_popup').show();
	}
	
	function generalPopupOpen(text, left, top) {
		var elem = $('#general_popup');
		if(elem.hasClass('popupShown')) return;
		
		elem.html('<div>' + text + '</div>');
		elem
			.css('left', left)
			.css('top', top)
			.show();
	}
	
	function generalPopupClose() {
		$('#general_popup').hide();
	}

	function bindGeneralPopup() {
		$('#general_popup').live('mouseover', function() {
			$(this).addClass('popupShown');
			generalPopupOpen();
		});

		$('#general_popup').live('mouseout', function() {
			$(this).removeClass('popupShown');
			
			//makes sensible to copy paste (if mouse go overboard, the popup doesn't disappear immediately)
			setTimeout(generalPopupClose, 2000); 
		});
	}
	
	function bindStackValueHover() {
		$("#stack > div").live('mouseover', function(event) {
				var text = $(this).text();
				var left = event.pageX + 10;
				var top = $(this).offset().top;
				generalPopupOpen(text, left, top);
		});		
		
		$("#stack").live('mouseout', function() {
				setTimeout(function() {
						if(!$('#general_popup').hasClass('popupShown')) {
							generalPopupClose();
						}
				}, 2000); // gives time to move into the popup after mouseout for "#stack > div" has occurred
		});
		
		$("#stack > div").live('click', function() {
				appendToCommand($(this).text());
		});		
	}

	
	
	function bindRemoveCustomWord() {
		$('.customword .remove').live('click', function() {
			var customWord = $(this).closest('.customword');
			var name = customWord.find('.word_name').text();
			interpreter.removeCustomWord(name);
			removeHoverForCustomWord(customWord);
			customWord.remove();
			return false; // don't let event escape
		});
	}
	
	function isEnterKeyCode(code) {
		return code === 10 || code === 13;
	}

	function bindExecuteInput() {
		function interpretInput() {
			var value = $.trim($('#command').val());
			commandHistory.add(value);
			clearCommand();
			showResult('> ' + value);

			interpreter.execute(value);
		}
		
		$('#executeButton').click(function(event) {
			interpretInput();
		});
		
		$('#command').keyup(function(event) {
			if(isEnterKeyCode(getKeyCode(event))) {
				interpretInput();
			}
		});
	}
	
	function bindShowExample() {
		$('.nativeword').live('mouseover', function() {
			var name = $(this).find('.wordname').text();
			var example = examples.examples()[name];
			if(example !== undefined) {
				var result = "";
				
		    result += "<span class='next'>" + example[0] + "</span>"; 

		    for(var i = 1; i < example.length; ++i) {
		    	result += "<span> " + example[i] + " </span>";
		    }

 		    $('#example').html(result);
			}
		});
	}

	function bindRunExample() {
		$('#exampleButton').click(function() {
			var example = $('#example');
			var old = example.html();
		  var value = example.find('.next');
			var next = example.find('.next + span');
			if(next.length !== 0) next.addClass('next');
			value.removeClass('next');	  
			interpreter.execute(value.text());

			if($('#example .next').length === 0) {
		    $('#example span:first').addClass('next');
			}

			//setTimeout(function(){$('#command').focus();}, 0);			
		});
		
	}
	
	function bindRemoveIntroduction() {
		$('.introduction .remove').click(function() {
				$('.introduction').remove();
		});
	}

	var customWordsStorageKey = "customWords";

	function loadLocallySavedCustomWords() {
		var customwords = $.jStorage.get(customWordsStorageKey);
		if(customwords !== null) {
		  interpreter.execute(customwords);
		} else {
			showResult(":: No custom words loaded locally (maybe your browser doesn't support it"); 
		}
	}
	
	function bindSaveLocally() {
		$('.save_custom_words').click(function() {
			var customwords = getCustomWordDefinitionsAsString();
			$.jStorage.set(customWordsStorageKey, customwords);
			showResult(':: saved custom words locally (if your browser supports it) ::');
		});
	}
	
	// initialize everything
	$(function() {
		bindSaveLocally();
		
		bindRemoveIntroduction();
		bindRunExample();
		bindShowExample();
		bindWordCategoryHover();
		bindRemoveCustomWord();
		bindGetCustomWordDefinitions();
		bindGeneralPopup();
		bindStackValueHover();
		bindNativeWordHover();
	  bindCustomWordHover();
		bindWhatsThisHover();
		bindHistoryBrowsing();
		bindClickWordCategory();
		bindExecuteInput();		

		clearAll();
		print_native_words();
		loadLocallySavedCustomWords();
		refresh();
	});
	
}
