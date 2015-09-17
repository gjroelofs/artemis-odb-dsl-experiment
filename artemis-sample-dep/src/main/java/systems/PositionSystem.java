package systems;

import com.artemis.Aspect;
import com.artemis.ComponentMapper;
import com.artemis.Entity;
import com.artemis.EntitySystem;
import com.artemis.annotations.Wire;
import com.artemis.systems.EntityProcessingSystem;

import components.Position;

@Wire
public class PositionSystem extends EntityProcessingSystem {

	ComponentMapper<Position> position;
	
	public PositionSystem() {
		super(Aspect.all(Position.class));
		
	}

	@Override
	protected void process(Entity e) {
		
		for (int i = 0; i < 10; i++) {
			position.get(e).x++;
			position.get(e).y++;
//			e.position().x++;
//			e.position().y++;
		}
	}

}
