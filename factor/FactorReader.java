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

package factor;

import java.io.*;
import java.util.*;

/**
 * Use a FactorScanner to read words, and dispatch to parsing words in order
 * to build a parse tree.
 */
public class FactorReader
{
	private VocabularyLookup lookup;
	private FactorScanner scanner;
	private Cons states;

	/**
	 * Top level of parse tree.
	 */
	private FactorWord toplevel = new FactorWord(null,"#<EOF>");
	private boolean alwaysDocComments;

	private Cons use;
	private String in;
	private int base = 10;

	//{{{ getUnreadableString() method
	public static String getUnreadableString(String str)
	{
		return "#<" + str + ">";
	} //}}}

	//{{{ charsToEscapes() method
	public static String charsToEscapes(String str)
	{
		StringBuffer buf = new StringBuffer();
		for(int i = 0; i < str.length(); i++)
		{
			char ch = str.charAt(i);
			switch(ch)
			{
			case 27: // ASCII ESC
				buf.append("\\e");
				break;
			case '\n':
				buf.append("\\n");
				break;
			case '\r':
				buf.append("\\r");
				break;
			case '\t':
				buf.append("\\t");
				break;
			case '"':
				buf.append("\\\"");
				break;
			case '\\':
				buf.append("\\\\");
				break;
			case '\0':
				buf.append("\\0");
				break;
			default:
				if(ReadTable.DEFAULT_READTABLE.getCharacterType(ch)
					== ReadTable.INVALID)
				{
					buf.append("\\u");
					String hex = Integer.toString(ch,16);
					buf.append("0000".substring(hex.length()));
					buf.append(hex);
				}
				else
					buf.append(ch);
			}
		}
		return buf.toString();
	} //}}}

	//{{{ unparseObject() method
	public static String unparseObject(Object obj)
	{
		// this is for string representations of lists and stacks
		if(obj == null || obj.equals(Boolean.FALSE))
			return "f";
		else if(obj.equals(Boolean.TRUE))
			return "t";
		else if(obj instanceof FactorWord)
		{
			FactorWord word = (FactorWord)obj;
			return (word.parsing != null ? "POSTPONE: " : "")
				+ word.toString();
		}
		else if(obj instanceof String)
			return '"' + charsToEscapes((String)obj) + '"';
		else if(obj instanceof Number
			|| obj instanceof FactorExternalizable)
			return obj.toString();
		else if(obj instanceof Character)
		{
			if(((Character)obj).charValue() == ' ')
				return "CHAR: \\s";
			else
				return "CHAR: " + charsToEscapes(obj.toString());
		}
		else
			return getUnreadableString(obj.toString());
	} //}}}

	//{{{ FactorReader constructor
	public FactorReader(
		String filename,
		BufferedReader in,
		VocabularyLookup lookup)
	{
		this(filename,in,false,lookup);
	} //}}}

	//{{{ FactorReader constructor
	public FactorReader(
		String filename,
		BufferedReader in,
		boolean alwaysDocComments,
		VocabularyLookup lookup)
	{
		this(new FactorScanner(filename,in),alwaysDocComments,lookup);
	} //}}}

	//{{{ FactorReader constructor
	public FactorReader(
		FactorScanner scanner,
		boolean alwaysDocComments,
		VocabularyLookup lookup)
	{
		this.lookup = lookup;
		this.scanner = scanner;
		pushState(toplevel,null);
		this.alwaysDocComments = alwaysDocComments;
		this.in = DefaultVocabularyLookup.DEFAULT_IN;
		this.use = DefaultVocabularyLookup.DEFAULT_USE;
	} //}}}

	//{{{ getScanner() method
	public FactorScanner getScanner()
	{
		return scanner;
	} //}}}

	//{{{ getIn() method
	public String getIn()
	{
		return in;
	} //}}}

	//{{{ setIn() method
	public void setIn(String in)
	{
		this.in = in;
	} //}}}

	//{{{ getUse() method
	public Cons getUse()
	{
		return use;
	} //}}}

	//{{{ setUse() method
	public void setUse(Cons use)
	{
		this.use = use;
	} //}}}

	//{{{ addUse() method
	public void addUse(String name)
	{
		setUse(new Cons(name,getUse()));
	} //}}}

	//{{{ parse() method
	/**
	 * Keeps parsing the input stream until EOF, and returns the
	 * parse tree.
	 */
	public Cons parse() throws Exception
	{
		scanner.nextLine();

		for(;;)
		{
			if(next())
			{
				// eof.
				return popState(toplevel,toplevel).first;
			}
		}
	} //}}}

	//{{{ searchVocabulary() method
	public FactorWord searchVocabulary(Cons use, String word)
		throws Exception
	{
		return lookup.searchVocabulary(use,word);
	} //}}}

	//{{{ intern() method
	public FactorWord intern(String name, boolean define)
		throws Exception
	{
		if(define)
			return lookup.define(getIn(),name);
		else
		{
			FactorWord word = searchVocabulary(getUse(),name);
			if(word == null)
				error("Undefined: " + name);
			return word;
		}
	} //}}}

	//{{{ nextWord() method
	/**
	 * Read a word from the scanner and intern it. Returns null on EOF.
	 */
	public FactorWord nextWord(boolean define) throws Exception
	{
		// remember the position before the word name
		int line = scanner.getLineNumber();
		int col = scanner.getColumnNumber();

		Object next = nextNonEOL(true,false);
		if(next instanceof Number)
		{
			scanner.error("Unexpected " + next);
			// can't happen
			return null;
		}
		else if(next instanceof String)
		{
			FactorWord w = intern((String)next,define);
			if(define && w != null)
			{
				w.line = line;
				w.col = col;
				w.file = scanner.getFileName();
				w.stackEffect = null;
				w.documentation = null;
			}
			return w;
		}
		else
			return null;
	} //}}}

	//{{{ next() method
	public Object next(
		boolean readNumbers,
		boolean start)
		throws IOException, FactorParseException
	{
		Object next = scanner.next(readNumbers,start,base);
		if(next == FactorScanner.EOL)
		{
			scanner.nextLine();
			return next(readNumbers,start);
		}
		else
			return next;
	} //}}}
	
	//{{{ nextNonEOL() method
	public Object nextNonEOL(
		boolean readNumbers,
		boolean start)
		throws IOException, FactorParseException
	{
		return scanner.nextNonEOL(readNumbers,start,base);
	} //}}}
	
	//{{{ next() method
	/**
	 * Read the next word and take some kind of action.
	 * Returns true if EOF, false otherwise.
	 */
	private boolean next() throws Exception
	{
		Object next = next(true,true);
		if(next == FactorScanner.EOF)
			return true;
		else if(next instanceof String)
		{
			FactorWord word = intern((String)next,false);
			if(word == null)
			{
				/* We're ignoring errors */
				return false;
			}

			if(word.parsing != null)
			{
				word.parsing.eval(this);
				return false;
			}
			append(word);
			return false;
		}
		else // its a number.
		{
			append(next);
			return false;
		}
	} //}}}

	//{{{ pushExclusiveState() method
	/**
	 * An exclusive state can only happen at the top level.
	 * For example, : ... ; definitions cannot be nested so they
	 * are exclusive.
	 */
	public void pushExclusiveState(FactorWord start, FactorWord defining)
		throws FactorParseException
	{
		if(getCurrentState().start != toplevel)
			scanner.error(start + " cannot be nested");
		pushState(start,defining);
	} //}}}

	//{{{ pushState() method
	/**
	 * Push a parser state, for example reading of a list.
	 */
	public void pushState(FactorWord start, FactorWord defining)
	{
		states = new Cons(new ParseState(start,defining),states);
	} //}}}

	//{{{ popState() method
	/**
	 * Pop a parser state, throw exception if it doesn't match the
	 * parameter.
	 */
	public ParseState popState(FactorWord start, FactorWord end)
		throws FactorParseException
	{
		ParseState state = getCurrentState();
		if(state.start != start)
			scanner.error(end + " does not close " + state.start);
		states = states.next();
		return state;
	} //}}}

	//{{{ getCurrentState() method
	public ParseState getCurrentState()
	{
		return (ParseState)states.car;
	} //}}}

	//{{{ append() method
	/**
	 * Append the given object to the current parse tree node.
	 */
	public void append(Object obj) throws FactorParseException
	{
		getCurrentState().append(obj);
	} //}}}

	//{{{ setStackComment() method
	public void setStackComment(String comment)
	{
		getCurrentState().setStackComment(comment);
	} //}}}

	//{{{ addDocComment() method
	public void addDocComment(String comment)
	{
		getCurrentState().addDocComment(comment);
	} //}}}

	//{{{ bar() method
	/**
	 * Sets the current parser state's cdr to the given object.
	 */
	public void bar() throws FactorParseException
	{
		getCurrentState().bar();
	} //}}}

	//{{{ error() method
	public void error(String msg) throws FactorParseException
	{
		scanner.error(msg);
	} //}}}

	//{{{ ParseState class
	public class ParseState
	{
		public FactorWord start;
		public FactorWord defining;
		public Cons first;
		public Cons last;
		private boolean bar;
		private boolean docComment;

		ParseState(FactorWord start, FactorWord defining)
		{
			docComment = start.docComment;
			this.start = start;
			this.defining = defining;
		}

		void append(Object obj) throws FactorParseException
		{
			docComment = false;

			if(bar)
			{
				if(last.cdr != null)
					scanner.error("Only one token allowed after |");
				last.cdr = obj;
			}
			else
			{
				Cons next = new Cons(obj,null);
				if(first == null)
					first = next;
				else
					last.cdr = next;
				last = next;
			}
		}

		void setStackComment(String comment)
		{
			if(defining != null && defining.stackEffect == null)
				defining.stackEffect = comment;
		}

		void addDocComment(String comment)
		{
			if(defining != null && (docComment || alwaysDocComments))
			{
				if(defining.documentation == null)
					defining.documentation = comment;
				else
				{
					/* Its O(n^2). Big deal. */
					defining.documentation = defining.documentation
						.concat(comment);
				}
			}
		}

		void bar() throws FactorParseException
		{
			if(last.cdr != null)
			{
				// We already read [ a | b
				// no more can be appended to this state.
				scanner.error("Only one token allowed after |");
			}

			bar = true;
		}
	} //}}}
}
