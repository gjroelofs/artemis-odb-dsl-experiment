package net.codepoke.experiments.artemis.extensions

import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

class FieldDeclarationExtensions {

	/**
	 * Checks whether the given field is properly settable.
	 * Either the Field is Public, or the Class has a public Setter named following Java Bean convention.
	 */
	def static isVariableSettable(FieldDeclaration f) {
		if (f.visibility == Visibility.PUBLIC) {
			return true;
		} else {
			try {
				var method = f.declaringType.findDeclaredMethod("set" + f.simpleName.toFirstUpper, f.type);
				return method != null
			} catch (Exception e) {
			}
		}

		return false;
	}

}
