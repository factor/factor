/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2003, 2004 Slava Pestov.
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

import factor.jedit.FactorWordRenderer;

public class FactorWord extends FactorArtifact implements FactorExternalizable,
	Comparable
{
	public String vocabulary;
	public String name;
	public String stackEffect;
	public String documentation;

	/**
	 * Parsing word definition.
	 */
	public FactorParsingDefinition parsing;

	private VocabularyLookup lookup;
	
	/**
	 * For browsing, the parsing word that was used to define this word.
	 */
	private FactorWord definer;

	//{{{ FactorWord constructor
	public FactorWord(VocabularyLookup lookup,
		String vocabulary, String name)
	{
		this.lookup = lookup;
		this.vocabulary = vocabulary;
		this.name = name;
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return name == null ? "#<unnamed>" : name;
	} //}}}
	
	//{{{ getDefiner() method
	public FactorWord getDefiner()
	{
		if(definer == null)
			return new FactorWord(lookup,null,"DEFER:");
		else
			return definer;
	} //}}}

	//{{{ setDefiner() method
	public void setDefiner(FactorWord definer)
	{
		this.definer = definer;
	} //}}}
	
	//{{{ getShortString() method
	public String getShortString()
	{
		return name;
	} //}}}
	
	//{{{ getLongString() method
	public String getLongString()
	{
		return FactorWordRenderer.getWordHTMLString(this,false);
	} //}}}

	//{{{ forget() method
	public void forget()
	{
		/* Not allowed to forget parsing words, since that confuses our
		parser */
		if(parsing != null)
			return;
		
		lookup.forget(this);
	} //}}}

	//{{{ compareTo() method
	public int compareTo(Object o)
	{
		int c = name.compareTo(((FactorWord)o).name);
		if(c == 0)
		{
			return String.valueOf(vocabulary)
				.compareTo(String.valueOf(
				((FactorWord)o).vocabulary));
		}
		else
			return c;
	} //}}}
}
