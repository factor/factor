/**
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

package org.objectweb.asm.attrs;

import java.util.Map;

import org.objectweb.asm.Attribute;
import org.objectweb.asm.ByteVector;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;

/**
 * The Signature Attribute introduced in JSR-14 (Adding Generics to the
 * Java Programming Language) and also defined in the Java Virtual Machine
 * Specification, 3rd edition draft. This atribute is used for classes,
 * fields and methods.
 * <p>
 * Classfiles need to carry generic type information in a backwards
 * compatible way. This is accomplished by introducing a new "Signature"
 * attribute for classes, methods and fields. The structure of this
 * attribute is as follows:
 * <pre>
 *   "Signature" (u4 attr-length, u2 signature-index)
 * </pre>
 * When used as an attribute of a method or field, a signature gives the
 * full (possibly generic) type of that method or field.
 * When used as a class attribute, a signature indicates the type
 * parameters of the class, followed by its supertype, followed by
 * all its interfaces.
 * <p>
 * The type syntax in signatures is extended to parameterized types and
 * type variables. There is also a new signature syntax for formal type
 * parameters. The syntax extensions for signature strings are as follows:
 * <pre>
 *   MethodOrFieldSignature ::= TypeSignature
 *   ClassSignature        ::= ParameterPartOpt super_TypeSignature interface_TypeSignatures
 *   TypeSignatures        ::= TypeSignatures TypeSignature
 *                             |
 *   TypeSignature         ::= ...
 *                             | ClassTypeSignature
 *                             | MethodTypeSignature
 *                             | TypeVariableSignature
 *   ClassTypeSignature    ::= 'L' Ident TypeArgumentsOpt ';'
 *                             | ClassTypeSignature '.' Ident ';' TypeArgumentsOpt
 *   MethodTypeSignature   ::= TypeArgumentsOpt '(' TypeSignatures ')'
 *                             TypeSignature ThrowsSignatureListOpt
 *   ThrowsSignatureList   ::= ThrowsSignature ThrowsSignatureList
 *                             | ThrowsSignature
 *   ThrowsSignature       ::= '^' TypeSignature
 *   TypeVariableSignature ::= 'T' Ident ';'
 *   TypeArguments         ::= '<' TypeSignature TypeSignatures '>'
 *   ParameterPart         ::= '<' ParameterSignature ParameterSignatures '>'
 *   ParameterSignatures   ::= ParameterSignatures ParameterSignature
 *                             |
 *   ParameterSignature ::= Ident ':' bound_TypeSignature
 * </pre>
 *
 * @see <a href="http://www.jcp.org/en/jsr/detail?id=14">JSR 14 : Add Generic
 * Types To The JavaTM Programming Language</a>
 *
 * @author Eugene Kuleshov
 */

public class SignatureAttribute extends Attribute implements Dumpable {

  public String signature;

  public SignatureAttribute () {
    super("Signature");
  }

  public SignatureAttribute (String signature) {
    this();
    this.signature = signature;
  }

  protected Attribute read (ClassReader cr, int off,
                            int len, char[] buf, int codeOff, Label[] labels) {
    return new SignatureAttribute(cr.readUTF8(off, buf));
  }

  protected ByteVector write (ClassWriter cw, byte[] code,
                              int len, int maxStack, int maxLocals) {
    return new ByteVector().putShort(cw.newUTF8(signature));
  }

  public void dump (StringBuffer buf, String varName, Map labelNames) {
    buf.append("SignatureAttribute ").append(varName)
      .append(" = new SignatureAttribute(\"")
      .append(signature).append("\");\n");
  }

  public String toString () {
    return signature;
  }
}
