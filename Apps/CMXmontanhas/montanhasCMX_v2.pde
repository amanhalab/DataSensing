PFont font;
DataEngineCMX engine;

String yesterday;

float timer_x = 80;

int simulation_time = 6 * 60 * 60;
int frame = 0;
int fMax = 10;
int fMin = 100;

boolean print = false; // saveFrame()

PShader blur;       // Blur shader for lines

Landscape land;    

void setup() {

  background(0);

  // Carregar dados
  engine = new DataEngineCMX();
  thread("loadDataEngineJSON");

  // Tipografia
  font = loadFont("FFFEstudio-8.vlw");
  textFont(font, 8);

  // create landscape object
  land = new Landscape(20, 120, 1400);

  // Shader
  blur = loadShader("blur.glsl");
  
  // frameRate
  frameRate(300);
}


void draw() {

  //  background(0);

  // Checar status dos dados
  switch (engine.state) {
  case 0:
   // drawLoading();
    break;
  case 1:
    drawVis();
    simulation_time += 2;
    simulation_time = simulation_time % (24 * 60 * 60);
   drawTimer();
    break;
  }
}

void drawLoading() {

  fill(255);

  DateFormat dt = DateFormat.getDateInstance(DateFormat.FULL, new Locale("pt", "br"));
  yesterday = dt.format(engine.calendar.getTime()).toUpperCase();

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  text(yesterday, 15, baseHeight - 55);
  text("NUM  " + engine.num_records, 15, baseHeight - 35);
  //text("ANTENAS  " + engine.num_cmx, 15, baseHeight - 15);
}

void drawTimer() {

  fill(255);

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  if (simulation_time % (60 * 60) < 60 * 20) {
  //  text("USUARIOS", 15, baseHeight - 15);
    timer_x += (100 - timer_x) * 0.2;
  } else {
    timer_x += (15 - timer_x) * 0.2;
  }

  text(getTime(simulation_time), timer_x, 15);
}

void drawVis() {

  pushMatrix();
  land.render(); 
  popMatrix();
  land.calculate();

  frame = (frame + 1) % (60 * 60 * 24);


  if ( print == true) {
    saveFrame();
  }
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

// Screen Schot


void keyPressed() {
  if (key == 's') {
    if (print == false) { 
      print = true;
    } else if (print == true) {
      print = false;
    }
  }
}