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
import console.*;
import sidekick.*;

public class FactorPlugin extends EditPlugin
{
	private static FactorInterpreter interp;
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
	public static ExternalFactor getExternalInstance()
		throws IOException, UnsupportedEncodingException
	{
		if(external == null)
		{
			Process p = Runtime.getRuntime().exec(
				new String[] {
					jEdit.getProperty("factor.external.program"),
					jEdit.getProperty("factor.external.image"),
					"-no-ansi",
					"-jedit"
				});
			p.getErrorStream().close();

			external = new ExternalFactor(
				getInterpreter(),
				p.getInputStream(),
				p.getOutputStream());
		}

		return external;
	} //}}}

	//{{{ stopExternalInstance() method
	/**
	 * Stops the external interpreter. It will probably be restarted soon after.
	 */
	public static void stopExternalInstance()
	{
		((FactorShell)ServiceManager.getService("console.Shell","Factor"))
			.closeStreams();

		if(external != null)
		{
			external.close();
			external = null;
		}
	} //}}}

	//{{{ newInterpreter() method
	private static FactorInterpreter newInterpreter(String[] args)
	{
		try
		{
			FactorInterpreter interp = new FactorInterpreter();
			interp.interactive = false;
			interp.init(args);
			return interp;
		}
		catch(Exception e)
		{
			System.err.println("Failed to initialize interpreter:");
			e.printStackTrace();
			return null;
		}
	} //}}}

	//{{{ getInterpreter() method
	/**
	 * This can be called from the SideKick thread and must be thread safe.
	 */
	public static synchronized FactorInterpreter getInterpreter()
	{
		if(interp == null)
		{
			interp = newInterpreter(new String[] { "-jedit", "-no-compile" });
		}

		return interp;
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
		if(v == null)
			return;

		Cons words = v.toValueList();

		while(words != null)
		{
			FactorWord w = (FactorWord)words.car;
			if(w != null && w.name != null)
			{
				if(!completions.contains(w))
				{
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
				}
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
			new InsertUseDialog(view,getSideKickParser(),words);
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

		for(int i = 0; i < buffer.getLineCount(); i++)
		{
			String text = buffer.getLineText(i).trim();
			if(text.startsWith("IN:") || text.startsWith("USE:"))
			{
				lastUseOffset = buffer.getLineEndOffset(i) - 1;
				leadingNewline = true;
			}
			else if(text.startsWith("!"))
			{
				lastUseOffset = buffer.getLineEndOffset(i) - 1;
				leadingNewline = true;
			}
			else if(text.length() == 0)
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
