/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004, 2005 Slava Pestov.
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
import org.gjt.sp.jedit.syntax.*;
import org.gjt.sp.jedit.textarea.*;
import org.gjt.sp.jedit.*;
import org.gjt.sp.util.Log;
import console.*;
import sidekick.*;

public class FactorPlugin extends EditPlugin
{
	private static ExternalFactor external;
	private static Process process;
	private static int PORT = 9999;

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

		Buffer buffer = jEdit.getFirstBuffer();
		while(buffer != null)
		{
			buffer.setProperty(FactorSideKickParser.ARTIFACTS_PROPERTY,null);
			buffer = buffer.getNext();
		}
	} //}}}

	//{{{ addNonEmpty() method
	private static void addNonEmpty(String[] input, List output)
	{
		for(int i = 0; i < input.length; i++)
		{
			if(input[i].length() != 0)
				output.add(input[i]);
		}
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
			InputStream in = null;
			OutputStream out = null;

			try
			{
				String exePath = jEdit.getProperty(
					"factor.external.program");
				String imagePath = jEdit.getProperty(
					"factor.external.image");
				List args = new ArrayList();
				args.add(exePath);
				args.add(imagePath);
				args.add("-null-stdio");
				args.add("-shell=telnet");
				args.add("-telnetd-port=" + PORT);
				String[] extraArgs = jEdit.getProperty(
					"factor.external.args")
					.split(" ");
				addNonEmpty(extraArgs,args);
				process = Runtime.getRuntime().exec(
					(String[])args.toArray(
					new String[args.size()]),
					null,
					new File(MiscUtilities
					.getParentOfPath(imagePath)));

				external = new ExternalFactor(PORT);

				process.getOutputStream().close();
				process.getInputStream().close();
				process.getErrorStream().close();
			}
			catch(Exception e)
			{
				Log.log(Log.ERROR,FactorPlugin.class,
					"Cannot start external Factor:");
				Log.log(Log.ERROR,FactorPlugin.class,e);
				process = null;
			}
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
		if(getFactorShell() != null)
			getFactorShell().closeStreams();

		if(external != null)
		{
			external.close();
			try
			{
				process.getErrorStream().close();
				process.getInputStream().close();
				process.getOutputStream().close();
				process.waitFor();
			}
			catch(Exception e)
			{
				Log.log(Log.DEBUG,FactorPlugin.class,e);
			}
			external = null;
			process = null;
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
	
	//{{{ getParsedData() method
	public static FactorParsedData getParsedData(View view)
	{
		SideKickParsedData data = SideKickParsedData.getParsedData(view);
		if(data instanceof FactorParsedData)
			return (FactorParsedData)data;
		else
			return null;
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
	public static String evalInWire(String cmd) throws IOException
	{
		return getExternalInstance().eval(cmd);
	} //}}}

	//{{{ lookupWord() method
	/**
	 * Look up the given Factor word in the vocabularies USE:d in the given view.
	 */
	public static FactorWord lookupWord(View view, String word)
	{
		FactorParsedData fdata = getParsedData(view);
		if(fdata == null)
			return null;
		else
			return getExternalInstance().searchVocabulary(fdata.use,word);
	} //}}}

	//{{{ factorWord() method
	/**
	 * Look up the given Factor word in the vocabularies USE:d in the given view.
	 */
	public static String factorWord(View view, String word)
	{
		FactorParsedData fdata = getParsedData(view);
		if(fdata == null)
			return null;

		return "\""
			+ FactorReader.charsToEscapes(word)
			+ "\" " + FactorReader.unparseObject(fdata.use)
			+ " search";
	} //}}}

	//{{{ factorWord() method
	/**
	 * Build a Factor expression for pushing the selected word on the stack
	 */
	public static String factorWord(View view)
	{
		JEditTextArea textArea = view.getTextArea();
		String word = FactorPlugin.getWordAtCaret(textArea);
		if(word == null)
			return null;
		else
			return factorWord(view,word);
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

	//{{{ factorWordPopupOp() method
	/**
	 * Apply a Factor word to the selected word.
	 */
	public static void factorWordPopupOp(View view, String op) throws IOException
	{
		String word = factorWord(view);
		if(word == null)
			view.getToolkit().beep();
		else
		{
			new TextAreaPopup(view.getTextArea(),
				evalInWire(word + " " + op).trim());
		}
	} //}}}

	//{{{ toWordArray() method
	public static FactorWord[] toWordArray(Set completions)
	{
		FactorWord[] w = (FactorWord[])completions.toArray(new FactorWord[
			completions.size()]);
		Arrays.sort(w,new MiscUtilities.StringICaseCompare());

		return w;
	} //}}}
	
	//{{{ getWordCompletions() method
	/**
	 * Returns all words in all vocabularies whose name starts with
	 * <code>word</code>.
	 *
	 * @param anywhere If true, matches anywhere in the word name are
	 * returned; otherwise, only matches from beginning.
	 */
	public static Set getWordCompletions(String word, boolean anywhere)
	{
		try
		{
			Set completions = new HashSet();
			getExternalInstance().getWordCompletions(
				getExternalInstance().getVocabularies(),
				word,
				anywhere,
				completions);
			return completions;
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}
	
	//{{{ getVocabCompletions() method
	/**
	 * Returns all vocabularies whose name starts with
	 * <code>vocab</code>.
	 *
	 * @param anywhere If true, matches anywhere in the word name are
	 * returned; otherwise, only matches from beginning.
	 */
	public static String[] getVocabCompletions(String vocab, boolean anywhere)
	{
		try
		{
			return getExternalInstance().getVocabCompletions(
				vocab,anywhere);
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}
	
	//{{{ getWordStartIndex() method
	public static int getWordStartOffset(String line, int caret)
	{
		ReadTable readtable = ReadTable.DEFAULT_READTABLE;

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
		
		return start;
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

		int start = getWordStartOffset(line,caret);

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
	public static boolean isUsed(View view, String vocab)
	{
		FactorParsedData fdata = getParsedData(view);
		if(fdata == null)
			return false;
		else
		{
			Cons use = fdata.use;
			return Cons.contains(use,vocab);
		}
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

	//{{{ findUse() method
	/**
	 * Find an existing USING: declaration.
	 */
	private static int findUse(Buffer buffer)
	{
		for(int i = 0; i < buffer.getLineCount(); i++)
		{
			String text = buffer.getLineText(i);
			int index = text.indexOf("USING:");
			if(index != -1)
				return buffer.getLineStartOffset(i) + index;
		}
		
		return -1;
	} //}}}

	//{{{ createUse() method
	/**
	 * No USING: declaration exists, so add a new one.
	 */
	private static void createUse(Buffer buffer, String vocab)
	{
		String decl = "USING: " + vocab + " ;";

		int offset = 0;
		boolean leadingNewline = false;
		boolean trailingNewline = true;

		for(int i = 0; i < buffer.getLineCount(); i++)
		{
			String text = buffer.getLineText(i).trim();
			if(text.startsWith("IN:"))
			{
				offset = buffer.getLineEndOffset(i) - 1;
				leadingNewline = true;
				break;
			}
			else if(text.startsWith("!"))
			{
				offset = buffer.getLineEndOffset(i) - 1;
				leadingNewline = true;
			}
			else if(text.length() == 0)
			{
				if(i == 0)
					offset = 0;
				else
					offset = buffer.getLineEndOffset(i - 1) - 1;
				leadingNewline = true;
				trailingNewline = false;
			}
			else
				break;
		}

		decl = (leadingNewline ? "\n" : "") + decl
			+ (trailingNewline ? "\n" : "");
		
		buffer.insert(offset,decl);
	} //}}}

	//{{{ updateUse() method
	private static void updateUse(Buffer buffer, String vocab, int offset)
	{
		String text = buffer.getText(0,buffer.getLength());
		int end = text.indexOf(";",offset);
		if(end == -1)
			end = buffer.getLength();

		String decl = text.substring(offset + "USING:".length(),end);
		
		List declList = new ArrayList();
		StringTokenizer st = new StringTokenizer(decl);
		while(st.hasMoreTokens())
			declList.add(st.nextToken());
		declList.add(vocab);
		Collections.sort(declList);
		
		StringBuffer buf = new StringBuffer("USING: ");
		Iterator iter = declList.iterator();
		while(iter.hasNext())
		{
			buf.append(iter.next());
			buf.append(' ');
		}

		/* format() strips trailing whitespace */
		decl = TextUtilities.format(buf.toString(),
			buffer.getIntegerProperty("maxLineLen",64),
			buffer.getTabSize()) + " ";

		try
		{
			buffer.beginCompoundEdit();
			buffer.remove(offset,end - offset);
			buffer.insert(offset,decl);
		}
		finally
		{
			buffer.endCompoundEdit();
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
		int offset = findUse(buffer);

		if(offset == -1)
			createUse(buffer,vocab);
		else
			updateUse(buffer,vocab,offset);

		showStatus(view,"inserted-use",vocab);
	} //}}}

	//{{{ extractWord() method
	public static void extractWord(View view)
	{
		JEditTextArea textArea = view.getTextArea();
		Buffer buffer = textArea.getBuffer();
		String selection = textArea.getSelectedText();
		if(selection == null)
			selection = "";

		FactorParsedData data = getParsedData(view);
		if(data == null)
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

			int firstLine = buffer.getLineOfOffset(start);

			buffer.insert(start,newDef);
			
			int lastLine = buffer.getLineOfOffset(start
				+ newDef.length());
			
			buffer.indentLines(firstLine,lastLine);
			
			textArea.setSelectedText(newWord);
			buffer.indentLine(textArea.getCaretLine(),true);
		}
		finally
		{
			buffer.endCompoundEdit();
		}
	} //}}}

	//{{{ getRulesetAtOffset() method
	public static String getRulesetAtOffset(JEditTextArea textArea, int caret)
	{
		int line = textArea.getLineOfOffset(caret);

		DefaultTokenHandler h = new DefaultTokenHandler();
		textArea.getBuffer().markTokens(line,h);
		Token tokens = h.getTokens();

		int offset = caret - textArea.getLineStartOffset(line);

		int len = textArea.getLineLength(line);
		if(len == 0)
			return null;

		if(offset == len)
			offset--;

		Token token = TextUtilities.getTokenAtOffset(tokens,offset);
		
		return token.rules.getName();
	} //}}}
}
