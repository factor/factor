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
	private FactorWord toplevel = new FactorWord("#<EOF>");
	private boolean alwaysDocComments;

	//{{{ parseObject() method
	/**
	 * Parse the given string. It must be a single literal object.
	 * The object is returned.
	 */
	public static Object parseObject(String input, FactorInterpreter interp)
		throws FactorParseException
	{
		try
		{
			FactorReader parser = new FactorReader(
				"parseObject()",new StringReader(input),
				interp,true);
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
			case '\n':
				buf.append("\\n");
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
		else if(obj instanceof String)
			return '"' + charsToEscapes((String)obj) + '"';
		else if(obj instanceof Number
			|| obj instanceof FactorExternalizable)
			return obj.toString();
		else if(obj instanceof Character)
			return "#\\" + ((Character)obj).charValue();
		else
			return getUnreadableString(obj.toString());
	} //}}}

	//{{{ FactorReader constructor
	public FactorReader(String filename, Reader in,
		FactorInterpreter interp)
	{
		this(filename,in,interp,false);
	} //}}}

	//{{{ FactorReader constructor
	public FactorReader(String filename, Reader in,
		FactorInterpreter interp, boolean alwaysDocComments)
	{
		this.interp = interp;

		this.alwaysDocComments = alwaysDocComments;

		ReadTable readtable = new ReadTable();

		readtable.setCharacterType('\t',ReadTable.WHITESPACE);
		readtable.setCharacterType('\n',ReadTable.WHITESPACE);
		readtable.setCharacterType((char)12,ReadTable.WHITESPACE); // ^L
		readtable.setCharacterType('\r',ReadTable.WHITESPACE);
		readtable.setCharacterType(' ',ReadTable.WHITESPACE);

		readtable.setCharacterType('!',ReadTable.CONSTITUENT);
		readtable.setCharacterType('"',ReadTable.DISPATCH);
		readtable.setCharacterType('#',ReadTable.DISPATCH);
		readtable.setCharacterType('$',ReadTable.DISPATCH);
		readtable.setCharacterRange('%','?',ReadTable.CONSTITUENT);
		readtable.setCharacterType('@',ReadTable.DISPATCH);
		readtable.setCharacterRange('A','[',ReadTable.CONSTITUENT);
		readtable.setCharacterType('\\',ReadTable.SINGLE_ESCAPE);
		readtable.setCharacterRange(']','{',ReadTable.CONSTITUENT);
		readtable.setCharacterType('|',ReadTable.DISPATCH);
		readtable.setCharacterRange('}','~',ReadTable.CONSTITUENT);

		// XXX:
		readtable.setCharacterType('!',ReadTable.DISPATCH);
		readtable.setCharacterType('(',ReadTable.DISPATCH);

		scanner = new FactorScanner(interp,filename,in,readtable);

		pushState(toplevel);
	} //}}}

	//{{{ getScanner() method
	public FactorScanner getScanner()
	{
		return scanner;
	} //}}}

	//{{{ parse() method
	/**
	 * Keeps parsing the input stream until EOF, and returns the
	 * parse tree.
	 */
	public Cons parse() throws IOException, FactorParseException
	{
		for(;;)
		{
			if(next())
			{
				// eof.
				return popState(toplevel,toplevel);
			}
		}
	} //}}}

	//{{{ next() method
	/**
	 * Read the next word and take some kind of action.
	 * Returns true if EOF, false otherwise.
	 */
	private boolean next() throws IOException, FactorParseException
	{
		Object next = scanner.next(true,true);
		if(next == FactorScanner.EOF)
			return true;

		if(next instanceof FactorWord)
		{
			FactorWord word = (FactorWord)next;
			if(word.parsing != null)
			{
				word.parsing.eval(interp,this);
				return false;
			}
		}

		append(next);
		return false;
	} //}}}

	//{{{ pushExclusiveState() method
	/**
	 * An exclusive state can only happen at the top level.
	 * For example, : ... ; definitions cannot be nested so they
	 * are exclusive.
	 */
	public void pushExclusiveState(FactorWord start)
		throws FactorParseException
	{
		if(getCurrentState().start != toplevel)
			scanner.error(start + " cannot be nested");
		pushState(start);
	} //}}}

	//{{{ pushState() method
	/**
	 * Push a parser state, for example reading of a list.
	 */
	public void pushState(FactorWord start)
	{
		states = new Cons(new ParseState(start),states);
	} //}}}

	//{{{ popState() method
	/**
	 * Pop a parser state, throw exception if it doesn't match the
	 * parameter.
	 */
	public Cons popState(FactorWord start, FactorWord end)
		throws FactorParseException
	{
		ParseState state = getCurrentState();
		if(state.start != start)
		{
			scanner.error(end + " does not close " + state.start);
		}
		states = states.next();
		return state.first;
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

	//{{{ comma() method
	/**
	 * Sets the current parser state's cdr to the given object.
	 */
	public void comma() throws FactorParseException
	{
		getCurrentState().comma();
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
		public Cons first;
		public Cons last;
		private boolean comma;
		private boolean docComment;

		ParseState(FactorWord start)
		{
			this.start = start;
			try
			{
				this.docComment
					= (start.getNamespace(interp)
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
					scanner.error("Only one token allowed after ,");
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

		void comma() throws FactorParseException
		{
			if(last.cdr != null)
			{
				// We already read [ a , b
				// no more can be appended to this state.
				scanner.error("Only one token allowed after ,");
			}

			comma = true;
		}
	} //}}}
}
