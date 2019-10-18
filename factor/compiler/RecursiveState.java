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

public class RecursiveState
{
	private Cons words;

	//{{{ RecursiveState constructor
	public RecursiveState()
	{
	} //}}}

	//{{{ RecursiveState constructor
	public RecursiveState(RecursiveState clone)
	{
		words = clone.words;
	} //}}}

	//{{{ add() method
	public void add(FactorWord word, StackEffect effect)
	{
		//System.err.println(this + ": adding " + word);
		//System.err.println(words);
		if(get(word) != null)
		{
			//System.err.println("throwing exception");
			throw new RuntimeException("Calling add() twice on " + word);
		}
		words = new Cons(new RecursiveForm(word,effect),words);
	} //}}}

	//{{{ remove() method
	public void remove(FactorWord word)
	{
		//System.err.println(this + ": removing " + word);
		if(last().word != word)
			throw new RuntimeException("Unbalanced add()/remove()");
		words = words.next();
	} //}}}

	//{{{ get() method
	public RecursiveForm get(FactorWord word)
	{
		Cons iter = words;
		while(iter != null)
		{
			RecursiveForm form = (RecursiveForm)iter.car;
			//System.err.println(form.word + "==?" + word);
			if(form.word == word)
				return form;
			iter = iter.next();
		}

		return null;
	} //}}}

	//{{{ last() method
	public RecursiveForm last()
	{
		return (RecursiveForm)words.car;
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return FactorParser.unparse(words);
	} //}}}
}
