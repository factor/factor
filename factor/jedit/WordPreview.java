/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004 Slava Pestov.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package factor.jedit;

import factor.*;
import java.awt.event.*;
import java.io.IOException;
import java.util.*;
import javax.swing.event.*;
import javax.swing.Timer;
import org.gjt.sp.jedit.syntax.*;
import org.gjt.sp.jedit.textarea.*;
import org.gjt.sp.jedit.*;
import org.gjt.sp.util.Log;
import sidekick.*;

public class WordPreview implements ActionListener, CaretListener
{
	private FactorSideKickParser parser;
	private Timer timer;
	private EditPane editPane;

	private static String[] IGNORED_RULESETS = {
		"factor::LITERAL",
		"factor::STACK_EFFECT",
		"factor::COMMENT"
	};

	//{{{ WordPreview constructor
	public WordPreview(FactorSideKickParser parser, EditPane editPane)
	{
		this.parser = parser;
		this.editPane = editPane;
		this.timer = new Timer(0,this);
		timer.setRepeats(false);
	} //}}}
	
	//{{{ caretUpdate() method
	public void caretUpdate(CaretEvent e)
	{
		timer.stop();
		timer.setInitialDelay(100);
		timer.start();
	} //}}}

	//{{{ public void actionPerformed() method
	public void actionPerformed(ActionEvent evt)
	{
		try
		{
			if(FactorPlugin.getExternalInstance().isClosed())
				return;

			showPreview();
		}
		catch(IOException e)
		{
			throw new RuntimeException(e);
		}
	} //}}}
	
	//{{{ getWordAtCaret() method
	private FactorWord getWordAtCaret(FactorParsedData fdata)
		throws IOException
	{
		JEditTextArea textArea = editPane.getTextArea();
		
		String name = FactorPlugin.getRulesetAtOffset(editPane,
			textArea.getCaretPosition());
		if(name == null)
			return null;

		for(int i = 0; i < IGNORED_RULESETS.length; i++)
		{
			if(name.equals(IGNORED_RULESETS[i]))
				return null;
		}

		String word = FactorPlugin.getWordAtCaret(textArea);
		if(word == null)
			return null;

		return FactorPlugin.getExternalInstance()
			.searchVocabulary(fdata.use,word);
	} //}}}

	//{{{ showPreview() method
	private void showPreview()
		throws IOException
	{
		View view = editPane.getView();

		if(SideKickPlugin.isParsingBuffer(view.getBuffer()))
			return;

		if(!view.getBuffer().isLoaded())
			return;

		FactorParsedData data = FactorPlugin.getParsedData(view);
		if(data != null)
		{
			FactorWord w = getWordAtCaret(data);
			if(w != null)
			{
				view.getStatus().setMessageAndClear(
					FactorWordRenderer.getWordHTMLString(
					w,true));
			}
		}
	} //}}}
}
