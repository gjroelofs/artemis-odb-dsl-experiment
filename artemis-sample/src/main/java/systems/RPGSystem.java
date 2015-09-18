package systems;

import com.artemis.Aspect;
import com.artemis.Entity;
import com.artemis.systems.EntityProcessingSystem;

import components.Mana;
import components.Health;

public class RPGSystem extends EntityProcessingSystem {

	public RPGSystem() {
		super(Aspect.all(Health.class, Mana.class));
	}

	@Override
	protected void process(Entity e) {
		e.health().value += 10;
		e.mana().value += 10;
	}

}
