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

import factor.parser.*;
import java.io.*;
import java.util.*;

public class DefaultVocabularyLookup implements VocabularyLookup
{
	public static final Cons DEFAULT_USE = new Cons("syntax",new Cons("scratchpad",null));
	public static final String DEFAULT_IN = "scratchpad";

	/**
	 * Maps vocabulary names to vocabularies.
	 */
	private Map vocabularies;

	//{{{ DefaultVocabularyLookup constructor
	public DefaultVocabularyLookup()
	{
		vocabularies = new HashMap();

		/* comments */
		FactorWord lineComment = define("syntax","!");
		lineComment.parsing = new LineComment(lineComment,false);
		FactorWord stackComment = define("syntax","(");
		stackComment.parsing = new StackComment(stackComment);
		FactorWord docComment = define("syntax","#!");
		docComment.parsing = new LineComment(docComment,true);

		/* strings */
		FactorWord str = define("syntax","\"");
		str.parsing = new StringLiteral(str,true);
		FactorWord ch = define("syntax","CHAR:");
		ch.parsing = new CharLiteral(ch);

		/* constants */
		FactorWord t = define("syntax","t");
		t.parsing = new T(t);
		FactorWord f = define("syntax","f");
		f.parsing = new F(f);
		FactorWord complex = define("syntax","#{");
		complex.parsing = new ComplexLiteral(complex,"}");

		/* lists */
		FactorWord bra = define("syntax","[");
		bra.parsing = new Bra(bra);
		FactorWord ket = define("syntax","]");
		ket.parsing = new Ket(bra,ket);
		FactorWord bar = define("syntax","|");
		bar.parsing = new Bar(bar);

		/* vectors */
		FactorWord beginVector = define("syntax","{");
		beginVector.parsing = new BeginVector(beginVector);
		FactorWord endVector = define("syntax","}");
		endVector.parsing = new EndVector(beginVector,endVector);

		/* word defs */
		FactorWord def = define("syntax",":");
		def.parsing = new Def(def);
		def.docComment = true;
		FactorWord ine = define("syntax",";");
		ine.parsing = new Ine(def,ine);
		FactorWord symbol = define("syntax","SYMBOL:");
		symbol.parsing = new Symbol(symbol);

		/* reading numbers with another base */
		FactorWord bin = define("syntax","BIN:");
		bin.parsing = new Base(bin,2);
		FactorWord oct = define("syntax","OCT:");
		oct.parsing = new Base(oct,8);
		FactorWord hex = define("syntax","HEX:");
		hex.parsing = new Base(hex,16);

		/* vocabulary parsing words */
		FactorWord noParsing = define("syntax","POSTPONE:");
		noParsing.parsing = new NoParsing(noParsing);
		FactorWord defer = define("syntax","DEFER:");
		defer.parsing = new Defer(defer);
		FactorWord in = define("syntax","IN:");
		in.parsing = new In(in);
		FactorWord use = define("syntax","USE:");
		use.parsing = new Use(use);

		FactorWord pushWord = define("syntax","\\");
		pushWord.parsing = new PushWord(pushWord);
	} //}}}

	//{{{ getVocabulary() method
	public Map getVocabulary(String name)
	{
		return (Map)vocabularies.get(name);
	} //}}}

	//{{{ searchVocabulary() method
	/**
	 * Search in the given vocabulary for the given word.
	 */
	public FactorWord searchVocabulary(String vname, String name)
	{
		Map v = getVocabulary(vname);
		if(v != null)
			return (FactorWord)v.get(name);
		else
			return null;
	} //}}}

	//{{{ searchVocabulary() method
	/**
	 * Search through the given vocabulary list for the given word.
	 */
	public FactorWord searchVocabulary(Cons vocabulary, String name)
	{
		while(vocabulary != null)
		{
			FactorWord word = searchVocabulary(
				(String)vocabulary.car,name);
			if(word != null)
				return word;

			vocabulary = vocabulary.next();
		}

		return null;
	} //}}}

	//{{{ define() method
	/**
	 * Define a word in the given vocabulary if it doesn't exist already.
	 */
	public FactorWord define(String vocabulary, String name)
	{
		Map v = getVocabulary(vocabulary);
		if(v == null)
		{
			v = new HashMap();
			vocabularies.put(vocabulary,v);
		}
		Object value = v.get(name);
		if(value instanceof FactorWord)
			return (FactorWord)value;
		else
		{
			// save to same workspace as vocabulary,
			// or no workspace if vocabulary is builtins
			FactorWord word = new FactorWord(vocabulary,name);
			v.put(name,word);
			return word;
		}
	} //}}}

	//{{{ getVocabularies() method
	public Cons getVocabularies()
	{
		Cons vocabs = null;
		Iterator iter = vocabularies.keySet().iterator();
		while(iter.hasNext())
			vocabs = new Cons(iter.next(),vocabs);
		return vocabs;
	} //}}}

	//{{{ getCompletions() method
	public void getCompletions(String vocab, String word, Set completions,
		boolean anywhere)
	{
		Map v = (Map)vocabularies.get(vocab);
		if(v == null)
			return;

		Iterator words = v.values().iterator();

		while(words.hasNext())
		{
			FactorWord w = (FactorWord)words.next();
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
		}
	} //}}}

	//{{{ parseObject() method
	public Cons parseObject(String source) throws Exception
	{
		FactorReader parser = new FactorReader(
			"parseObject()",
			new BufferedReader(new StringReader(source)),
			true,this);
		return parser.parse();
	} //}}}
}
