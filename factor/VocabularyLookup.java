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

package factor;

import factor.parser.*;
import java.io.*;
import java.util.*;

public class VocabularyLookup
{
	public static final int COMPLETE_START = 0;
	public static final int COMPLETE_ANYWHERE = 1;
	public static final int COMPLETE_EQUAL = 2;

	public static final Cons DEFAULT_USE = new Cons("syntax",new Cons("scratchpad",null));
	public static final String DEFAULT_IN = "scratchpad";

	/**
	 * Maps vocabulary names to vocabularies.
	 */
	private Map vocabularies;

	//{{{ VocabularyLookup constructor
	public VocabularyLookup()
	{
		vocabularies = new HashMap();

		/* comments */
		FactorWord lineComment = define("syntax","!");
		lineComment.parsing = new LineComment(lineComment);
		FactorWord stackComment = define("syntax","(");
		stackComment.parsing = new StackComment(stackComment);
		FactorWord docComment = define("syntax","#!");
		docComment.parsing = new LineComment(docComment);

		/* strings */
		FactorWord str = define("syntax","\"");
		str.parsing = new StringLiteral(str);
		FactorWord sbuf = define("syntax","SBUF\"");
		sbuf.parsing = new StringBufferLiteral(str);
		FactorWord ch = define("syntax","CHAR:");
		ch.parsing = new CharLiteral(ch);

		/* constants */
		FactorWord t = define("syntax","t");
		t.parsing = new T(t);
		FactorWord f = define("syntax","f");
		f.parsing = new F(f);
		FactorWord complex = define("syntax","#{");
		complex.parsing = new ComplexLiteral(complex,"}#");

		/* lists */
		FactorWord bra = define("syntax","[");
		bra.parsing = new Bra(bra);
		FactorWord ket = define("syntax","]");
		ket.parsing = new Ket(bra,ket);

		/* tuples */
		FactorWord beginTuple = define("syntax","<<");
		beginTuple.parsing = new Bra(beginTuple);
		FactorWord endTuple = define("syntax",">>");
		endTuple.parsing = new Ket(beginTuple,endTuple);

		/* conses */
		FactorWord beginCons = define("syntax","[[");
		beginCons.parsing = new BeginCons(beginCons);
		FactorWord endCons = define("syntax","]]");
		endCons.parsing = new EndCons(beginCons,endCons);

		/* vectors */
		FactorWord beginVector = define("syntax","{");
		beginVector.parsing = new BeginVector(beginVector);
		FactorWord endVector = define("syntax","}");
		endVector.parsing = new EndVector(beginVector,endVector);

		/* word defs */
		FactorWord def = define("syntax",":");
		def.parsing = new Def(def);
		FactorWord ine = define("syntax",";");
		ine.parsing = new Ine(ine);
		FactorWord symbol = define("syntax","SYMBOL:");
		symbol.parsing = new Definer(symbol);

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
		defer.parsing = new Definer(defer);
		FactorWord in = define("syntax","IN:");
		in.parsing = new In(in);
		FactorWord use = define("syntax","USE:");
		use.parsing = new Use(use);
		FactorWord using = define("syntax","USING:");
		using.parsing = new Using(using);

		FactorWord pushWord = define("syntax","\\");
		pushWord.parsing = new PushWord(pushWord);

		/* OOP */
		FactorWord generic = define("syntax","GENERIC:");
		generic.parsing = new Definer(generic);
		FactorWord beginMethod = define("syntax","M:");
		beginMethod.parsing = new BeginMethod(beginMethod);
		FactorWord beginConstructor = define("syntax","C:");
		beginConstructor.parsing = new BeginConstructor(beginConstructor);
		FactorWord beginPredicate = define("syntax","PREDICATE:");
		beginPredicate.parsing = new BeginPredicate(beginPredicate);
		FactorWord beginUnion = define("syntax","UNION:");
		beginUnion.parsing = new ClassDefinition(beginUnion);
		FactorWord beginBuiltin = define("syntax","BUILTIN:");
		beginBuiltin.parsing = new ClassDefinition(beginBuiltin);
		FactorWord tuple = define("syntax","TUPLE:");
		tuple.parsing = new Tuple(tuple);
		FactorWord primitive = define("syntax","PRIMITIVE:");
		primitive.parsing = new Primitive(primitive);
		
		/* Alien */
		FactorWord beginStruct = define("alien","BEGIN-STRUCT:");
		beginStruct.parsing = new BeginStruct(beginStruct);
		FactorWord endStruct = define("alien","END-STRUCT");
		endStruct.parsing = new EndStruct(beginStruct,endStruct);
		FactorWord field = define("alien","FIELD:");
		field.parsing = new Field(field);
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
			FactorWord word = new FactorWord(this,vocabulary,name);
			v.put(name,word);
			return word;
		}
	} //}}}

	//{{{ forget() method
	public void forget(FactorWord word)
	{
		Map vocab = (Map)vocabularies.get(word.vocabulary);
		if(vocab != null)
			vocab.remove(word.name);
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

	//{{{ getWordCompletions() method
	/**
	 * @param word A substring of the word name to complete
	 * @param mode One of COMPLETE_START, COMPLETE_ANYWHERE, or
	 * COMPLETE_EQUAL.
	 * @param completions Set to add completions to
	 */
	public FactorWord[] getWordCompletions(String word,
		int mode) throws Exception
	{
		Set s = new TreeSet();
		getWordCompletions(word,mode,s);
		return (FactorWord[])s.toArray(new FactorWord[s.size()]);
	} //}}}

	//{{{ getWordCompletions() method
	/**
	 * @param use A list of vocabularies.
	 * @param word A substring of the word name to complete
	 * @param mode One of COMPLETE_START, COMPLETE_ANYWHERE, or
	 * COMPLETE_EQUAL.
	 * @param completions Set to add completions to
	 */
	public void getWordCompletions(String word, int mode,
		Set completions) throws Exception
	{
		Cons use = getVocabularies();
		while(use != null)
		{
			String vocab = (String)use.car;
			getWordCompletions(vocab,word,mode,completions);
			use = use.next();
		}
	} //}}}

	//{{{ isCompletion() method
	public boolean isCompletion(String match, String against, int mode)
	{
		switch(mode)
		{
		case COMPLETE_START:
			return against.startsWith(match);
		case COMPLETE_ANYWHERE:
			return against.indexOf(match) != -1;
		case COMPLETE_EQUAL:
			return against.equals(match);
		default:
			throw new RuntimeException("Bad mode: " + mode);
		}
	} //}}}
	
	//{{{ getWordCompletions() method
	public void getWordCompletions(String vocab, String word, int mode,
		Set completions) throws Exception
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
					if(isCompletion(word,w.name,mode))
						completions.add(w);
				}
			}
		}
	} //}}}

	//{{{ getVocabCompletions() method
	/**
	 * @param vocab A string to complete
	 * @param anywhere If true, matches anywhere in the vocab name are
	 * returned; otherwise, only matches from beginning.
	 */
	public String[] getVocabCompletions(String vocab, boolean anywhere)
		throws Exception
	{
		List completions = new ArrayList();
		Cons vocabs = getVocabularies();
		while(vocabs != null)
		{
			String v = (String)vocabs.car;
			if(isCompletion(vocab,v,anywhere
				? COMPLETE_ANYWHERE
				: COMPLETE_START))
				completions.add(v);
			vocabs = vocabs.next();
		}

		return (String[])completions.toArray(new String[completions.size()]);
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
