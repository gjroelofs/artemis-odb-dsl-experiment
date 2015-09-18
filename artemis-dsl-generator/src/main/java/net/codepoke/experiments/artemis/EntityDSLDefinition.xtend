package net.codepoke.experiments.artemis

import com.artemis.Component
import com.artemis.ComponentMapper
import com.artemis.utils.Bag
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend2.lib.StringConcatenationClient

import static extension net.codepoke.experiments.artemis.extensions.ClassDeclarationExtensions.*
import static extension net.codepoke.experiments.artemis.extensions.FieldDeclarationExtensions.*
import com.artemis.Entity

class EntityDSLDefinition {
	
	val static String COMPONENT_VAR = "comp";
	
	/**
	 * Returns the Component Pool name, given the type of Component
	 */
	def String getPoolName(ClassDeclaration clzz) {
		'''«clzz.simpleName.toFirstLower»Pool'''
	}
	
	/**
	 * Returns the Mapper Name, given the type of Component
	 */
	def String getMapperName(ClassDeclaration clzz){
		'''«clzz.simpleName.toFirstLower»Mapper''';
	}

	/**
	 * Adds a static field to the given MutableClass which will hold the Components returned to the pool.
	 */
	def defineComponentPool(extension TransformationContext context, MutableClassDeclaration factory,
		ClassDeclaration clzz) {
		factory.addField(getPoolName(clzz)) [
			type = Bag.newTypeReference(clzz.newTypeReference)
			static = true
			final = true
			initializer = '''new Bag<«clzz.qualifiedName»>(50)''';
		]
	}

	/**
	 * Adds a static field to the given MutableClass which will hold the ComponentMapper.
	 * This will be initialized by the specialized EntityManager.
	 */
	def defineComponentMapper(extension TransformationContext context, MutableClassDeclaration factory,
		ClassDeclaration clzz) {
		factory.addField(getMapperName(clzz)) [
			type = ComponentMapper.newTypeReference(clzz.newTypeReference)
			visibility = Visibility.PROTECTED			
			static = true
		]
	}
	
	/**
	 * Defines the component getter defined as the Type name with the first letter to lowercase.
	 * E.g.: Position will create Entity.position().
	 */
	def defineComponentGetter(extension TransformationContext context, MutableClassDeclaration factory, ClassDeclaration clzz){
		factory.addMethod(clzz.simpleName.toFirstLower)[
			returnType = clzz.newSelfTypeReference
			visibility = Visibility.PUBLIC						
		]
	}
	
	/**
	 * Defines the component has defined as the Type name with the first letter to lowercase.
	 * E.g.: Position will create Entity.hasPosition().
	 */
	def defineComponentHas(extension TransformationContext context, MutableClassDeclaration factory, ClassDeclaration clzz){
		factory.addMethod("has"+clzz.simpleName.toFirstUpper)[
			returnType = boolean.newTypeReference
			visibility = Visibility.PUBLIC						
		]
	}
	
	/**
	 * Defines the component add, with all settable fields on the component class as parameters.
	 * E.g.: Position (with x,y) will create Entity.addPosition(x, y)
	 */
	def defineComponentAdd(extension TransformationContext context, MutableClassDeclaration factory, ClassDeclaration clzz){
		factory.addMethod("add"+clzz.simpleName.toFirstUpper)[
			visibility = Visibility.PUBLIC
			returnType = Entity.newTypeReference
			
			for(f : clzz.matchingFields[isVariableSettable])
				addParameter(f.simpleName, f.type)
		]
	}
	
	/**
	 * Defines the component remove.
	 * E.g.: Position will create Entity.removePosition()
	 */
	def defineComponentRemove(extension TransformationContext context, MutableClassDeclaration factory, ClassDeclaration clzz){
		factory.addMethod("remove"+clzz.simpleName.toFirstUpper)[
			visibility = Visibility.PUBLIC		
			returnType = Entity.newTypeReference			
		]
	}

	/**
	 * Tries to obtain a Component from the pool, if it doesn't exist instantiates using the no-args constructor.
	 * Assigns it to the given variable name.
	 */
	def obtainComponent(ClassDeclaration clzz, String varName) {
		'''
			«clzz.qualifiedName» «varName» = («clzz.qualifiedName»)«getPoolName(clzz)».removeLast();
			if(«varName» == null){
				«varName» = new «clzz.qualifiedName»();
			}
		'''
	}
	
	/**
	 * Creates a new instance of the Component and assigns it the given variable name.
	 */
	def obtainComponentNaive(ClassDeclaration clzz, String varName) {
		'''«clzz.qualifiedName» «varName» = new «clzz.qualifiedName»();'''
	}

	/**
	 * Fills in the initalization (Ensure all variables are set using either direct access or setters.)
	 * Assumes that arguments equal to the backing field name exists in the context.
	 */
	def String initializeComponent(extension TransformationContext context, ClassDeclaration clzz, String varName) {
		var initBlock = '''
			«FOR field : clzz.declaredFields»
				«IF(field.variableSettable)»
					«setVariable(clzz, field, varName)»
				«ENDIF»
			«ENDFOR»
		'''

		// Go through all superclasses until we hit Component
		if (!clzz.extendedClass.equals(Component.newTypeReference)) {
			initBlock += initializeComponent(context, clzz.extendedClass.type as ClassDeclaration, varName)
		}

		return initBlock;
	}
	
	/**
	 * Gets the required Component as an expression using the ComponentMapper.
	 */
	def StringConcatenationClient getComponent(ClassDeclaration clzz){
		'''«getMapperName(clzz)».get(this)'''
	}
	
	/**
	 * Gets the required Component using getComponent on the Entity.
	 */
	def StringConcatenationClient getComponentNaive(ClassDeclaration clzz){
		'''getComponent(«clzz.qualifiedName».class)'''
	}
	
	/**
	 * Checks whether the Entity has the required Component as an expression using the ComponentMapper.
	 */
	def StringConcatenationClient hasComponent(ClassDeclaration clzz){
		'''«getMapperName(clzz)».has(this)'''
	}
	
	/**
	 * Checks whether the Entity has the required Component using getComponent on the Entity.
	 */
	def StringConcatenationClient hasComponentNaive(ClassDeclaration clzz){
		'''getComponent(«clzz.qualifiedName».class) != null'''
	}
	
	/**
	 * Adds the given Component to the entity using the Type found in the Mapper.
	 */
	def StringConcatenationClient addComponent(ClassDeclaration clzz, String varName){
		'''addComponent(«varName», «getMapperName(clzz)».getType());'''
	}
	
	/**
	 * Adds the given Component to the entity without the use of a Mapper.
	 */
	def StringConcatenationClient addComponentNaive(ClassDeclaration clzz, String varName){
		'''addComponent(«varName»);'''
	}
	
	/**
	 * Removes the given Component from the entity using the Type found in the Mapper.
	 */
	def StringConcatenationClient removeComponent(ClassDeclaration clzz){
		'''removeComponent(«getMapperName(clzz)».getType());'''
	}

	
	/**
	 * Removes the given Component from the entity without the use of the Mapper.
	 */
	def StringConcatenationClient removeComponentNaive(ClassDeclaration clzz){
		'''removeComponent(«clzz.qualifiedName».class);'''
	}
	
	/**
	 * Returns the Component under the given variable name to the pool.
	 */
	def StringConcatenationClient freeComponent(ClassDeclaration clzz, String varName) {
		'''«getPoolName(clzz)».add(«varName»);'''
	}
	
	/**
	 * Defines the Component DSL on the specialized Entity which delegates to the component mappers (which are assumed to be defined).
	 */
	def implementComponentDSLSpecialization(MutableClassDeclaration factory,extension TransformationContext context,  ClassDeclaration clzz){
		
		defineComponentMapper(context, factory, clzz);
		
		defineComponentPool(context, factory, clzz);
		
		
		defineComponentHas(context, factory, clzz) => [
			body = '''return «hasComponent(clzz)»;'''
		]	
		
		defineComponentGetter(context, factory, clzz) => [
			body = '''return «getComponent(clzz)»;'''
		]		
		
		defineComponentRemove(context, factory, clzz) => [
			body = '''
				«clzz.qualifiedName» «COMPONENT_VAR» = «getComponent(clzz)»;
				«removeComponent(clzz)»
				«freeComponent(clzz, COMPONENT_VAR)»
				return this;
			'''
		]
		
		defineComponentAdd(context, factory, clzz) => [
			body = '''
				«obtainComponent(clzz, COMPONENT_VAR)»
				«initializeComponent(context, clzz, COMPONENT_VAR)»
				«addComponent(clzz, COMPONENT_VAR)»
				return this;
			'''
		]
		
	}
	
	def implementComponentDSLNaive(MutableClassDeclaration factory,extension TransformationContext context,  ClassDeclaration clzz){
				
		defineComponentHas(context, factory, clzz) => [
			body = '''return «hasComponentNaive(clzz)»;'''
		]	
		
		defineComponentGetter(context, factory, clzz) => [
			body = '''return «getComponentNaive(clzz)»;'''
		]		
		
		defineComponentRemove(context, factory, clzz) => [
			body = '''
				«removeComponentNaive(clzz)»
				return this;
				'''
		]
		
		defineComponentAdd(context, factory, clzz) => [
			body = '''
				«obtainComponentNaive(clzz, COMPONENT_VAR)»
				«initializeComponent(context, clzz, COMPONENT_VAR)»
				«addComponentNaive(clzz, COMPONENT_VAR)»
				return this;
			'''
		]
		
	}

	/**
	 * Returns either a Setter access (if it exists), direct field access (if public), or nothing if not allowed to 
	 * E.g.: given "Foo x"
	 * 	Foo.a will return "x.a = a;" if .setA() does not exist.
	 * 	Foo.setA() will return "x.setA(a);"
	 */
	def setVariable(ClassDeclaration clzz, FieldDeclaration f, String varName) {

		try {
			var method = clzz.findDeclaredMethod("set" + f.simpleName.toFirstUpper, f.type);
			return '''«varName».«method.simpleName»(«f.simpleName»);'''
		} catch (Exception e) {}
		
		if (f.visibility == Visibility.PUBLIC)
			return '''«varName».«f.simpleName» = «f.simpleName»;'''
		else
			return "";
	}

}