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

import factor.listener.FactorListenerPanel;
import factor.*;
import java.io.InputStreamReader;
import java.util.*;
import org.gjt.sp.jedit.gui.*;
import org.gjt.sp.jedit.textarea.*;
import org.gjt.sp.jedit.*;
import sidekick.*;

public class FactorPlugin extends EditPlugin
{
	private static final String DOCKABLE_NAME = "factor";

	private static FactorInterpreter interp;

	//{{{ start() method
	public void start()
	{
		BeanShell.eval(null,BeanShell.getNameSpace(),
			"import factor.*;\nimport factor.jedit.*;\n");
	} //}}}
	
	//{{{ getInterpreter() method
	/**
	 * This can be called from the SideKick thread and must be thread safe.
	 */
	public static synchronized FactorInterpreter getInterpreter()
	{
		if(interp == null)
		{
			interp = FactorListenerPanel.newInterpreter(
				new String[] { "-jedit" });
		}

		return interp;
	} //}}}
	
	//{{{ eval() method
	public static void eval(View view, String cmd)
	{
		DockableWindowManager wm = view.getDockableWindowManager();
		wm.addDockableWindow(DOCKABLE_NAME);
		FactorListenerPanel panel = (FactorListenerPanel)
			wm.getDockableWindow(DOCKABLE_NAME);
		panel.getListener().eval(cmd);
	} //}}}

	//{{{ factorWord() method
	/**
	 * Build a Factor expression for pushing the selected word on the stack
	 */
	public static String factorWord(FactorWord word)
	{
		return FactorReader.unparseObject(word.name)
			+ " [ " + FactorReader.unparseObject(word.vocabulary)
			+ " ] search";
	} //}}}

	//{{{ factorWord() method
	/**
	 * Build a Factor expression for pushing the selected word on the stack
	 */
	public static String factorWord(View view)
	{
		JEditTextArea textArea = view.getTextArea();
		SideKickParsedData data = SideKickParsedData
			.getParsedData(view);
		if(data instanceof FactorParsedData)
		{
			FactorParsedData fdata = (FactorParsedData)data;
			String word = FactorPlugin.getWordAtCaret(textArea);
			if(word == null)
				return null;
			return "\""
				+ FactorReader.charsToEscapes(word)
				+ "\" " + FactorReader.unparseObject(fdata.use)
				+ " search";
		}
		else
			return null;
	} //}}}
	
	//{{{ factorWordOperation() method
	/**
	 * Apply a Factor word to the selected word.
	 */
	public static void factorWordOperation(View view, String op)
	{
		String word = factorWord(view);
		if(word == null)
			view.getToolkit().beep();
		else
			eval(view,word + " " + op);
	} //}}}

	//{{{ getCompletions() method
	/**
	 * Returns all words in all vocabularies.
	 *
	 * @param anywhere If true, matches anywhere in the word name are
	 * returned; otherwise, only matches from beginning.
	 */
	public static List getCompletions(String word, boolean anywhere)
	{
		return getCompletions(interp.vocabularies.toVarList(),word,
			anywhere);
	} //}}}
	
	//{{{ getCompletions() method
	/**
	 * @param anywhere If true, matches anywhere in the word name are
	 * returned; otherwise, only matches from beginning.
	 */
	public static List getCompletions(Cons use,
		String word, boolean anywhere)
	{
		List completions = new ArrayList();
		FactorInterpreter interp = FactorPlugin.getInterpreter();

		while(use != null)
		{
			String vocab = (String)use.car;
			getCompletions(interp,vocab,word,completions,anywhere);
			use = use.next();
		}
		
		Collections.sort(completions,
			new MiscUtilities.StringICaseCompare());

		return completions;
	} //}}}

	//{{{ getCompletions() method
	private static void getCompletions(FactorInterpreter interp,
		String vocab, String word, List completions, boolean anywhere)
	{
		FactorNamespace v = interp.getVocabulary(vocab);
		Cons words = v.toValueList();

		while(words != null)
		{
			FactorWord w = (FactorWord)words.car;

			if(anywhere)
			{
				if(w.name.indexOf(word) != -1)
					completions.add(w);
			}
			else
			{
				if(w.name.startsWith(word))
					completions.add(w);
			}

			words = words.next();
		}
	} //}}}
	
	//{{{ getWordAtCaret() method
	public static String getWordAtCaret(JEditTextArea textArea)
	{
		if(textArea.getSelectionCount() != 0)
			return textArea.getSelectedText();

		String line = textArea.getLineText(textArea.getCaretLine());
		if(line.length() == 0)
			return null;

		int caret = textArea.getCaretPosition()
			- textArea.getLineStartOffset(
			textArea.getCaretLine());
		String noWordSep = textArea.getBuffer().getStringProperty(
			"noWordSep");
		int wordStart = TextUtilities.findWordStart(line,caret,
			noWordSep);
		int wordEnd = TextUtilities.findWordEnd(line,caret,
			noWordSep);
		return line.substring(wordStart,wordEnd);
	} //}}}
	
	//{{{ showStatus() method
	public static void showStatus(View view, String msg, String arg)
	{
		view.getStatus().setMessage(
			jEdit.getProperty("factor.status." + msg,
			new String[] { arg }));
	} //}}}
	
	//{{{ isUsed() method
	private static boolean isUsed(View view, String vocab)
	{
		SideKickParsedData data = SideKickParsedData
			.getParsedData(view);
		if(data instanceof FactorParsedData)
		{
			FactorParsedData fdata = (FactorParsedData)data;
			Cons use = fdata.use;
			return Cons.contains(use,vocab);
		}
		else
			return false;
	} //}}}

	//{{{ findAllWordsNamed() method
	private static FactorWord[] findAllWordsNamed(View view, String word)
	{
		ArrayList words = new ArrayList();
		Cons vocabs = getInterpreter().vocabularies.toValueList();
		while(vocabs != null)
		{
			FactorNamespace vocab = (FactorNamespace)vocabs.car;
			FactorWord w = (FactorWord)vocab.getVariable(word);
			if(w != null)
				words.add(w);
			vocabs = vocabs.next();
		}
		return (FactorWord[])words.toArray(
			new FactorWord[words.size()]);
	} //}}}

	//{{{ insertUseDialog() method
	public static void insertUseDialog(View view, String word)
	{
		FactorWord[] words = findAllWordsNamed(view,word);
		if(words.length == 0)
			view.getToolkit().beep();
		else if(words.length == 1)
			insertUse(view,words[0].vocabulary);
		else
			new InsertUseDialog(view,getInterpreter(),words);
	} //}}}

	//{{{ insertUse() method
	public static void insertUse(View view, String vocab)
	{
		if(isUsed(view,vocab))
		{
			showStatus(view,"already-used",vocab);
			return;
		}

		Buffer buffer = view.getBuffer();
		int lastUseOffset = 0;

		for(int i = 0; i < buffer.getLineCount(); i++)
		{
			String text = buffer.getLineText(i).trim();
			if(text.startsWith("IN:") || text.startsWith("USE:")
				|| text.startsWith("!")
				|| text.length() == 0)
			{
				lastUseOffset = buffer.getLineStartOffset(i);
			}
			else
				break;
		}

		String decl = "USE: " + vocab + "\n";
		buffer.insert(lastUseOffset,decl);
		showStatus(view,"inserted-use",decl);
	} //}}}
}
