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

package org.objectweb.asm.tree;

import org.objectweb.asm.ClassAdapter;
import org.objectweb.asm.CodeVisitor;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.Attribute;

/**
 * A {@link ClassAdapter ClassAdapter} that constructs a tree representation of
 * the classes it vists. Each <tt>visit</tt><i>XXX</i> method of this class
 * constructs an <i>XXX</i><tt>Node</tt> and adds it to the {@link #classNode
 * classNode} node (except the {@link #visitEnd visitEnd} method, which just
 * makes the {@link #cv cv} class visitor visit the tree that has just been
 * constructed).
 * <p>
 * In order to implement a usefull class adapter based on a tree representation
 * of classes, one just need to override the {@link #visitEnd visitEnd} method
 * with a method of the following form:
 * <pre>
 * public void visitEnd () {
 *   // ...
 *   // code to modify the classNode tree, can be arbitrary complex
 *   // ...
 *   // makes the cv visitor visit this modified class:
 *   classNode.accept(cv);
 * }
 * </pre>
 */

public class TreeClassAdapter extends ClassAdapter {

  /**
   * A tree representation of the class that is being visited by this visitor.
   */

  public ClassNode classNode;

  /**
   * Constructs a new {@link TreeClassAdapter TreeClassAdapter} object.
   *
   * @param cv the class visitor to which this adapter must delegate calls.
   */

  public TreeClassAdapter (final ClassVisitor cv) {
    super(cv);
  }

  public void visit (
    final int access,
    final String name,
    final String superName,
    final String[] interfaces,
    final String sourceFile)
  {
    classNode = new ClassNode(access, name, superName, interfaces, sourceFile);
  }

  public void visitInnerClass (
    final String name,
    final String outerName,
    final String innerName,
    final int access)
  {
    InnerClassNode icn = new InnerClassNode(name, outerName, innerName, access);
    classNode.innerClasses.add(icn);
  }

  public void visitField (
    final int access,
    final String name,
    final String desc,
    final Object value,
    final Attribute attrs)
  {
    FieldNode fn = new FieldNode(access, name, desc, value, attrs);
    classNode.fields.add(fn);
  }

  public CodeVisitor visitMethod (
    final int access,
    final String name,
    final String desc,
    final String[] exceptions,
    final Attribute attrs)
  {
    MethodNode mn = new MethodNode(access, name, desc, exceptions, attrs);
    classNode.methods.add(mn);
    return new TreeCodeAdapter(mn);
  }

  public void visitAttribute (final Attribute attr) {
    attr.next = classNode.attrs;
    classNode.attrs = attr;
  }

  public void visitEnd () {
    classNode.accept(cv);
  }
}
