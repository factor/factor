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
import java.io.*;
import java.util.*;
import org.gjt.sp.jedit.gui.*;
import org.gjt.sp.jedit.textarea.*;
import org.gjt.sp.jedit.*;
import org.gjt.sp.util.Log;
import console.*;
import sidekick.*;

public class FactorPlugin extends EditPlugin
{
	private static ExternalFactor external;

	//{{{ getPluginPath() method
	private String getPluginPath()
	{
		return MiscUtilities.getParentOfPath(
			jEdit.getPlugin("factor.jedit.FactorPlugin")
			.getPluginJAR().getPath())
			+ "Factor";
	} //}}}
	
	//{{{ start() method
	public void start()
	{
		BeanShell.eval(null,BeanShell.getNameSpace(),
			"import factor.*;\nimport factor.jedit.*;\n");
		String program = jEdit.getProperty("factor.external.program");
		String image = jEdit.getProperty("factor.external.image");
		if(program == null || image == null
			|| program.length() == 0 || image.length() == 0)
		{
			jEdit.setProperty("factor.external.program",
				MiscUtilities.constructPath(getPluginPath(),"f"));
			jEdit.setProperty("factor.external.image",
				MiscUtilities.constructPath(getPluginPath(),"factor.image"));
		}
	} //}}}

	//{{{ stop() method
	public void stop()
	{
		stopExternalInstance();
	} //}}}
	
	//{{{ getExternalInstance() method
	/**
	 * Returns the object representing a connection to an external Factor instance.
	 * It will start the interpreter if it's not already running.
	 */
	public synchronized static ExternalFactor getExternalInstance()
	{
		if(external == null)
		{
			Process p = null;
			InputStream in = null;
			OutputStream out = null;

			try
			{
				String[] args = jEdit.getProperty("factor.external.args","-jedit")
					.split(" ");
				String[] nargs = new String[args.length + 3];
				nargs[0] = jEdit.getProperty("factor.external.program");
				nargs[1] = jEdit.getProperty("factor.external.image");
				nargs[2] = "-no-ansi";
				System.arraycopy(args,0,nargs,3,args.length);
				p = Runtime.getRuntime().exec(nargs);
				p.getErrorStream().close();

				in = p.getInputStream();
				out = p.getOutputStream();
			}
			catch(IOException io)
			{
				Log.log(Log.ERROR,FactorPlugin.class,
					"Cannot start external Factor:");
				Log.log(Log.ERROR,FactorPlugin.class,io);
			}

			external = new ExternalFactor(p,in,out);
		}

		return external;
	} //}}}

	//{{{ getFactorShell() method
	public static FactorShell getFactorShell()
	{
		return ((FactorShell)ServiceManager.getService("console.Shell","Factor"));
	} //}}}

	//{{{ stopExternalInstance() method
	/**
	 * Stops the external interpreter.
	 */
	public static void stopExternalInstance()
	{
		getFactorShell().closeStreams();

		if(external != null)
		{
			external.close();
			external = null;
		}
	} //}}}
	
	//{{{ restartExternalInstance() method
	/**
	 * Restart the external interpreter.
	 */
	public static void restartExternalInstance()
	{
		stopExternalInstance();
		getExternalInstance();
		FactorPlugin.getFactorShell().openStreams();
	} //}}}

	//{{{ getSideKickParser() method
	public static FactorSideKickParser getSideKickParser()
	{
		return (FactorSideKickParser)ServiceManager.getService(
			"sidekick.SideKickParser","factor");
	} //}}}
	
	//{{{ evalInListener() method
	public static void evalInListener(View view, String cmd)
	{
		DockableWindowManager wm = view.getDockableWindowManager();
		wm.addDockableWindow("console");
		Console console = (Console)wm.getDockableWindow("console");
		console.run(Shell.getShell("Factor"),console,cmd);
	} //}}}

	//{{{ evalInWire() method
	public static void evalInWire(String cmd) throws IOException
	{
		getExternalInstance().eval(cmd);
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
	
	//{{{ factorWordOutputOp() method
	/**
	 * Apply a Factor word to the selected word.
	 */
	public static void factorWordOutputOp(View view, String op)
	{
		String word = factorWord(view);
		if(word == null)
			view.getToolkit().beep();
		else
			evalInListener(view,word + " " + op);
	} //}}}

	//{{{ factorWordWireOp() method
	/**
	 * Apply a Factor word to the selected word.
	 */
	public static void factorWordWireOp(View view, String op) throws IOException
	{
		String word = factorWord(view);
		if(word == null)
			view.getToolkit().beep();
		else
			evalInWire(word + " " + op);
	} //}}}

	//{{{ toWordArray() method
	public static FactorWord[] toWordArray(Set completions)
	{
		FactorWord[] w = (FactorWord[])completions.toArray(new FactorWord[
			completions.size()]);
		Arrays.sort(w,new MiscUtilities.StringICaseCompare());

		return w;
	} //}}}
	
	//{{{ getCompletions() method
	/**
	 * Returns all words in all vocabularies.
	 *
	 * @param anywhere If true, matches anywhere in the word name are
	 * returned; otherwise, only matches from beginning.
	 */
	public static Set getCompletions(String word, boolean anywhere)
	{
		try
		{
			return getCompletions(getExternalInstance().getVocabularies(),word,
				anywhere);
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}
	
	//{{{ getCompletions() method
	/**
	 * @param anywhere If true, matches anywhere in the word name are
	 * returned; otherwise, only matches from beginning.
	 */
	public static Set getCompletions(Cons use, String word, boolean anywhere)
	{
		try
		{
			Set completions = new HashSet();
	
			while(use != null)
			{
				String vocab = (String)use.car;
				getExternalInstance().getCompletions(
					vocab,word,completions,anywhere);
				use = use.next();
			}

			return completions;
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
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
		if(caret == line.length())
			caret--;

		ReadTable readtable = ReadTable.DEFAULT_READTABLE;

		if(readtable.getCharacterType(line.charAt(caret))
			== ReadTable.WHITESPACE)
		{
			return null;
		}

		int start = caret;
		while(start > 0)
		{
			if(readtable.getCharacterType(line.charAt(start - 1))
				== ReadTable.WHITESPACE)
			{
				break;
			}
			else
				start--;
		}

		int end = caret;
		do
		{
			if(readtable.getCharacterType(line.charAt(end))
				== ReadTable.WHITESPACE)
			{
				break;
			}
			else
				end++;
		}
		while(end < line.length());

		return line.substring(start,end);
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
		throws Exception
	{
		ExternalFactor external = getExternalInstance();

		ArrayList words = new ArrayList();

		Cons vocabs = external.getVocabularies();
		while(vocabs != null)
		{
			String vocab = (String)vocabs.car;
			FactorWord w = (FactorWord)external.searchVocabulary(
				new Cons(vocab,null),word);
			if(w != null)
				words.add(w);
			vocabs = vocabs.next();
		}
		return (FactorWord[])words.toArray(new FactorWord[words.size()]);
	} //}}}

	//{{{ insertUseDialog() method
	public static void insertUseDialog(View view, String word)
	{
		try
		{
			FactorWord[] words = findAllWordsNamed(view,word);
			if(words.length == 0)
				view.getToolkit().beep();
			else if(words.length == 1)
				insertUse(view,words[0].vocabulary);
			else
				new InsertUseDialog(view,getSideKickParser(),words);
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
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
		boolean leadingNewline = false;
		boolean seenUse = false;

		for(int i = 0; i < buffer.getLineCount(); i++)
		{
			String text = buffer.getLineText(i).trim();
			if(text.startsWith("IN:") || text.startsWith("USE:"))
			{
				lastUseOffset = buffer.getLineEndOffset(i) - 1;
				leadingNewline = true;
				seenUse = true;
			}
			else if(text.startsWith("!") && !seenUse)
			{
				lastUseOffset = buffer.getLineEndOffset(i) - 1;
				leadingNewline = true;
			}
			else if(text.length() == 0 && !seenUse)
			{
				if(i == 0)
					lastUseOffset = 0;
				else
					lastUseOffset  = buffer.getLineEndOffset(i - 1) - 1;
			}
			else
			{
				break;
			}
		}

		String decl = "USE: " + vocab;
		if(leadingNewline)
			decl = "\n" + decl;
		if(lastUseOffset == 0)
			decl = decl + "\n";
		buffer.insert(lastUseOffset,decl);
		showStatus(view,"inserted-use",decl);
	} //}}}

	//{{{ extractWord() method
	public static void extractWord(View view)
	{
		JEditTextArea textArea = view.getTextArea();
		Buffer buffer = textArea.getBuffer();
		String selection = textArea.getSelectedText();
		if(selection == null)
			selection = "";

		SideKickParsedData data = SideKickParsedData
			.getParsedData(view);
		if(!(data instanceof FactorParsedData))
		{
			view.getToolkit().beep();
			return;
		}

		Asset asset = data.getAssetAtPosition(
			textArea.getCaretPosition());

		if(asset == null)
		{
			GUIUtilities.error(view,"factor.extract-word-where",null);
			return;
		}

		String newWord = GUIUtilities.input(view,
			"factor.extract-word",null);
		if(newWord == null)
			return;

		int start = asset.start.getOffset();
		/* Hack */
		start = buffer.getLineStartOffset(
			buffer.getLineOfOffset(start));

		String indent = MiscUtilities.createWhiteSpace(
			buffer.getIndentSize(),
			(buffer.getBooleanProperty("noTabs") ? 0
			: buffer.getTabSize()));

		String newDef = ": " + newWord + "\n" + indent
			+ selection.trim() + " ;\n\n" ;

		try
		{
			buffer.beginCompoundEdit();
			
			buffer.insert(start,newDef);
			textArea.setSelectedText(newWord);
		}
		finally
		{
			buffer.endCompoundEdit();
		}
	} //}}}
}
