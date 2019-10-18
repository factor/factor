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
 * A visitor to visit a Java class. The methods of this interface must be called
 * in the following order: <tt>visit</tt> (<tt>visitField</tt> |
 * <tt>visitMethod</tt> | <tt>visitInnerClass</tt> | <tt>visitAttribute</tt>)*
 * <tt>visitEnd</tt>.
 */

public interface ClassVisitor {

  /**
   * Visits the header of the class.
   *
   * @param access the class's access flags (see {@link Constants}). This
   *      parameter also indicates if the class is deprecated.
   * @param name the internal name of the class (see {@link Type#getInternalName
   *      getInternalName}).
   * @param superName the internal of name of the super class (see {@link
   *      Type#getInternalName getInternalName}). For interfaces, the super
   *      class is {@link Object}. May be <tt>null</tt>, but only for the {@link
   *      Object java.lang.Object} class.
   * @param interfaces the internal names of the class's interfaces (see {@link
   *      Type#getInternalName getInternalName}). May be <tt>null</tt>.
   * @param sourceFile the name of the source file from which this class was
   *      compiled. May be <tt>null</tt>.
   */

  void visit (
    int access,
    String name,
    String superName,
    String[] interfaces,
    String sourceFile);

  /**
   * Visits information about an inner class. This inner class is not
   * necessarily a member of the class being visited.
   *
   * @param name the internal name of an inner class (see {@link
   *      Type#getInternalName getInternalName}).
   * @param outerName the internal name of the class to which the inner class
   *      belongs (see {@link Type#getInternalName getInternalName}). May be
   *      <tt>null</tt>.
   * @param innerName the (simple) name of the inner class inside its enclosing
   *      class. May be <tt>null</tt> for anonymous inner classes.
   * @param access the access flags of the inner class as originally declared
   *      in the enclosing class.
   */

  void visitInnerClass (
    String name,
    String outerName,
    String innerName,
    int access);

  /**
   * Visits a field of the class.
   *
   * @param access the field's access flags (see {@link Constants}). This
   *      parameter also indicates if the field is synthetic and/or deprecated.
   * @param name the field's name.
   * @param desc the field's descriptor (see {@link Type Type}).
   * @param value the field's initial value. This parameter, which may be
   *      <tt>null</tt> if the field does not have an initial value, must be an
   *      {@link java.lang.Integer Integer}, a {@link java.lang.Float Float}, a
   *      {@link java.lang.Long Long}, a {@link java.lang.Double Double} or a
   *      {@link String String}. <i>This parameter is only used for static
   *      fields</i>. Its value is ignored for non static fields, which must be
   *      initialized through bytecode instructions in constructors or methods.
   * @param attrs the non standard method attributes, linked together by their
   *      <tt>next</tt> field. May be <tt>null</tt>.
   */

  void visitField (
    int access,
    String name,
    String desc,
    Object value,
    Attribute attrs);

  /**
   * Visits a method of the class. This method <i>must</i> return a new
   * {@link CodeVisitor CodeVisitor} instance (or <tt>null</tt>) each time it
   * is called, i.e., it should not return a previously returned visitor.
   *
   * @param access the method's access flags (see {@link Constants}). This
   *      parameter also indicates if the method is synthetic and/or deprecated.
   * @param name the method's name.
   * @param desc the method's descriptor (see {@link Type Type}).
   * @param exceptions the internal names of the method's exception
   *      classes (see {@link Type#getInternalName getInternalName}). May be
   *      <tt>null</tt>.
   * @param attrs the non standard method attributes, linked together by their
   *      <tt>next</tt> field. May be <tt>null</tt>.
   * @return an object to visit the byte code of the method, or <tt>null</tt> if
   *      this class visitor is not interested in visiting the code of this
   *      method.
   */

  CodeVisitor visitMethod (
    int access,
    String name,
    String desc,
    String[] exceptions,
    Attribute attrs);

  /**
   * Visits a non standard attribute of the class. This method must visit only
   * the first attribute in the given attribute list.
   *
   * @param attr a non standard class attribute. Must not be <tt>null</tt>.
   */

  void visitAttribute (Attribute attr);

  /**
   * Visits the end of the class. This method, which is the last one to be
   * called, is used to inform the visitor that all the fields and methods of
   * the class have been visited.
   */

  void visitEnd ();
}
