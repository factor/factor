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

import factor.compiler.*;
import java.util.HashSet;
import java.util.Set;
import org.objectweb.asm.*;

/**
 * A word definition.
 */
public abstract class FactorWordDefinition implements FactorObject, Constants
{
	private FactorNamespace namespace;
	protected FactorWord word;

	public boolean compileFailed;

	public FactorWordDefinition(FactorWord word)
	{
		this.word = word;
	}

	public abstract void eval(FactorInterpreter interp)
		throws Exception;

	//{{{ getNamespace() method
	public FactorNamespace getNamespace(FactorInterpreter interp) throws Exception
	{
		if(namespace == null)
			namespace = new FactorNamespace(interp.global,this);

		return namespace;
	} //}}}

	//{{{ getStackEffect() method
	public final StackEffect getStackEffect() throws Exception
	{
		return getStackEffect(new HashSet(),new LocalAllocator());
	} //}}}

	//{{{ getStackEffect() method
	public StackEffect getStackEffect(Set recursiveCheck,
		LocalAllocator state) throws Exception
	{
		return null;
	} //}}}

	//{{{ compile() method
	FactorWordDefinition compile(FactorInterpreter interp,
		Set recursiveCheck) throws Exception
	{
		return this;
	} //}}}

	//{{{ compileCallTo() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 */
	public int compileCallTo(CodeVisitor mw, LocalAllocator allocator,
		Set recursiveCheck) throws Exception
	{
		StackEffect effect = getStackEffect();
		if(effect == null)
		{
			// combinator; inline
			return compileImmediate(mw,allocator,recursiveCheck);
		}
		else
		{
			// normal word
			mw.visitVarInsn(ALOAD,0);

			allocator.generateArgs(mw,effect.inD,null);

			String defclass = getClass().getName().replace('.','/');

			String signature = effect.getCorePrototype();

			mw.visitMethodInsn(INVOKESTATIC,defclass,"core",signature);

			if(effect.outD > 1)
				throw new FactorCompilerException("Cannot compile word with non-0/1-out factors");
			if(effect.outD == 1)
				allocator.push(mw);

			return effect.inD + 1;
		}
	} //}}}

	//{{{ compileImmediate() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 */
	public int compileImmediate(CodeVisitor mw, LocalAllocator allocator,
		Set recursiveCheck) throws Exception
	{
		throw new FactorCompilerException("Cannot compile " + word + " in immediate mode");
	} //}}}
}
