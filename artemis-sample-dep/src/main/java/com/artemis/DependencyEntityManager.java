package com.artemis;

import com.artemis.utils.Bag;
import com.artemis.utils.IntBag;
import com.artemis.EntityTransmuter.TransmuteOperation;
import com.artemis.utils.IntDeque;

import components.Position;

import java.util.BitSet;


/**
 * EntityManager.
 *
 * @author Arni Arent
 */
public class DependencyEntityManager extends EntityManager {

	/**
	 * Creates a new EntityManager Instance.
	 */
	protected DependencyEntityManager(int initialContainerSize) {
		super(initialContainerSize);
	}
	
	@Override
	protected void initialize() {
		super.initialize();
		recyclingEntityFactory = new DependencyRecyclingEntityFactory(this);
		DependencyEntity.position = world.getMapper(Position.class);
	}
	
	protected static final class DependencyRecyclingEntityFactory extends RecyclingEntityFactory {

		DependencyRecyclingEntityFactory(DependencyEntityManager em) {
			super(em);
		}
		
		Entity obtain() {
			if (limbo.isEmpty()) {
				Entity e = new DependencyEntity(em.world, nextId++);
				em.entities.set(e.id, e);
				return e;
			} else {
				int id = limbo.popFirst();
				recycled.set(id, false);
				return em.entities.get(id);
			}
		}
		
	}
}
