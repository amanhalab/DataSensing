PFont font;
PGraphics pg;
DataEngineCMX engine;

FlowGenerator[] antenas = new FlowGenerator[20];

String yesterday;

float timer_x = 80;

int simulation_time = 10 * 60 * 60;
int frame = 0;
int fMax = 10;
int fMin = 100;


void setup() {

  for (int i = 0; i < antenas.length; i++) {
    int h = (int)(HEIGHT * SCALEFACTOR / antenas.length);
    antenas[i] = new FlowGenerator((int)random(100), i * h, h );
  }

  //frameRate(30);

  // Carregar dados
  engine = new DataEngineCMX();
  thread("loadDataEngineJSON");

  // Tipografia
  font = loadFont("FFFEstudio-8.vlw");
  textFont(font, 8);

  // Iniciar PGraphics
  pg = createGraphics(int(WIDTH * SCALEFACTOR), int(HEIGHT * SCALEFACTOR), P2D);
  pg.beginDraw();
  pg.background(0);
  pg.endDraw();

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


  for(UniqueCMX cmx : engine.cmxList) {
      cmx.update(simulation_time);
  }


  //background(0);
  pg.beginDraw();
  pg.fill(0,50);
  pg.rect(0,0,WIDTH*SCALEFACTOR,HEIGHT*SCALEFACTOR);

  for (int i = 0; i < antenas.length; i++) {
    // if  (frame % (60) == 0) {
    //   antenas[i].regenerate();
    // }
    int index = i % engine.cmxList.size();
    UniqueCMX cmx = engine.cmxList.get(index);

    if(cmx.update(simulation_time)){
      float sum = cmx.connected + cmx.visitors + cmx.passerby;
      antenas[i].setFreq(sum);
      //println("antena " + index + " -- " + sum);
    }

    antenas[i].update(pg, frame);
  }

  pg.endDraw();

  image(pg, 0, OFFSET);

  frame = (frame + 1) % (60 * 60 * 24);

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
