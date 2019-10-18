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
import org.objectweb.asm.*;

class AuxiliaryQuotation
{
	private String method;
	private FactorDataStack datastack;
	private FactorCallStack callstack;
	private Cons code;
	private StackEffect effect;
	private RecursiveState recursiveCheck;

	//{{{ mungeFlowObject() method
	private FlowObject mungeFlowObject(int base, int index, FlowObject flow,
		FactorCompiler compiler, RecursiveState recursiveCheck)
		throws Exception
	{
		if(flow instanceof CompiledList)
		{
			return new CompiledListResult(index + base,
				(Cons)flow.getLiteral(),compiler,
				((CompiledList)flow).recursiveCheck);
		}
		else if(flow instanceof Null)
		{
			return new CompiledListResult(index + base,
				(Cons)flow.getLiteral(),
				compiler,recursiveCheck);
		}
		else
		{
			return new Result(index + base,compiler,recursiveCheck);
		}
	} //}}}

	//{{{ AuxiliaryQuotation constructor
	AuxiliaryQuotation(String method,
		FactorDataStack datastack,
        	FactorCallStack callstack,
        	Cons code,
        	StackEffect effect,
		FactorCompiler compiler,
		RecursiveState recursiveCheck)
		throws Exception
	{
		this.method = method;
		this.datastack = datastack;
		this.callstack = callstack;
		this.code = code;
		this.effect = effect;
		this.recursiveCheck = new RecursiveState(recursiveCheck);

		System.arraycopy(datastack.stack,datastack.top - effect.inD,
			datastack.stack,0,effect.inD);
		for(int i = 0; i < effect.inD; i++)
		{
			int index = datastack.top - effect.inD + i;
			FlowObject flow = (FlowObject)datastack.stack[index];
			datastack.stack[index] = mungeFlowObject(1,index,flow,
				compiler,recursiveCheck);
		}

		System.arraycopy(callstack.stack,callstack.top - effect.inR,
			callstack.stack,0,effect.inD);
		for(int i = 0; i < effect.inR; i++)
		{
			int index = callstack.top - effect.inR + i;
			FlowObject flow = (FlowObject)callstack.stack[index];
			callstack.stack[index] = mungeFlowObject(1 + effect.inD,
				index,flow,compiler,recursiveCheck);
		}
	} //}}}

	//{{{ compile() method
	String compile(FactorCompiler compiler, ClassWriter cw,
		FactorWord word)
		throws Exception
	{
		// generate core
		compiler.init(1,effect.inD,effect.inR,method);
		compiler.datastack = datastack;
		compiler.callstack = callstack;
		//compiler.produce(compiler.datastack,effect.inD);
		// important: this.recursiveCheck due to
		// lexically-scoped recursion issues
		return compiler.compile(code,cw,method,effect,
			new RecursiveState(this.recursiveCheck));
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return method + effect;
	} //}}}
}
