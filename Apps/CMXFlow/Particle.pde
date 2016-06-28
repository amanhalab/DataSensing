class Particle {

  float x, freq;

  Particle(float _freq) {
    x = -100;
    freq = _freq;
  }

  void update(PGraphics pg, int h) {

    float w = freq;

    pg.noStroke();
    pg.fill(220, map(freq, fMin, fMax, 255, 25));

    if(x <= (WIDTH * SCALEFACTOR / 2) - w + 10){
      pg.rect(x, 4 * SCALEFACTOR, w, h - 2 * SCALEFACTOR);
      pg.rect(WIDTH * SCALEFACTOR - x - w, 4 * SCALEFACTOR, w, h - 2 * SCALEFACTOR);
    }

    x += 1 + pow(freq, 2) * 0.0005;

  }

}
