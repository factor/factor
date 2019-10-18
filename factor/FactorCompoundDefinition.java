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
import java.lang.reflect.*;
import java.io.FileOutputStream;
import java.util.*;
import org.objectweb.asm.*;
import org.objectweb.asm.util.*;

/**
 * : name ... ;
 */
public class FactorCompoundDefinition extends FactorWordDefinition
{
	private static int compileCount;

	public Cons definition;

	//{{{ FactorCompiledDefinition constructor
	public FactorCompoundDefinition(FactorWord word, Cons definition)
	{
		super(word);
		this.definition = definition;
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		interp.call(word,definition);
	} //}}}

	//{{{ getStackEffect() method
	public StackEffect getStackEffect(Set recursiveCheck,
		LocalAllocator state) throws Exception
	{
		if(recursiveCheck.contains(this))
			return null;

		try
		{
			recursiveCheck.add(this);

			return StackEffect.getStackEffect(definition,
				recursiveCheck,state);
		}
		finally
		{
			recursiveCheck.remove(this);
		}
	} //}}}

	//{{{ getSanitizedName() method
	private String getSanitizedName(String name)
	{
		StringBuffer sanitizedName = new StringBuffer();
		for(int i = 0; i < name.length(); i++)
		{
			char ch = name.charAt(i);
			if(!Character.isJavaIdentifierStart(ch))
				sanitizedName.append("_");
			else
				sanitizedName.append(ch);
		}
		return "factor/compiler/gen/" + sanitizedName
			+ "_" + (compileCount++);
	} //}}}

	//{{{ compile() method
	/**
	 * Compile the given word, returning a new word definition.
	 */
	FactorWordDefinition compile(FactorInterpreter interp,
		Set recursiveCheck) throws Exception
	{
		StackEffect effect = getStackEffect(
			recursiveCheck,new LocalAllocator());
		if(effect == null)
			throw new FactorCompilerException("Cannot deduce stack effect of " + word);
		if(effect.outD > 1)
			throw new FactorCompilerException("Cannot compile word that returns more than 1 value");

		/* StringBuffer buf = new StringBuffer();
		for(int i = 0; i < recursiveCheck.size(); i++)
		{
			buf.append(' ');
		}
		buf.append("Compiling ").append(word);
		System.err.println(buf); */

		String className = getSanitizedName(word.name);

		ClassWriter cw = new ClassWriter(false);
		cw.visit(ACC_PUBLIC, className,
			"factor/compiler/CompiledDefinition", null, null);

		compileConstructor(cw,className);

		CompileResult result = compileEval(interp,cw,
			className,effect,recursiveCheck);

		compileToString(cw,effect);

		// Generate fields for storing literals and word references
		result.allocator.generateFields(cw);

		// gets the bytecode of the class, and loads it dynamically
		byte[] code = cw.toByteArray();

		if(interp.compileDump)
		{
			FileOutputStream fos = new FileOutputStream(className + ".class");
			fos.write(code);
			fos.close();
		}

		Class compiledWordClass = loader._defineClass(
			className.replace('/','.'),
			code, 0, code.length);

		result.allocator.setFields(compiledWordClass);

		Constructor constructor = compiledWordClass.getConstructor(
			new Class[] { FactorWord.class, StackEffect.class });

		FactorWordDefinition compiledWord = (FactorWordDefinition)
			constructor.newInstance(new Object[] { word, effect });

		// store disassembly for the 'asm' word.
		compiledWord.getNamespace(interp).setVariable("asm",
			result.asm);

		return compiledWord;
	} //}}}

	//{{{ compileConstructor() method
	private void compileConstructor(ClassVisitor cw, String className)
	{
		// creates a MethodWriter for the constructor
		CodeVisitor mw = cw.visitMethod(ACC_PUBLIC,
			"<init>",
			"(Lfactor/FactorWord;Lfactor/compiler/StackEffect;)V",
			null, null);
		// pushes the 'this' variable
		mw.visitVarInsn(ALOAD, 0);
		// pushes the word parameter
		mw.visitVarInsn(ALOAD, 1);
		// pushes the stack effect parameter
		mw.visitVarInsn(ALOAD, 2);
		// invokes the super class constructor
		mw.visitMethodInsn(INVOKESPECIAL,
			"factor/compiler/CompiledDefinition", "<init>",
			"(Lfactor/FactorWord;Lfactor/compiler/StackEffect;)V");
		mw.visitInsn(RETURN);
		mw.visitMaxs(3, 3);
	} //}}}

	//{{{ compileToString() method
	private void compileToString(ClassVisitor cw, StackEffect effect)
	{
		// creates a MethodWriter for the 'toString' method
		CodeVisitor mw = cw.visitMethod(ACC_PUBLIC,
			"toString", "()Ljava/lang/String;", null, null);
		mw.visitLdcInsn("( compiled: " + effect + " ) " + toString());
		mw.visitInsn(ARETURN);
		mw.visitMaxs(1, 1);
	} //}}}

	//{{{ compileEval() method
	static class CompileResult
	{
		LocalAllocator allocator;
		String asm;

		CompileResult(LocalAllocator allocator, String asm)
		{
			this.allocator = allocator;
			this.asm = asm;
		}
	}

	/**
	 * Write the definition of the eval() method in the compiled word.
	 * Local 0 -- this
	 * Local 1 -- interpreter
	 */
	protected CompileResult compileEval(FactorInterpreter interp,
		ClassWriter cw, String className, StackEffect effect,
		Set recursiveCheck) throws Exception
	{
		// creates a MethodWriter for the 'eval' method
		CodeVisitor _mw = cw.visitMethod(ACC_PUBLIC,
			"eval", "(Lfactor/FactorInterpreter;)V",
			null, null);

		TraceCodeVisitor mw = new TraceCodeVisitor(_mw);

		// eval() method calls core
		mw.visitVarInsn(ALOAD,1);

		compileDataStackToJVMStack(effect,mw);

		String signature = effect.getCorePrototype();

		mw.visitMethodInsn(INVOKESTATIC,
			className,"core",signature);

		compileJVMStackToDataStack(effect,mw);

		mw.visitInsn(RETURN);
		mw.visitMaxs(Math.max(4,2 + effect.inD),4);

		String evalAsm = getDisassembly(mw);

		// generate core
		_mw = cw.visitMethod(ACC_PUBLIC | ACC_STATIC,
			"core",signature,null,null);

		mw = new TraceCodeVisitor(_mw);

		LocalAllocator allocator = new LocalAllocator(interp,
			className,1,effect.inD);

		int maxJVMStack = allocator.compile(definition,mw,
			recursiveCheck);

		if(effect.outD == 0)
			mw.visitInsn(RETURN);
		else
		{
			allocator.pop(mw);
			mw.visitInsn(ARETURN);
			maxJVMStack = Math.max(maxJVMStack,1);
		}

		mw.visitMaxs(maxJVMStack,allocator.maxLocals());

		String coreAsm = getDisassembly(mw);

		return new CompileResult(allocator,
			"eval(Lfactor/FactorInterpreter;)V:\n" + evalAsm
			+ "core" + signature + "\n" + coreAsm);
	} //}}}

	//{{{ getDisassembly() method
	protected String getDisassembly(TraceCodeVisitor mw)
	{
		// Save the disassembly of the eval() method
		StringBuffer buf = new StringBuffer();
		Iterator bytecodes = mw.getText().iterator();
		while(bytecodes.hasNext())
		{
			buf.append(bytecodes.next());
		}
		return buf.toString();
	} //}}}

	//{{{ compileDataStackToJVMStack() method
	private void compileDataStackToJVMStack(StackEffect effect,
		CodeVisitor mw)
	{
		if(effect.inD != 0)
		{
			mw.visitVarInsn(ALOAD,1);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorInterpreter", "datastack",
				"Lfactor/FactorDataStack;");

			// ensure the stack has enough elements
			mw.visitInsn(DUP);
			mw.visitIntInsn(BIPUSH,effect.inD);
			mw.visitMethodInsn(INVOKEVIRTUAL,
				"factor/FactorArrayStack", "ensurePop",
				"(I)V");

			// datastack.stack -> 2
			mw.visitInsn(DUP);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArrayStack", "stack",
				"[Ljava/lang/Object;");
			mw.visitVarInsn(ASTORE,2);
			// datastack.top-args.length -> 3
			mw.visitInsn(DUP);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArrayStack", "top",
				"I");
			mw.visitIntInsn(BIPUSH,effect.inD);
			mw.visitInsn(ISUB);

			// datastack.top -= args.length
			mw.visitInsn(DUP_X1);
			mw.visitFieldInsn(PUTFIELD,
				"factor/FactorArrayStack", "top",
				"I");

			mw.visitVarInsn(ISTORE,3);

			for(int i = 0; i < effect.inD; i++)
			{
				mw.visitVarInsn(ALOAD,2);
				mw.visitVarInsn(ILOAD,3);
				mw.visitInsn(AALOAD);
				if(i != effect.inD - 1)
					mw.visitIincInsn(3,1);
			}
		}
	} //}}}

	//{{{ compileJVMStackToDataStack() method
	private void compileJVMStackToDataStack(StackEffect effect,
		CodeVisitor mw)
	{
		if(effect.outD == 1)
		{
			// ( datastack )
			mw.visitVarInsn(ALOAD,1);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorInterpreter", "datastack",
				"Lfactor/FactorDataStack;");

			mw.visitInsn(SWAP);
			mw.visitMethodInsn(INVOKEVIRTUAL,
				"factor/FactorArrayStack", "push",
				"(Ljava/lang/Object;)V");
		}
	} //}}}

	//{{{ compileImmediate() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 */
	public int compileImmediate(CodeVisitor mw, LocalAllocator allocator,
		Set recursiveCheck) throws Exception
	{
		return allocator.compile(definition,mw,recursiveCheck);
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return definition.elementsToString();
	} //}}}

	private static SimpleClassLoader loader = new SimpleClassLoader();

	//{{{ SimpleClassLoader class
	static class SimpleClassLoader extends ClassLoader
	{
		public Class _defineClass(String name,
				byte[] code, int off, int len)
		{
			return defineClass(name,code,off,len);
		}
	} //}}}
}
