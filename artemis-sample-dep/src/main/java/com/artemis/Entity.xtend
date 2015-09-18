package com.artemis

import java.util.BitSet;
import java.util.UUID;

import com.artemis.managers.UuidEntityManager;
import com.artemis.utils.Bag;
import components.Position
import net.codepoke.experiments.artemis.EntityDSLComponents

/** 
 * The entity class.
 * <p>
 * Cannot be instantiated outside the framework, you must create new entities
 * using World. The world creates entities via it's entity manager.
 * </p>
 * @author Arni Arent
 */
@EntityDSLComponents(Position)
class Entity {
	/** 
	 * The entities identifier in the world. 
	 */
	public int id
	/** 
	 * The world this entity belongs to. 
	 */
	final World world
	//#include "./entity_flyweight_bool.inc"
	/** 
	 * Creates a new {@link Entity} instance in the given world.
	 * <p>
	 * This will only be called by the world via it's entity manager,
	 * and not directly by the user, as the world handles creation of entities.
	 * </p>
	 * @param worldthe world to create the entity in
	 * @param idthe id to set
	 */
	protected  new(World world, int id) {
		this(world, id, null)
	}
	/** 
	 * Creates a new {@link Entity} instance in the given world.
	 * <p>
	 * This will only be called by the world via it's entity manager,
	 * and not directly by the user, as the world handles creation of entities.
	 * </p>
	 * @param worldthe world to create the entity in
	 * @param idthe id to set
	 * @param uuidthe UUID to set
	 */
	protected  new(World world, int id, UUID uuid) {
		this.world=world this.id=id if (uuid !== null && world.hasUuidManager()) world.getManager(UuidEntityManager).setUuid(this, uuid) 
	}
	/** 
	 * The internal id for this entity within the framework.
	 * <p>
	 * No other entity will have the same ID, but ID's are however reused so
	 * another entity may acquire this ID if the previous entity was deleted.
	 * </p>
	 * @return id of the entity
	 */
	def int getId() {
		return id 
	}
	/** 
	 * Returns a BitSet instance containing bits of the components the entity
	 * possesses.
	 * @return a BitSet containing the entities component bits
	 */
	def protected BitSet getComponentBits() {
		return world.getEntityManager().componentBits(id) 
	}
	def EntityEdit edit() {
		var Entity entity=world.getEntity(id) 
		if (entity === null) entity=this return world.editPool.obtainEditor(entity) 
	}
	override String toString() {
		return '''Entity[«id»]''' 
	}
	/** 
	 * @deprecated See {@link Entity#edit()}
	 */
	@Deprecated def <T extends Component>T createComponent(Class<T> componentKlazz) {
		return edit().create(componentKlazz) 
	}
	/** 
	 * @deprecated See {@link Entity#edit()}
	 */
	@Deprecated def Entity addComponent(Component component) {
		edit().add(component) return this 
	}
	/** 
	 * @deprecated See {@link Entity#edit()}
	 */
	@Deprecated def Entity addComponent(Component component, ComponentType type) {
		edit().add(component, type) return this 
	}
	/** 
	 * @deprecated See {@link Entity#edit()}
	 */
	@Deprecated def Entity removeComponent(Component component) {
		edit().remove(component) return this 
	}
	/** 
	 * @deprecated See {@link Entity#edit()}
	 */
	@Deprecated def Entity removeComponent(ComponentType type) {
		edit().remove(type) return this 
	}
	/** 
	 * @deprecated See {@link Entity#edit()}
	 */
	@Deprecated def Entity removeComponent(Class<? extends Component> type) {
		edit().remove(type) return this 
	}
	/** 
	 * Checks if the entity has been added to the world and has not been
	 * deleted from it.
	 * <p>
	 * If the entity has been disabled this will still return true.
	 * </p>
	 * @return {@code true} if it's active
	 */
	def boolean isActive() {
		return world.getEntityManager().isActive(id) 
	}
	/** 
	 * Retrieves component from this entity.
	 * <p>
	 * It will provide good performance. But the recommended way to retrieve
	 * components from an entity is using the ComponentMapper.
	 * </p>
	 * @param typein order to retrieve the component fast you must provide a
	 * ComponentType instance for the expected component
	 * @return
	 */
	def Component getComponent(ComponentType type) {
		return world.getComponentManager().getComponent(this, type) 
	}
	/** 
	 * Slower retrieval of components from this entity.
	 * <p>
	 * Minimize usage of this, but is fine to use e.g. when creating new
	 * entities and setting data in components.
	 * </p>
	 * @param<T>
	 * the expected return component class type
	 * @param typethe expected return component class type
	 * @return component that matches, or null if none is found
	 */
	@SuppressWarnings("unchecked")def <T extends Component>T getComponent(Class<T> type) {
		var ComponentTypeFactory tf=world.getComponentManager().typeFactory 
		return getComponent(tf.getTypeFor(type)) as T 
	}
	/** 
	 * Returns a bag of all components this entity has.
	 * <p>
	 * You need to reset the bag yourself if you intend to fill it more than
	 * once.
	 * </p>
	 * @param fillBagthe bag to put the components into
	 * @return the fillBag containing the components
	 */
	def Bag<Component> getComponents(Bag<Component> fillBag) {
		return world.getComponentManager().getComponentsFor(this, fillBag) 
	}
	/** 
	 * @deprecated Automatically managed.
	 */
	@Deprecated def void addToWorld() {
		
	}
	/** 
	 * @deprecated Automatically managed.
	 */
	@Deprecated def void changedInWorld() {
		
	}
	/** 
	 * Delete this entity from the world.
	 */
	def void deleteFromWorld() {
		edit().deleteEntity() 
	}
	/** 
	 * (Re)enable the entity in the world, after it having being disabled.
	 * <p>
	 * Won't do anything unless it was already disabled.
	 * </p>
	 * @deprecated create your own components to track state.
	 */
	@Deprecated def void enable() {
		world.enable(this) 
	}
	/** 
	 * Disable the entity from being processed.
	 * <p>
	 * Won't delete it, it will continue to exist but won't get processed.
	 * </p>
	 * @deprecated create your own components to track state.
	 */
	@Deprecated def void disable() {
		world.disable(this) 
	}
	/** 
	 * Get the UUID for this entity.
	 * <p>
	 * This UUID is unique per entity (re-used entities get a new UUID).
	 * </p>
	 * @return uuid instance for this entity
	 * @deprecated historical left-over: use the UuidEntityManager directly, if you need it.
	 */
	@Deprecated def UUID getUuid() {
		if (!world.hasUuidManager()) throw new MundaneWireException(UuidEntityManager)return world.getManager(UuidEntityManager).getUuid(this) 
	}
	/** 
	 * @deprecated historical left-over: use the UuidEntityManager directly, if you need it.
	 */
	@Deprecated def void setUuid(UUID uuid) {
		if (world.hasUuidManager()) {
			world.getManager(UuidEntityManager).setUuid(this, uuid) 
		}
		
	}
	/** 
	 * Returns the world this entity belongs to.
	 * @return world of entity
	 */
	def World getWorld() {
		return world 
	}
	def int getCompositionId() {
		return world.getEntityManager().getIdentity(id) 
	}
	override boolean equals(Object o) {
		if (this === o) return true if (o === null || getClass() !== o.getClass()) return false var Entity entity=o as Entity 
		if (id !== entity.id) return false return true 
	}
	def boolean equals(Entity o) {
		return o !== null && o.id === id 
	}
	override int hashCode() {
		return id 
	}
	
}