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

package factor.primitives;

import factor.compiler.*;
import factor.*;
import java.util.Map;

public class Define extends FactorPrimitiveDefinition
{
	//{{{ Define constructor
	public Define(FactorWord word)
	{
		super(word);
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		FactorDataStack datastack = interp.datastack;
		Object def = datastack.pop();
		Object name = datastack.pop();
		core(interp,name,def);
	} //}}}

	//{{{ core() method
	public static void core(FactorInterpreter interp,
		Object name, Object def) throws Exception
	{
		// name: either a string or a word
		FactorWord newWord;
		if(name instanceof FactorWord)
			newWord = (FactorWord)name;
		else
			newWord = interp.intern((String)name);

		if(def instanceof Cons)
		{
			// old-style compound definition.
			def = new FactorCompoundDefinition(
				newWord,(Cons)def);
		}
		else if(def instanceof String)
		{
			// a class name...
			def = CompiledDefinition.create(interp,newWord,
				Class.forName((String)def));
		}

		newWord.define((FactorWordDefinition)def);
		interp.last = newWord;
	} //}}}

	//{{{ getStackEffect() method
	public void getStackEffect(RecursiveState recursiveCheck,
		FactorCompiler state) throws FactorStackException
	{
		state.ensure(state.datastack,2);
		state.pop(null);
		state.pop(null);
	} //}}}
}
