package net.codepoke.experiments.artemis

import java.lang.reflect.Field
import java.util.List

class ClassExtensions {
	
	/**
	 * Returns all matching fields that exist on a Class and any superclass.
	 */
	def static List<Field> matchingFields(Class clzz, (Field)=>boolean match){
		
		val fields = clzz.declaredFields.filter(match).toList
		
		if(!(clzz.superclass.equals(Object))){
			fields += matchingFields(clzz.superclass, match)
		}
		
		return fields		
	}
	
}