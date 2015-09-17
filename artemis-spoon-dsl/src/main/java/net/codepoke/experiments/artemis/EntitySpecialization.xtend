package net.codepoke.experiments.artemis

import com.artemis.Component
import java.lang.reflect.Field
import static extension net.codepoke.experiments.artemis.FieldExtensions.*;
import static extension net.codepoke.experiments.artemis.ClassExtensions.*;
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import com.artemis.utils.Bag
import org.eclipse.xtend.lib.macro.TransformationContext
import com.artemis.ComponentMapper
import org.eclipse.xtend.lib.macro.declaration.Modifier
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend2.lib.StringConcatenationClient
import com.artemis.Entity

class EntitySpecialization {
	
	val static String COMPONENT_VAR = "comp";
	
	/**
	 * Returns the Component Pool name, given the type of Component
	 */
	def static String getPoolName(Class<? extends Component> clzz) {
		'''«clzz.simpleName.toFirstLower»Pool'''
	}
	
	/**
	 * Returns the Mapper Name, given the type of Component
	 */
	def static String getMapperName(Class<? extends Component> clzz){
		'''«clzz.simpleName.toFirstLower»Mapper''';
	}

	/**
	 * Adds a static field to the given MutableClass which will hold the Components returned to the pool.
	 */
	def static defineComponentPool(extension TransformationContext context, MutableClassDeclaration factory,
		Class<? extends Component> clzz) {
		factory.addField(getPoolName(clzz)) [
			type = Bag.newTypeReference(clzz.newTypeReference)
			modifiers += Modifier.STATIC
			final = true
			initializer = '''new Bag«clzz.canonicalName»(50);''';
		]
	}

	/**
	 * Adds a static field to the given MutableClass which will hold the ComponentMapper.
	 * This will be initialized by the specialized EntityManager.
	 */
	def static defineComponentMapper(extension TransformationContext context, MutableClassDeclaration factory,
		Class<? extends Component> clzz) {
		factory.addField(getMapperName(clzz)) [
			type = ComponentMapper.newTypeReference(clzz.newTypeReference)			
			modifiers += Modifier.STATIC
			final = true
		]
	}
	
	/**
	 * Defines the component getter defined as the Type name with the first letter to lowercase.
	 * E.g.: Position will create Entity.position().
	 */
	def static defineComponentGetter(extension TransformationContext context, MutableClassDeclaration factory, Class<? extends Component> clzz){
		factory.addMethod(clzz.simpleName.toFirstLower)[
			modifiers += Modifier.OVERRIDE
			modifiers += Modifier.STATIC
			visibility = Visibility.PUBLIC						
		]
	}
	
	/**
	 * Defines the component add, with all settable fields on the component class as parameters.
	 * E.g.: Position (with x,y) will create Entity.addPosition(x, y)
	 */
	def static defineComponentAdd(extension TransformationContext context, MutableClassDeclaration factory, Class<? extends Component> clzz){
		factory.addMethod("add"+clzz.simpleName.toFirstUpper)[
			modifiers += Modifier.OVERRIDE
			modifiers += Modifier.STATIC
			visibility = Visibility.PUBLIC
			
			for(f : clzz.matchingFields[isVariableSettable])
				addParameter(f.name, f.type.newTypeReference)
		]
	}
	
	/**
	 * Defines the component remove.
	 * E.g.: Position will create Entity.removePosition()
	 */
	def static defineComponentRemove(extension TransformationContext context, MutableClassDeclaration factory, Class<? extends Component> clzz){
		factory.addMethod("remove"+clzz.simpleName.toFirstUpper)[
			if(factory.newSelfTypeReference.equals(Entity.newTypeReference))
				modifiers += Modifier.OVERRIDE
			modifiers += Modifier.STATIC
			visibility = Visibility.PUBLIC					
		]
	}

	/**
	 * Tries to obtain a Component from the pool, if it doesn't exist instantiates using the no-args constructor.
	 * Assigns it to the given variable name.
	 */
	def static obtainComponent(Class<? extends Component> clzz, String varName) {
		'''
			«clzz.canonicalName» «varName» = «getPoolName(clzz)».removeLast() as «clzz.canonicalName»;
			if(«varName» == null){
				«varName» = new «clzz.canonicalName»();
			}
		'''
	}
	
	/**
	 * Creates a new instance of the Component and assigns it the given variable name.
	 */
	def static obtainComponentNaive(Class<? extends Component> clzz, String varName) {
		'''«clzz.canonicalName» «varName» = new «clzz.typeName»();'''
	}

	/**
	 * Fills in the initalization (Ensure all variables are set using either direct access or setters.)
	 * Assumes that arguments equal to the backing field name exists in the context.
	 */
	def static initializeComponent(Class<? extends Component> clzz, String varName) {
		var initBlock = '''
			«FOR field : clzz.declaredFields»
				«IF(!field.hasModifier(java.lang.reflect.Modifier.STATIC))»
					«setVariable(clzz, field, varName)»
				«ENDIF»
			«ENDFOR»
		'''

		// Go through all superclasses until we hit Component
		if (clzz.superclass != Component) {
			initBlock += initializeComponent(clzz.superclass as Class, varName)
		}

		return initBlock;
	}
	
	/**
	 * Gets the required Component as an expression using the ComponentMapper.
	 */
	def static StringConcatenationClient getComponent(Class<? extends Component> clzz){
		'''«getMapperName(clzz)».get(this)'''
	}
	
	/**
	 * Gets the required Component using getComponent on the Entity.
	 */
	def static StringConcatenationClient getComponentNaive(Class<? extends Component> clzz){
		'''getComponent(«clzz.typeName»)'''
	}
	
	/**
	 * Adds the given Component to the entity using the Type found in the Mapper.
	 */
	def static StringConcatenationClient addComponent(Class<? extends Component> clzz, String varName){
		'''addComponent(«varName», «getMapperName(clzz)».getType());'''
	}
	
	/**
	 * Adds the given Component to the entity without the use of a Mapper.
	 */
	def static StringConcatenationClient addComponentNaive(Class<? extends Component> clzz, String varName){
		'''addComponent(«varName»);'''
	}
	
	/**
	 * Removes the given Component from the entity using the Type found in the Mapper.
	 */
	def static StringConcatenationClient removeComponent(Class<? extends Component> clzz){
		'''removeComponent(«getMapperName(clzz)».getType());'''
	}

	
	/**
	 * Removes the given Component from the entity without the use of the Mapper.
	 */
	def static StringConcatenationClient removeComponentNaive(Class<? extends Component> clzz){
		'''removeComponent(«clzz.typeName»);'''
	}
	
	/**
	 * Returns the Component under the given variable name to the pool.
	 */
	def static StringConcatenationClient freeComponent(Class<? extends Component> clzz, String varName) {
		'''«getPoolName(clzz)».add(«varName»);'''
	}
	
	/**
	 * Defines the Component DSL on the specialized Entity which delegates to the component mappers (which are assumed to be defined).
	 */
	def static implementComponentDSLSpecialization(extension TransformationContext context, MutableClassDeclaration factory, Class<? extends Component> clzz){
		
		defineComponentGetter(context, factory, clzz) => [
			body = '''return «getComponent(clzz)»;'''
		]		
		
		defineComponentRemove(context, factory, clzz) => [
			body = '''
				var «COMPONENT_VAR» = «getComponent(clzz)»;
				«removeComponent(clzz)»
				«freeComponent(clzz, COMPONENT_VAR)»
			'''
		]
		
		defineComponentAdd(context, factory, clzz) => [
			body = '''
				«obtainComponent(clzz, COMPONENT_VAR)»
				«initializeComponent(clzz, COMPONENT_VAR)»
				«addComponent(clzz, COMPONENT_VAR)»
			'''
		]
		
	}
	
	def static implementComponentDSLNaive(extension TransformationContext context, MutableClassDeclaration factory, Class<? extends Component> clzz){
		
		defineComponentGetter(context, factory, clzz) => [
			body = '''return «getComponentNaive(clzz)»;'''
		]		
		
		defineComponentRemove(context, factory, clzz) => [
			body = '''«removeComponentNaive(clzz)»'''
		]
		
		defineComponentAdd(context, factory, clzz) => [
			body = '''
				«obtainComponentNaive(clzz, COMPONENT_VAR)»
				«initializeComponent(clzz, COMPONENT_VAR)»
				«addComponentNaive(clzz, COMPONENT_VAR)»
			'''
		]
		
	}

	/**
	 * Returns either a Setter access (if it exists), direct field access (if public), or nothing if not allowed to 
	 * E.g.: given "Foo x"
	 * 	Foo.a will return "x.a = a;" if .setA() does not exist.
	 * 	Foo.setA() will return "x.setA(a);"
	 */
	def static setVariable(Class<? extends Component> clzz, Field f, String varName) {

		try {
			var method = clzz.getMethod("set" + f.name.toFirstUpper, f.type);
			return '''«varName».«method.name»(«f.name»);'''
		} catch (Exception e) {}

		if (f.hasModifier(java.lang.reflect.Modifier.PUBLIC))
			return '''«varName».«f.name» = «f.name»;'''
		else
			return "";
	}

	def static void main(String[] args) {
		println("Started:")
		println(net.codepoke.experiments.artemis.EntitySpecialization.obtainComponent(TestComponent, COMPONENT_VAR))
		println(initializeComponent(TestComponent, COMPONENT_VAR))
		println(freeComponent(TestComponent, COMPONENT_VAR))
		println(addComponent(TestComponent, COMPONENT_VAR))
		println(removeComponent(TestComponent))
	}

	static class TestComponent extends Component {
		public String x;

	}

}