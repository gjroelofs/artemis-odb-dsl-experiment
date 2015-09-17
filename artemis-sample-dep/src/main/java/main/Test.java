package main;

import com.artemis.Entity;
import com.artemis.World;
import com.artemis.WorldConfiguration;

import components.Position;
import systems.PositionSystem;

public class Test {

	public static void main(String[] args) {
		World w = new World(new WorldConfiguration().setSystem(new PositionSystem()));

		int entities = 1000000;
		int runs = 50;
		int processCalls = 10;

		for (int i = 0; i < entities; i++) {
			Entity e = w.createEntity()
						.edit()
						.add(new Position())
						.getEntity();
		}

		long total = 0;
		for (int i = 0; i < runs; i++) {
			long then = System.currentTimeMillis();
			for (int j = 0; j < processCalls; j++) {
				w.process();
			}
			total += System.currentTimeMillis() - then;
		}
		
		System.out.println(total / runs + " ms per run");
	}

}
