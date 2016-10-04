PFont font;
PGraphics pg;
DataEngineCMX engine;

String yesterday;

int simulation_time = 4 * 60 * 60;
int num_radars = 18;

float timer_x = 80;
float hue = 0;

Radar[] radar = new Radar[num_radars];

color c1 = color(238, 212, 15);
color c2 = color(215, 153, 24);
color c3 = color(238, 109, 15);

void setup() {

  //size(864, 144, P3D);
  pg = createGraphics(WIDTH, HEIGHT, P3D);

  //smooth();

  int offset = 50;

  for (int i = 0; i < num_radars; i++){
    radar[i] = new Radar(offset + ((WIDTH-offset*2) * i * 1.0 / (num_radars-1)), random(HEIGHT));
    radar[i].v1 = 0; //random(10,20);
    radar[i].v2 = 0; //random(20,30);
    radar[i].v3 = 0; //random(30,60);
    radar[i].max = 80;
  }

  // Tipografia
  font = loadFont("FFFEstudio-8.vlw");
  textFont(font, 8);

  // Carregar dados
  engine = new DataEngineCMX();
  thread("loadDataEngineJSON");

  surface.setTitle("processing_vis");
  
}

void draw() {

  background(0);

  // Checar status dos dados
  switch (engine.state) {
    case 0:
      drawLoading();
      break;
    case 1:
      drawVis();
      simulation_time += 2;
      simulation_time = simulation_time % (24 * 60 * 60);
      drawTimer();
      break;
    }

}


void drawLoading(){

  fill(255);

  DateFormat dt = DateFormat.getDateInstance(DateFormat.FULL, new Locale("pt","br"));
  yesterday = dt.format(engine.calendar.getTime()).toUpperCase();

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  text(yesterday, 15, baseHeight - 55);
  text("NUM  " + engine.num_records, 15, baseHeight - 35);
  text("ANTENAS  " + engine.num_cmx, 15, baseHeight - 15);

}

void drawTimer() {

  fill(255);

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  if(simulation_time % (60 * 60) < 60 * 20){
    text("ANTENAS", 15, baseHeight - 15);
    timer_x += (100 - timer_x) * 0.2;
  } else {
    timer_x += (15 - timer_x) * 0.2;
  }

  text(getTime(simulation_time), timer_x, baseHeight - 15);

}

void drawVis() {

  background(0);

  for(UniqueCMX cmx : engine.cmxList) {
      cmx.update(simulation_time);
  }

  // DRAW RADARS

  pg.beginDraw();
    pg.background(0);
    for (int i = 0; i < num_radars; i++){
      int index = i % engine.cmxList.size();
      UniqueCMX cmx = engine.cmxList.get(index);
      radar[i].v1 = map(cmx.connected, 0, engine.top_value, 5, 80);
      radar[i].v2 = map(cmx.visitors, 0, engine.top_value, 10, 80);
      radar[i].v3 = map(cmx.passerby, 0, engine.top_value, 20, 80);
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

  hue = (hue + 0.001) % 1;
  float offset = ( (1-hue) * 256 * 2);

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

String getTime(int unixtime) {

  DecimalFormat df = new DecimalFormat("00");

  int hours = floor(unixtime / (60 * 60));
  int minutes = floor(unixtime / 60) % 60;

  return df.format(hours) + "h" + df.format(minutes) + "m";

}

// THREAD

void loadDataEngineJSON() {
  engine.loadJSON();
}