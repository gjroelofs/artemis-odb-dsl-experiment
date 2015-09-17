package net.codepoke.experiments.artemis

import java.lang.reflect.Modifier
import java.lang.reflect.Field

class FieldExtensions {

	/**
	 * Returns whether a given field has the given modifiers.
	 */
	def static hasModifier(Field f, int... modifiers) {
		var mod = 0;
		for (m : modifiers) {
			mod = mod.bitwiseOr(m)
		}
		
		return f.modifiers.bitwiseAnd(mod) != 0;
	}
	
	/**
	 * Checks whether the given field is properly settable.
	 * Either the Field is Public, or the Class has a public Setter named following Java Bean convention.
	 */
	def static isVariableSettable(Field f){
		if(f.hasModifier(java.lang.reflect.Modifier.PUBLIC)){
			return true;
		} else {
			try {
				var method = f.declaringClass.getMethod("set" + f.name.toFirstUpper, f.type);
				return method != null
			} catch (Exception e) {}
		}
		
		return false;
	}

}