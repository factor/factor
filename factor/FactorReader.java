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
	private FactorInterpreter interp;
	private FactorScanner scanner;
	private Cons states;

	/**
	 * Top level of parse tree.
	 */
	private FactorWord toplevel = new FactorWord(null,"#<EOF>");
	private boolean alwaysDocComments;

	// if interactive, use interp.use & interp.in instead of below two
	private boolean interactive;
	private Cons use;
	private String in;

	private int base = 10;
	
	//{{{ parseObject() method
	/**
	 * Parse the given string. It must be a single literal object.
	 * The object is returned.
	 */
	public static Object parseObject(String input, FactorInterpreter interp)
		throws Exception
	{
		try
		{
			FactorReader parser = new FactorReader(
				"parseObject()",
				new BufferedReader(new StringReader(input)),
				true,false,interp);
			Cons parsed = parser.parse();
			if(parsed.cdr != null)
			{
				// not a single literal
				throw new FactorParseException("parseObject()",
					1,"Not a literal: " + input);
			}
			return parsed.car;
		}
		catch(IOException io)
		{
			// can't happen!
			throw new FactorParseException("parseObject()",1,
				io.toString());
		}
	} //}}}

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

	//{{{ getVocabularyDeclaration() method
	/**
	 * Return a string of USE: declarations for the given object.
	 */
	public static String getVocabularyDeclaration(Object obj)
	{
		StringBuffer buf = new StringBuffer();
		Set vocabs = getAllVocabularies(obj);
		Iterator iter = vocabs.iterator();
		while(iter.hasNext())
		{
			String name = (String)iter.next();
			buf.append("USE: ").append(name).append('\n');
		}
		return buf.toString();
	} //}}}

	//{{{ getAllVocabularies() method
	/**
	 * Return a set of all vocabularies referenced in the given quotation.
	 */
	public static Set getAllVocabularies(Object obj)
	{
		Set set = new TreeSet();
		getAllVocabularies(obj,set);
		return set;
	} //}}}

	//{{{ getAllVocabularies() method
	/**
	 * Return a set of all vocabularies referenced in the given quotation.
	 */
	private static void getAllVocabularies(Object obj, Set set)
	{
		if(obj instanceof FactorWord)
		{
			String vocab = ((FactorWord)obj).vocabulary;
			if(vocab != null)
				set.add(vocab);
		}
		else if(obj instanceof Cons)
		{
			Cons quotation = (Cons)obj;

			while(quotation != null)
			{
				getAllVocabularies(quotation.car,set);
				if(quotation.car instanceof Cons)
					getAllVocabularies((Cons)quotation.car,set);
				if(quotation.cdr instanceof Cons)
					quotation = quotation.next();
				else
				{
					getAllVocabularies(quotation.cdr,set);
					return;
				}
			}
		}
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
		FactorInterpreter interp)
	{
		this(filename,in,false,false,interp);
	} //}}}

	//{{{ FactorReader constructor
	public FactorReader(
		String filename,
		BufferedReader in,
		boolean alwaysDocComments,
		boolean interactive,
		FactorInterpreter interp)
	{
		this(new FactorScanner(filename,in),alwaysDocComments,
			interactive,interp);
	} //}}}

	//{{{ FactorReader constructor
	public FactorReader(
		FactorScanner scanner,
		boolean alwaysDocComments,
		boolean interactive,
		FactorInterpreter interp)
	{
		this.interp = interp;
		this.scanner = scanner;
		pushState(toplevel,null);
		this.alwaysDocComments = alwaysDocComments;
		this.interactive = interactive;
		this.in = FactorInterpreter.DEFAULT_IN;
		this.use = FactorInterpreter.DEFAULT_USE;
	} //}}}

	//{{{ getScanner() method
	public FactorScanner getScanner()
	{
		return scanner;
	} //}}}

	//{{{ getIn() method
	public String getIn()
	{
		if(interactive)
			return interp.in;
		else
			return in;
	} //}}}

	//{{{ setIn() method
	public void setIn(String in) throws Exception
	{
		if(interactive)
			interp.in = in;
		else
			this.in = in;

		if(interp.getVocabulary(in) == null)
			interp.defineVocabulary(in);
	} //}}}

	//{{{ getUse() method
	public Cons getUse()
	{
		if(interactive)
			return interp.use;
		else
			return use;
	} //}}}

	//{{{ setUse() method
	public void setUse(Cons use)
	{
		if(interactive)
			interp.use = use;
		else
			this.use = use;
	} //}}}

	//{{{ addUse() method
	public void addUse(String name) throws Exception
	{
		if(interp.getVocabulary(name) == null)
			error("Undefined vocabulary: " + name);

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

	//{{{ intern() method
	public FactorWord intern(String name, boolean define)
		throws Exception
	{
		if(define)
			return interp.define(getIn(),name);
		else
		{
			FactorWord word = interp.searchVocabulary(
				getUse(),name);
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
			FactorWord word = intern((String)next,
				!getCurrentState().warnUndefined);
			if(word == null)
			{
				/* We're ignoring errors */
				return false;
			}

			if(word.parsing != null)
			{
				word.parsing.eval(interp,this);
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
	 *
	 * @param args Parsing words can use this to store arbitrary info
	 */
	public void pushExclusiveState(FactorWord start, Object args)
		throws FactorParseException
	{
		if(getCurrentState().start != toplevel)
			scanner.error(start + " cannot be nested");
		pushState(start,args);
	} //}}}

	//{{{ pushState() method
	/**
	 * Push a parser state, for example reading of a list.
	 */
	public void pushState(FactorWord start, Object args)
	{
		states = new Cons(new ParseState(start,args),states);
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
		public Object arg;
		public Cons first;
		public Cons last;
		public boolean warnUndefined;
		private boolean comma;
		private boolean docComment;

		ParseState(FactorWord start, Object arg)
		{
			warnUndefined = true;
			this.start = start;
			this.arg = arg;
			try
			{
				this.docComment
					= (start.getNamespace()
					.getVariable("doc-comments")
					!= null);
			}
			catch(Exception e)
			{
				throw new RuntimeException(e);
			}
		}

		void append(Object obj) throws FactorParseException
		{
			boolean docComment = (this.docComment
				|| alwaysDocComments);
			// In a doc comment context, first object is always
			// a word, then followed by doc comments, then followed
			// by code.
			if(docComment && !(obj instanceof FactorDocComment)
				&& first != null)
			{
				this.docComment = false;
			}
			else if(!docComment && obj instanceof FactorDocComment)
			{
				//scanner.error("Documentation comment not allowed here");
				return;
			}

			if(comma)
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

		void bar() throws FactorParseException
		{
			if(last.cdr != null)
			{
				// We already read [ a | b
				// no more can be appended to this state.
				scanner.error("Only one token allowed after |");
			}

			comma = true;
		}
	} //}}}
}
