/***
 * ASM: a very small and fast Java bytecode manipulation framework
 * Copyright (c) 2000,2002,2003 INRIA, France Telecom
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holders nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Contact: Eric.Bruneton@rd.francetelecom.com
 *
 * Author: Eric Bruneton
 */

package org.objectweb.asm;

/**
 * An empty {@link ClassVisitor ClassVisitor} that delegates to another {@link
 * ClassVisitor ClassVisitor}. This class can be used as a super class to
 * quickly implement usefull class adapter classes, just by overriding the
 * necessary methods.
 */

public class ClassAdapter implements ClassVisitor {

  /**
   * The {@link ClassVisitor ClassVisitor} to which this adapter delegates
   * calls.
   */

  protected ClassVisitor cv;

  /**
   * Constructs a new {@link ClassAdapter ClassAdapter} object.
   *
   * @param cv the class visitor to which this adapter must delegate calls.
   */

  public ClassAdapter (final ClassVisitor cv) {
    this.cv = cv;
  }

  public void visit (
    final int access,
    final String name,
    final String superName,
    final String[] interfaces,
    final String sourceFile)
  {
    cv.visit(access, name, superName, interfaces, sourceFile);
  }

  public void visitInnerClass (
    final String name,
    final String outerName,
    final String innerName,
    final int access)
  {
    cv.visitInnerClass(name, outerName, innerName, access);
  }

  public void visitField (
    final int access,
    final String name,
    final String desc,
    final Object value,
    final Attribute attrs)
  {
    cv.visitField(access, name, desc, value, attrs);
  }

  public CodeVisitor visitMethod (
    final int access,
    final String name,
    final String desc,
    final String[] exceptions,
    final Attribute attrs)
  {
    return new CodeAdapter(cv.visitMethod(access, name, desc, exceptions, attrs));
  }

  public void visitAttribute (final Attribute attr) {
    cv.visitAttribute(attr);
  }

  public void visitEnd () {
    cv.visitEnd();
  }
}
