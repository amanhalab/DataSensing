class FlowGenerator {

  ArrayList<Particle> particles = new ArrayList<Particle>();

  int seed, y, h, freq;

  FlowGenerator(int _seed, int _y, int _h) {
    y = _y;
    h = _h;
    seed = _seed;
    regenerate();
  }

  void regenerate() {
    freq = (int)random(fMax,fMin);
  }

  void setFreq(float f) {
    freq = (int)map(f, 0, engine.top_value, fMax, fMin);
  }

  void update(PGraphics pg, int time) {

    pg.pushMatrix();
    pg.translate(0, y);

    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      if (p.x > width) {
        particles.remove(i);
      } else {
        p.update(pg, h-2);
      }
    }

    pg.popMatrix();

    //float mult = 20;
    // if (time % (seed + int(map(freq, fMin, fMax, fMax * mult, fMin / mult))) == 0) {
    //   particles.add(new Particle(freq));
    // }
    if ((seed + time) % (int(map(freq, fMin, fMax, 10, 100))) == 0) {
      particles.add(new Particle(freq));
    }

  }

}
