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

import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.CodeVisitor;
import org.objectweb.asm.Label;
import org.objectweb.asm.Attribute;

import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;

/**
 * A node that represents a method.
 */

public class MethodNode {

  /**
   * The method's access flags (see {@link org.objectweb.asm.Constants}). This
   * field also indicates if the method is synthetic and/or deprecated.
   */

  public int access;

  /**
   * The method's name.
   */

  public String name;

  /**
   * The method's descriptor (see {@link org.objectweb.asm.Type Type}).
   */

  public String desc;

  /**
   * The internal names of the method's exception classes (see {@link
   * org.objectweb.asm.Type#getInternalName getInternalName}). This list is a
   * list of {@link String} objects.
   */

  public final List exceptions;

  /**
   * The non standard attributes of the method.
   */

  public Attribute attrs;

  /**
   * The instructions of this method. This list is a list of {@link
   * AbstractInsnNode AbstractInsnNode} and {@link Label Label} objects.
   */

  public final List instructions;

  /**
   * The try catch blocks of this method. This list is a list of {@link
   * TryCatchBlockNode TryCatchBlockNode} objects.
   */

  public final List tryCatchBlocks;

  /**
   * The maximum stack size of this method.
   */

  public int maxStack;

  /**
   * The maximum number of local variables of this method.
   */

  public int maxLocals;

  /**
   * The local variables of this method. This list is a list of {@link
   * LocalVariableNode LocalVariableNode} objects.
   */

  public final List localVariables;

  /**
   * The line numbers of this method. This list is a list of {@link
   * LineNumberNode LineNumberNode} objects.
   */

  public final List lineNumbers;

  /**
   * The non standard attributes of the method's code.
   */

  public Attribute codeAttrs;

  /**
   * Constructs a new {@link MethodNode MethodNode} object.
   *
   * @param access the method's access flags (see {@link
   *      org.objectweb.asm.Constants}). This parameter also indicates if the
   *      method is synthetic and/or deprecated.
   * @param name the method's name.
   * @param desc the method's descriptor (see {@link org.objectweb.asm.Type
   *      Type}).
   * @param exceptions the internal names of the method's exception
   *      classes (see {@link org.objectweb.asm.Type#getInternalName
   *      getInternalName}). May be <tt>null</tt>.
   * @param attrs the non standard attributes of the method.
   */

  public MethodNode (
    final int access,
    final String name,
    final String desc,
    final String[] exceptions,
    final Attribute attrs)
  {
    this.access = access;
    this.name = name;
    this.desc = desc;
    this.exceptions = new ArrayList();
    this.instructions = new ArrayList();
    this.tryCatchBlocks = new ArrayList();
    this.localVariables = new ArrayList();
    this.lineNumbers = new ArrayList();
    if (exceptions != null) {
      this.exceptions.addAll(Arrays.asList(exceptions));
    }
    this.attrs = attrs;
  }

  /**
   * Makes the given class visitor visit this method.
   *
   * @param cv a class visitor.
   */

  public void accept (final ClassVisitor cv) {
    String[] exceptions = new String[this.exceptions.size()];
    this.exceptions.toArray(exceptions);
    CodeVisitor mv = cv.visitMethod(access, name, desc, exceptions, attrs);
    if (mv != null && instructions.size() > 0) {
      int i;
      // visits instructions
      for (i = 0; i < instructions.size(); ++i) {
        Object insn = instructions.get(i);
        if (insn instanceof Label) {
          mv.visitLabel((Label)insn);
        } else {
          ((AbstractInsnNode)insn).accept(mv);
        }
      }
      // visits try catch blocks
      for (i = 0; i < tryCatchBlocks.size(); ++i) {
        ((TryCatchBlockNode)tryCatchBlocks.get(i)).accept(mv);
      }
      // visits maxs
      mv.visitMaxs(maxStack, maxLocals);
      // visits local variables
      for (i = 0; i < localVariables.size(); ++i) {
        ((LocalVariableNode)localVariables.get(i)).accept(mv);
      }
      // visits line numbers
      for (i = 0; i < lineNumbers.size(); ++i) {
        ((LineNumberNode)lineNumbers.get(i)).accept(mv);
      }
      // visits the code attributes
      Attribute attrs = codeAttrs;
      while (attrs != null) {
        mv.visitAttribute(attrs);
        attrs = attrs.next;
      }
    }
  }
}
