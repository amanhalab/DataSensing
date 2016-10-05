
int num_radars = 20;
Radar[] radar = new Radar[num_radars];

color c1 = color(238, 212, 15);
color c2 = color(215, 153, 24);
color c3 = color(238, 109, 15);

float m = 0;
PGraphics pg;

void setup() {

  //size(864, 144, P3D);
  pg = createGraphics(WIDTH, HEIGHT, P3D);

  //smooth();

  int offset = 50;

  for (int i = 0; i < num_radars; i++){
    radar[i] = new Radar(offset + ((WIDTH-offset*2) * i * 1.0 / (num_radars-1)), random(HEIGHT));
    radar[i].v1 = random(10,20);
    radar[i].v2 = random(20,30);
    radar[i].v3 = random(30,60);
    radar[i].max = 60;
  }

}

void draw() {

  background(0);

  // DRAW RADARS

  pg.beginDraw();
    pg.background(0);
    for (int i = 0; i < num_radars; i++){
      radar[i].update(pg);
    }
    // THRESHOLD FILTER
    if(!mousePressed){
      pg.filter(THRESHOLD,0.6);
    }
  pg.endDraw();

  if(!mousePressed){
    // FAST BLUR
    fastblur(pg, 2);

  // DRAW B&W IMAGE
  pushMatrix();
  translate(0,OFFSET);
  scale(SCALEFACTOR);
  image(pg, 0, 0);
  popMatrix();

  // DRAW COLORS
  colorMode(HSB);
  blendMode(MULTIPLY);

  m = (m + 0.001) % 1;
  float offset = ( (1-m) * 256 * 2);

  for (int i = 0; i < WIDTH * SCALEFACTOR; i ++) {
    float offset_i = i * 1.0 / WIDTH * SCALEFACTOR * 100;
    float hue = (offset + offset_i) % 256;
    stroke(hue, 255, 255);
    line(i, OFFSET, i, OFFSET + HEIGHT * SCALEFACTOR);
  }
}else{
  image(pg, 0, 0);
}
  // BACK TO DEFAUKT BLEND MODE
  blendMode(BLEND);

  // frame.setTitle("VisCMXRadar (fps)" + frameRate);

}
