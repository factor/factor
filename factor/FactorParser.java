/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2003 Slava Pestov.
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
import java.util.HashMap;

public class FactorParser
{
	private static final Object EOF = new Object();

	private FactorWord DEF;
	private FactorWord INE;

	private FactorWord SHU;
	private FactorWord F;
	private FactorWord FLE;

	private FactorWord DEFINE;

	private FactorWord BRA;
	private FactorWord KET;

	private FactorWord COMMA;

	private String filename;
	private Reader in;
	private FactorDictionary dict;
	private StreamTokenizer st;

	// sometimes one token is expanded into two words
	private Object next;

	//{{{ FactorParser constructor
	public FactorParser(String filename, Reader in, FactorDictionary dict)
	{
		this.filename = (filename == null ? "<eval>" : filename);
		this.in = in;
		this.dict = dict;

		DEF = dict.intern(":");
		INE = dict.intern(";");

		SHU = dict.intern("~<<");
		F = dict.intern("--");
		FLE = dict.intern(">>~");

		DEFINE = dict.intern("define");

		BRA = dict.intern("[");
		KET = dict.intern("]");

		COMMA = dict.intern(",");

		st = new StreamTokenizer(in);
		st.resetSyntax();
		st.whitespaceChars(0,' ');
		/* all printable ASCII characters */
		st.wordChars('#','~');
		st.wordChars('0','9');
		st.commentChar('!');
		st.quoteChar('"');
		st.commentChar('(');
		st.eolIsSignificant(false);
	} //}}}

	//{{{ isParsingWord() method
	private boolean isParsingWord(Object word)
	{
		return word == DEF
			|| word == INE
			|| word == SHU
			|| word == FLE
			|| word == BRA
			|| word == KET
			|| word == COMMA;
	} //}}}

	//{{{ parse() method
	/**
	 * Reads the file being parsed, and returns a list of all tokens that
	 * were read in. This list can be evaluated to run the file.
	 */
	public FactorList parse() throws IOException, FactorParseException
	{
		FactorList first = null;
		FactorList last = null;

		try
		{
			for(;;)
			{
				Object next = next();
				if(next == EOF)
					return first;
				/* : foo bar baz ; is equivalent to
				   "foo" [ bar baz ] define */
				else if(next == DEF)
				{
					Object obj = next();
					if(!(obj instanceof FactorWord)
						|| isParsingWord(obj))
					{
						error("Expected word name after " + next);
					}

					FactorWordDefinition def = readDef();

					FactorList l = new FactorList(DEFINE,null);
					FactorList cons = new FactorList(
						((FactorWord)obj).name,
						new FactorList(def,l));
					if(first == null)
						first = cons;
					else
						last.cdr = cons;
					last = l;
				}
				else if(next == SHU)
				{
					Object obj = next();
					if(!(obj instanceof FactorWord)
						|| isParsingWord(obj))
					{
						error("Expected word name after " + next);
					}

					FactorWordDefinition def = readShuffle();

					FactorList l = new FactorList(DEFINE,null);
					FactorList cons = new FactorList(
						((FactorWord)obj).name,
						new FactorList(def,l));
					if(first == null)
						first = cons;
					else
						last.cdr = cons;
					last = l;
				}
				else if(next == BRA)
				{
					FactorList cons = new FactorList(
						readList(),null);
					if(first == null)
						first = cons;
					else
						last.cdr = cons;
					last = cons;
				}
				else if(isParsingWord(next))
				{
					error("Unexpected " + next);
				}
				else
				{
					FactorList cons = new FactorList(next,null);
					if(first == null)
						first = cons;
					else
						last.cdr = cons;
					last = cons;
				}
			}
		}
		finally
		{
			try
			{
				in.close();
			}
			catch(IOException io)
			{
			}
		}
	} //}}}

	//{{{ next() method
	private Object next() throws IOException, FactorParseException
	{
		if(next != null)
		{
			Object _next = next;
			next = null;
			return _next;
		}

		int type = st.nextToken();
		switch(type)
		{
		case StreamTokenizer.TT_EOF:
			return EOF;
		case StreamTokenizer.TT_WORD:
			boolean number = true;
			boolean floating = false;
			boolean exponent = false;

			for(int i = 0; i < st.sval.length(); i++)
			{
				char ch = st.sval.charAt(i);
				if(ch == '-')
				{
					if((i != 0 && Character.toLowerCase(
						st.sval.charAt(i - 1))
						!= 'e') || st.sval.length() == 1)
					{
						number = false;
						break;
					}
				}
				else if((ch == 'e' || ch == 'E')
					&& st.sval.length() != 1)
				{
					if(exponent)
					{
						number = false;
						break;
					}
					else
						exponent = true;
				}
				else if(ch == '.' && st.sval.length() != 1)
				{
					if(floating)
					{
						number = false;
						break;
					}
					else
						floating = true;
				}
				else if(!Character.isDigit(ch))
				{
					number = false;
					break;
				}
			}

			if(number)
			{
				if(floating || exponent)
					return new Float(st.sval);
				else
					return new Integer(st.sval);
			}

			if(st.sval.length() == 1)
			{
				switch(st.sval.charAt(0))
				{
				case 'f':
					return null;
				case 't':
					return Boolean.TRUE;
				}
			}
			else if(st.sval.startsWith("#\\"))
				return toChar(st.sval.substring(2));
			else
			{
				// $foo is expanded into "foo" $
				if(st.sval.charAt(0) == '$')
				{
					next = dict.intern("$");
					return st.sval.substring(1);
				}
				// @foo is expanded into "foo" @
				else if(st.sval.charAt(0) == '@')
				{
					next = dict.intern("@");
					return st.sval.substring(1);
				}
			}

			// |foo is the same as "foo"
			if(st.sval.charAt(0) == '|')
				return st.sval.substring(1);

			return dict.intern(st.sval);
		case '"': case '\'':
			return st.sval;
		default:
			throw new FactorParseException(filename,
				st.lineno(),"Unknown error: " + type);
		}
	} //}}}

	//{{{ toChar() method
	private Character toChar(String spec) throws FactorParseException
	{
		if(spec.length() != 1)
			error("Not a character literal: #\\" + spec);
		return new Character(spec.charAt(0));
	} //}}}

	//{{{ readDef() method
	/**
	 * Read list until ;.
	 */
	private FactorWordDefinition readDef()
		throws IOException, FactorParseException
	{
		return new FactorCompoundDefinition(readList(INE,false));
	} //}}}

	//{{{ readShuffle() method
	/**
	 * Shuffle notation looks like this:
	 * ~<< a b -- b a >>~
	 * On the left is inputs, on the right is their arrangement on the
	 * stack.
	 */
	private FactorWordDefinition readShuffle()
		throws IOException, FactorParseException
	{
		// 0 in consume map is last consumed, n is first consumed.
		HashMap consumeMap = new HashMap();
		int consumeD = 0;
		int consumeR = 0;

		for(;;)
		{
			Object next = next();
			if(next == EOF)
				error("Unexpected EOF");
			if(next == F)
				break;
			else if(next instanceof FactorWord)
			{
				String name = ((FactorWord)next).name;
				int counter;
				if(name.startsWith("r:"))
				{
					next = dict.intern(name.substring(2));
					counter = (FactorShuffleDefinition
						.FROM_R_MASK
						| consumeR++);
				}
				else
					counter = consumeD++;

				Object existing = consumeMap.put(next,
					new Integer(counter));
				if(existing != null)
					error("Appears twice in shuffle LHS: " + next);
			}
			else
			{
				error("Unexpected " + FactorJava.factorTypeToString(
					next));
			}
		}

		FactorList _shuffle = readList(FLE,false);

		int consume = consumeMap.size();

		if(_shuffle == null)
		{
			return new FactorShuffleDefinition(consumeD,consumeR,
				null,0,null,0);
		}

		int[] shuffle = new int[_shuffle.length()];

		int shuffleDlength = 0;
		int shuffleRlength = 0;

		int i = 0;
		while(_shuffle != null)
		{
			if(_shuffle.car instanceof FactorWord)
			{
				FactorWord word = ((FactorWord)_shuffle.car);
				String name = word.name;
				if(name.startsWith("r:"))
					word = dict.intern(name.substring(2));

				Integer _index = (Integer)consumeMap.get(word);
				if(_index == null)
					error("Does not appear in shuffle LHS: " + _shuffle.car);
				int index = _index.intValue();

				if(name.startsWith("r:"))
				{
					shuffleRlength++;
					shuffle[i++] = (index
						| FactorShuffleDefinition
						.TO_R_MASK);
				}
				else
				{
					shuffleDlength++;
					shuffle[i++] = index;
				}
			}
			else
			{
				error("Unexpected " + FactorJava.factorTypeToString(
					_shuffle.car));
			}
			_shuffle = _shuffle.next();
		}

		int[] shuffleD = new int[shuffleDlength];
		int[] shuffleR = new int[shuffleRlength];
		int j = 0, k = 0;
		for(i = 0; i < shuffle.length; i++)
		{
			int index = shuffle[i];
			if((index & FactorShuffleDefinition.TO_R_MASK)
				== FactorShuffleDefinition.TO_R_MASK)
			{
				index = (index
					& ~FactorShuffleDefinition.TO_R_MASK);
				shuffleR[j++] = index;
			}
			else
				shuffleD[k++] = index;
		}

		return new FactorShuffleDefinition(consumeD,consumeR,
			shuffleD,shuffleDlength,shuffleR,shuffleRlength);
	} //}}}

	//{{{ readList() method
	/**
	 * Read list until ].
	 */
	private FactorList readList()
		throws IOException, FactorParseException
	{
		return readList(KET,true);
	} //}}}

	//{{{ readList() method
	/**
	 * Read list until a given word.
	 */
	private FactorList readList(FactorWord until, boolean allowCommaPair)
		throws IOException, FactorParseException
	{
		FactorList first = null;
		FactorList last = null;

		for(;;)
		{
			Object next = next();
			if(next == until)
				return first;
			else if(next == EOF)
			{
				error("Unexpected EOF");
			}
			// read a dotted pair
			else if(allowCommaPair && next == COMMA)
			{
				if(first == null)
				{
					error("Expected at least 1 word before  " + next);
				}

				next = next();
				if(next == BRA)
				{
					last.cdr = readList();
					next = next();
					if(next == EOF)
						error("Unexpected EOF");
					else if(next != KET)
						error("Expected 1 word after ,");
					return first;
				}
				else if(next != EOF && !isParsingWord(next))
				{
					last.cdr = next;
					next = next();
					if(next == until)
						return first;
				}

				error("Expected 1 word after ,");
			}
			else if(next == BRA)
			{
				FactorList list = readList();
				if(first == null)
					first = last = new FactorList(list,null);
				else
				{
					FactorList nextList = new FactorList(list,null);
					last.cdr = nextList;
					last = nextList;
				}
			}
			else if(isParsingWord(next))
				error("Unexpected " + next);
			else if(first == null)
				first = last = new FactorList(next,null);
			else
			{
				FactorList nextList = new FactorList(next,null);
				last.cdr = nextList;
				last = nextList;
			}
		}
	} //}}}

	//{{{ error() method
	private void error(String msg) throws FactorParseException
	{
		throw new FactorParseException(filename,st.lineno(),msg);
	} //}}}
}
