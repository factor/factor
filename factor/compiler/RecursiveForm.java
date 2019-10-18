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
import org.objectweb.asm.Label;

public class RecursiveForm implements PublicCloneable
{
	/**
	 * Word represented by this form.
	 */
	public final FactorWord word;

	/**
	 * The effect on entry into this form.
	 * (?) only for immediates
	 */
	public StackEffect effect;

	/**
	 * Base case of recursive form. This is left-composed with the
	 * effect above.
	 */
	public StackEffect baseCase;

	/**
	 * Is the word being compiled right now?
	 */
	public boolean active;

	/**
	 * Name of class to call to recurse.
	 */
	public String className;

	/**
	 * Class loader containing this definition.
	 */
	public FactorClassLoader loader;

	/**
	 * Name of method to call to recurse.
	 */
	public String method;

	/**
	 * Are we compiling the last factor in the word right now?
	 */
	public boolean tail;

	/**
	 * A label to jump to the beginning of the definition.
	 */
	public Label label = new Label();

	/**
	 * See RecursiveState.lastCallable().
	 */
	public boolean callable = true;

	/**
	 * The containing recursive form, lexically.
	 */
	public RecursiveForm next;

	public RecursiveForm(FactorWord word, StackEffect effect,
		String className, FactorClassLoader loader,
		String method)
	{
		this.word = word;
		this.effect = effect;
		this.className = className;
		this.loader = loader;
		this.method = method;
	}

	public RecursiveForm(RecursiveForm form)
	{
		this.word = form.word;
		this.effect = form.effect;
		this.baseCase = form.baseCase;
		this.effect = form.effect;
		this.className = form.className;
		this.loader = form.loader;
		this.method = form.method;
	}

	public String toString()
	{
		return word.toString() + ",base=" + baseCase
			+ ",effect=" + effect
			+ (active?",active":"")
			+ (tail?",tail":"")
			+ "; " + className + "." + method + "()";
	}

	public Object clone()
	{
		return new RecursiveForm(this);
	}
}
