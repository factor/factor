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

package factor.compiler;

import factor.*;

public class RecursiveState implements PublicCloneable
{
	private Cons words;

	//{{{ RecursiveState constructor
	public RecursiveState()
	{
	} //}}}

	//{{{ RecursiveState constructor
	public RecursiveState(RecursiveState clone)
	{
		if(clone.words != null)
			words = clone.words;
	} //}}}

	//{{{ add() method
	public void add(FactorWord word, StackEffect effect,
		String className, FactorClassLoader loader, String method)
	{
		add(word,effect,className,loader,method,
			words == null ? null : last());
	} //}}}

	//{{{ add() method
	public void add(FactorWord word, StackEffect effect,
		String className, FactorClassLoader loader, String method,
		RecursiveForm next)
	{
		if(get(word) != null)
		{
			throw new RuntimeException("Calling add() twice on " + word);
		}

		RecursiveForm newForm = new RecursiveForm(
			word,effect,className,loader,method);
		words = new Cons(newForm,words);
		newForm.next = next;
	} //}}}

	//{{{ remove() method
	public void remove(FactorWord word)
	{
		//System.err.println(this + ": removing " + word);
		if(last().word != word)
			throw new RuntimeException("Expected " + word + ", found " + last().word);
		words = words.next();
	} //}}}

	//{{{ get() method
	public RecursiveForm get(FactorWord word)
	{
		if(words != null)
		{
			RecursiveForm iter = last();
			while(iter != null)
			{
				if(iter.word == word)
					return iter;
				iter = iter.next;
			}
		}

		return null;
	} //}}}

	//{{{ last() method
	public RecursiveForm last()
	{
		return (RecursiveForm)words.car;
	} //}}}

	//{{{ lastCallable() method
	public RecursiveForm lastCallable()
	{
		RecursiveForm word = (RecursiveForm)words.car;
		while(word != null)
		{
			if(word.callable)
				return word;
			word = word.next;
		}
		return null;
	} //}}}

	//{{{ allTails() method
	/**
	 * Returns if all forms from the given form upward are at their tail,
	 * so that we can do a direct GOTO to the given form to recurse on it.
	 */
	public boolean allTails(RecursiveForm form)
	{
		Cons iter = words;
		for(;;)
		{
			if(!((RecursiveForm)iter.car).tail)
				return false;
			if(iter.car == form)
				return true;
			iter = iter.next();
		}
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return FactorReader.unparseObject(words);
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		return new RecursiveState(this);
	} //}}}
}
