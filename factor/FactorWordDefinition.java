/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2003 Slava Pestov.
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

import java.io.FileOutputStream;
import java.util.Iterator;
import org.objectweb.asm.*;
import org.objectweb.asm.util.*;

/**
 * A word definition.
 */
public abstract class FactorWordDefinition implements FactorObject, Constants
{
	private FactorNamespace namespace;

	/**
	 * Number of times this word has been referenced from a
	 * compound word (incremented by the precompiler).
	 */
	public int references;

	public abstract void eval(FactorWord word, FactorInterpreter interp)
		throws Exception;

	void precompile(FactorWord word, FactorInterpreter interp)
		throws Exception {}

	public FactorNamespace getNamespace(FactorInterpreter interp) throws Exception
	{
		if(namespace == null)
			namespace = new FactorNamespace(interp.global,this);

		return namespace;
	}

	//{{{ canCompile() method
	boolean canCompile()
	{
		return false;
	} //}}}

	private static int compileCount;

	//{{{ compile() method
	/**
	 * Compile the given word, returning a new word definition.
	 */
	FactorWordDefinition compile(FactorWord word, FactorInterpreter interp)
		throws Exception
	{
		if(!canCompile())
			return this;

		//System.out.println("Compiling " + word);

		StringBuffer sanitizedName = new StringBuffer();
		for(int i = 0; i < word.name.length(); i++)
		{
			char ch = word.name.charAt(i);
			if(!Character.isJavaIdentifierStart(ch))
				sanitizedName.append("_");
			else
				sanitizedName.append(ch);
		}
		String className = "factor/__compiler__/" + sanitizedName
			+ "_" + (compileCount++);

		ClassWriter cw = new ClassWriter(false);
		cw.visit(ACC_PUBLIC, className,
			"factor/FactorWordDefinition", null, null);

		// creates a MethodWriter for the (implicit) constructor
		CodeVisitor mw = cw.visitMethod(ACC_PUBLIC,
			"<init>", "()V", null, null);
		// pushes the 'this' variable
		mw.visitVarInsn(ALOAD, 0);
		// invokes the super class constructor
		mw.visitMethodInsn(INVOKESPECIAL,
			"factor/FactorWordDefinition", "<init>", "()V");
		mw.visitInsn(RETURN);
		// this code uses a maximum of one stack element and one local
		// variable
		mw.visitMaxs(1, 1);

		// creates a MethodWriter for the 'toString' method
		mw = cw.visitMethod(ACC_PUBLIC,
			"toString", "()Ljava/lang/String;", null, null);
		mw.visitLdcInsn("( compiled ) " + toString());
		mw.visitInsn(ARETURN);
		mw.visitMaxs(1, 1);

		// pushes the 'this' variable
		mw.visitVarInsn(ALOAD, 0);
		// invokes the super class constructor
		mw.visitMethodInsn(INVOKESPECIAL,
			"factor/FactorWordDefinition", "<init>", "()V");
		mw.visitInsn(RETURN);
		// this code uses a maximum of one stack element and one local
		// variable
		mw.visitMaxs(1, 1);

		// creates a MethodWriter for the 'eval' method
		mw = cw.visitMethod(ACC_PUBLIC,
			"eval", "(Lfactor/FactorWord;Lfactor/FactorInterpreter;)V",
			null, null);

		// We store a string with disassembly for debugging
		// purposes.
		TraceCodeVisitor disasm = new TraceCodeVisitor(mw);
		if(!compile(word,interp,cw,disasm))
			return this;

		// Save the disassembly
		StringBuffer buf = new StringBuffer();
		Iterator bytecodes = disasm.getText().iterator();
		while(bytecodes.hasNext())
		{
			buf.append(bytecodes.next());
		}

		// gets the bytecode of the class, and loads it dynamically
		byte[] code = cw.toByteArray();

		/* FileOutputStream fos = new FileOutputStream(className + ".class");
		fos.write(code);
		fos.close(); */

		SimpleClassLoader loader = new SimpleClassLoader();
		Class compiledWordClass = loader._defineClass(className,
			code, 0, code.length);

		FactorWordDefinition compiledWord = (FactorWordDefinition)
			compiledWordClass.newInstance();

		compiledWord.getNamespace(interp).setVariable("asm",buf.toString());

		return compiledWord;
	} //}}}

	//{{{ compile() method
	/**
	 * Write the definition of the eval() method in the compiled word.
	 * Local 0 -- this
	 * Local 1 -- word
	 * Local 2 -- interpreter
	 */
	boolean compile(FactorWord word, FactorInterpreter interp,
		ClassWriter cw, CodeVisitor mw)
		throws Exception
	{
		throw new FactorRuntimeException("Don't know how to compile " + word);
	} //}}}

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
