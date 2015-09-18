package systems;

import com.artemis.Aspect;
import com.artemis.ComponentMapper;
import com.artemis.Entity;
import com.artemis.EntitySystem;
import com.artemis.annotations.Wire;
import com.artemis.systems.EntityProcessingSystem;

import components.Position;

public class PositionSystem extends EntityProcessingSystem {

	public PositionSystem() {
		super(Aspect.all(Position.class));
	}

	@Override
	protected void process(Entity e) {
		
		for (int i = 0; i < 10; i++) {
			e.position().x++;
			e.position().y++;
		}
	}

}
