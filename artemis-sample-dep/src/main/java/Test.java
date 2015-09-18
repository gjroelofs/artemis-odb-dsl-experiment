
import com.artemis.Entity;
import com.artemis.TestEntityManager;
import com.artemis.World;
import com.artemis.WorldConfiguration;

import components.Position;
import systems.PositionSystem;

public class Test {

	public static void main(String[] args) {
		World w = new World(new WorldConfiguration().setManager(new TestEntityManager(200))
													.setSystem(new PositionSystem()));

		int entities = 500000;
		int runs = 20;
		int processCalls = 10;

		for (int i = 0; i < entities; i++) {
			Entity e = w.createEntity()
						.addPosition(0, 0);
		}

		long min = Long.MAX_VALUE;
		long total = 0;
		for (int i = 0; i < runs; i++) {
			long then = System.currentTimeMillis();
			for (int j = 0; j < processCalls; j++) {
				w.process();
			}
			long delta = System.currentTimeMillis() - then;
			total += delta;
			min = Math.min(delta, min);
		}

		System.out.println(total / runs + " ms per run, min: " + min);
	}

}
