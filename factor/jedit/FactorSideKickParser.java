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

import errorlist.*;
import factor.*;
import java.io.*;
import javax.swing.tree.DefaultMutableTreeNode;
import java.util.*;
import org.gjt.sp.jedit.*;
import org.gjt.sp.util.Log;
import sidekick.*;

public class FactorSideKickParser extends SideKickParser
{
	//{{{ FactorSideKickParser constructor
	public FactorSideKickParser()
	{
		super("factor");
	} //}}}

	//{{{ parse() method
	/**
	 * Parses the given text and returns a tree model.
	 *
	 * @param buffer The buffer to parse.
	 * @param errorSource An error source to add errors to.
	 *
	 * @return A new instance of the <code>SideKickParsedData</code> class.
	 */
	public SideKickParsedData parse(Buffer buffer,
		DefaultErrorSource errorSource)
	{
		FactorParsedData d = new FactorParsedData(buffer.getPath());

		FactorInterpreter interp = FactorPlugin.getInterpreter();

		String text;

		try
		{
			buffer.readLock();

			text = buffer.getText(0,buffer.getLength());

			/* of course wrapping a string reader in a buffered
			reader is dumb, but the FactorReader uses readLine() */
			FactorScanner scanner = new RestartableFactorScanner(
				buffer.getPath(),
				new BufferedReader(new StringReader(text)),
				errorSource);
			FactorReader r = new FactorReader(scanner,
				false,false,interp);

			Cons parsed = r.parse();

			d.in = r.getIn();
			d.use = r.getUse();

			addWordDefNodes(d,parsed,buffer);
		}
		catch(FactorParseException pe)
		{
			errorSource.addError(ErrorSource.ERROR,pe.getFileName(),
				/* Factor line #'s are 1-indexed */
				pe.getLineNumber() - 1,0,0,pe.getMessage()); 
		}
		catch(Exception e)
		{
			errorSource.addError(ErrorSource.ERROR,
				buffer.getPath(),
				0,0,0,e.toString());
			Log.log(Log.DEBUG,this,e);
		}
		finally
		{
			buffer.readUnlock();
		}

		return d;
	} //}}}

	//{{{ addWordDefNodes() method
	private void addWordDefNodes(SideKickParsedData d, Cons parsed,
		Buffer buffer)
	{
		FactorAsset last = null;

		while(parsed != null)
		{
			if(parsed.car instanceof FactorWordDefinition)
			{
				FactorWordDefinition def
					= (FactorWordDefinition)
					parsed.car;

				FactorWord word = def.word;

				/* word lines are indexed from 1 */
				int startLine = Math.min(
					buffer.getLineCount() - 1,
					word.line - 1);
				int startLineLength = buffer.getLineLength(
					startLine);
				int startCol = Math.min(word.col,
					startLineLength);

				int start = buffer.getLineStartOffset(startLine)
					+ startCol;

				if(last != null)
					last.end = buffer.createPosition(start - 1);

				last = new FactorAsset(word.name,
					buffer.createPosition(start));
				d.root.add(new DefaultMutableTreeNode(last));
			}

			parsed = parsed.next();
		}

		if(last != null)
			last.end = buffer.createPosition(buffer.getLength());
	} //}}}

	//{{{ supportsCompletion() method
	/**
	 * Returns if the parser supports code completion.
	 *
	 * Returns false by default.
	 */
	public boolean supportsCompletion()
	{
		return true;
	} //}}}

	//{{{ isWhitespace() method
	private boolean isWhitespace(char ch)
	{
		return (ReadTable.DEFAULT_READTABLE.getCharacterType(ch)
			== ReadTable.WHITESPACE);
	} //}}}

	//{{{ canCompleteAnywhere() method
	/**
	 * Returns if completion popups should be shown after any period of
	 * inactivity. Otherwise, they are only shown if explicitly requested
	 * by the user.
	 *
	 * Returns false by default.
	 */
	public boolean canCompleteAnywhere()
	{
		return false;
	} //}}}

	//{{{ complete() method
	/**
	 * Returns completions suitable for insertion at the specified position.
	 *
	 * Returns null by default.
	 *
	 * @param editPane The edit pane involved.
	 * @param caret The caret position.
	 */
	public SideKickCompletion complete(EditPane editPane, int caret)
	{
		SideKickParsedData _data = SideKickParsedData
			.getParsedData(editPane.getView());
		if(!(_data instanceof FactorParsedData))
			return null;
		FactorParsedData data = (FactorParsedData)_data;

		Buffer buffer = editPane.getBuffer();

		// first, we get the word before the caret
		int caretLine = buffer.getLineOfOffset(caret);
		int lineStart = buffer.getLineStartOffset(caretLine);
		String text = buffer.getText(lineStart,caret - lineStart);

		/* Don't complete in the middle of a word */
		int lineEnd = buffer.getLineEndOffset(caretLine) - 1;
		if(caret != lineEnd)
		{
			String end = buffer.getText(caret,lineEnd - caret);
			if(!isWhitespace(end.charAt(0)))
				return null;
		}

		int wordStart = 0;
		for(int i = text.length() - 1; i >= 0; i--)
		{
			char ch = text.charAt(i);
			if(isWhitespace(ch))
			{
				wordStart = i + 1;
				break;
			}
		}

		String word = text.substring(wordStart);

		/* Don't complete empty string */
		if(word.length() == 0)
			return null;

		List completions = getCompletions(data.use,word);

		if(completions.size() == 0)
			return null;
		else
		{
			Collections.sort(completions,
				new MiscUtilities.StringICaseCompare());
			return new FactorCompletion(editPane.getView(),
				completions,word,data);
		}
	} //}}}

	//{{{ getCompletions() method
	private List getCompletions(Cons use, String word)
	{
		List completions = new ArrayList();
		FactorInterpreter interp = FactorPlugin.getInterpreter();

		while(use != null)
		{
			String vocab = (String)use.car;
			getCompletions(interp,vocab,word,completions);
			use = use.next();
		}
		
		return completions;
	} //}}}

	//{{{ getCompletions() method
	private void getCompletions(FactorInterpreter interp, String vocab,
		String word, List completions)
	{
		try
		{
			FactorNamespace v = interp.getVocabulary(vocab);
			Cons words = v.toValueList();

			while(words != null)
			{
				FactorWord w = (FactorWord)words.car;

				if(w.name.startsWith(word))
					completions.add(w);

				words = words.next();
			}
		}
		catch(Exception e)
		{
			Log.log(Log.ERROR,this,e);
		}
	} //}}}
}
