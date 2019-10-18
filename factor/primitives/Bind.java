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
import java.lang.reflect.*;
import java.util.Set;
import org.objectweb.asm.*;

public class Bind extends FactorWordDefinition
{
	//{{{ Bind constructor
	public Bind(FactorWord word)
	{
		super(word);
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		FactorDataStack datastack = interp.datastack;
		Cons code = (Cons)datastack.pop(Cons.class);
		Object obj = datastack.pop();
		FactorNamespace ns = FactorJava.toNamespace(obj,interp);
		interp.call(word,ns,code);
	} //}}}

	//{{{ getStackEffect() method
	public StackEffect getStackEffect(Set recursiveCheck,
		LocalAllocator state) throws Exception
	{
		state.ensure(state.datastack,2);
		LocalAllocator.FlowObject quot
			= (LocalAllocator.FlowObject)
			state.datastack.pop();
		state.pop(null);
		StackEffect effect = quot.getStackEffect(recursiveCheck);
		if(effect != null)
		{
			// add 2 to inD since we consume the
			// quotation and the object
			return new StackEffect(effect.inD + 2,
				effect.outD,
				effect.inR,
				effect.outR);
		}
		else
			return null;
	} //}}}

	//{{{ compileCallTo() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 */
	public int compileCallTo(
		CodeVisitor mw,
		LocalAllocator allocator,
		Set recursiveCheck)
		throws Exception
	{
		LocalAllocator.FlowObject quot = (LocalAllocator.FlowObject)
			allocator.datastack.pop();

		// store namespace on callstack
		mw.visitVarInsn(ALOAD,0);
		mw.visitFieldInsn(GETFIELD,
			"factor/FactorInterpreter",
			"callframe",
			"Lfactor/FactorCallFrame;");
		mw.visitInsn(DUP);
		mw.visitFieldInsn(GETFIELD,
			"factor/FactorCallFrame",
			"namespace",
			"Lfactor/FactorNamespace;");
		allocator.pushR(mw);

		// set new namespace
		mw.visitInsn(DUP);
		allocator.pop(mw);
		FactorJava.generateFromConversion(mw,FactorNamespace.class);
		mw.visitFieldInsn(PUTFIELD,
			"factor/FactorCallFrame",
			"namespace",
			"Lfactor/FactorNamespace;");

		int maxJVMStack = quot.compileCallTo(mw,recursiveCheck);

		// restore namespace from callstack
		allocator.popR(mw);
		mw.visitFieldInsn(PUTFIELD,
			"factor/FactorCallFrame",
			"namespace",
			"Lfactor/FactorNamespace;");

		return maxJVMStack + 3;
	} //}}}
}
