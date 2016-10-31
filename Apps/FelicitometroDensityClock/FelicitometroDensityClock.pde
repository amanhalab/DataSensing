import java.text.*;

PFont font;
PGraphics pg;
DataEngine engine;

ColorScale scale = new ColorScale();

int timer = 0;
int timer_max = 60 * 60 * 30;
int timer_increment = 16;

int numChannels = 5;
int numChannelsLoaded = 0;
Channel[] channels = new Channel[numChannels];

float timer_x = 110;

void setup() {

  smooth(8);
  
  background(0);

  pg = createGraphics(width, height, P2D);
  pg.beginDraw();
  pg.background(0);
  pg.endDraw();

  font = loadFont("FFFEstudio-8.vlw");
  textFont(font, 8);

  scale.addColor(color(168, 33, 108), 100);
  scale.addColor(color(237, 27, 77), 50);
  scale.addColor(color(243, 108, 68), 50);
  scale.addColor(color(248, 220, 105), 50);
  scale.addColor(color(46, 150, 152), 100);

  surface.setTitle("processing_vis");

  // Carregar dados
  // parametro: quantos dias para tras
  engine = new DataEngine(30);
  thread("loadDataEngineJSON");
  
}

// THREAD

void loadDataEngineJSON() {
  engine.loadJSON();
}

// DRAW

void draw() {

  background(0);

  switch (engine.state) {
    case 0:
      drawLoading();
      break;
    case 1:
      for (Map.Entry entry : engine.scores.descendingMap().entrySet()) {
        Integer id = (Integer)(entry.getValue());
        Poi p = engine.pois.get(id);
        if(numChannelsLoaded < numChannels){
          channels[numChannelsLoaded] = new Channel(numChannelsLoaded, p, engine.minval, engine.maxval);
          numChannelsLoaded++;
        } else {
          break;
        }
      }
      engine.state = 2;
    case 2:
      drawDensityClock();
      drawClockNumbers();
      drawTimer();
      timer = (timer + timer_increment) % timer_max;
      break;
  }

}

// LOADING

void drawLoading(){

  fill(255);

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  text("ANALISANDO FELICITOMETRO", 15, baseHeight - 35);
  text("NOS ÚLTIMOS 30 DIAS", 15, baseHeight - 15);

}

void drawDensityClock() {

  pg.beginDraw();
  pg.blendMode(BLEND);

  pg.fill(0, 50);
  pg.rect(0, 0, width, height);

  pg.blendMode(ADD);

  for(int i = 0; i < numChannels; i++){
    channels[i].display(pg, scale.getColorAt(i * 1.0 / numChannels), 700, 1000, 950 + i * 11, timer);
  }
  pg.endDraw();

  image(pg,0,0);

}

void drawClockNumbers(){

  float angle_in = 194;
  float angle_ini = 195;
  float angle_out = 210;

  for(int i = 0; i < 30; i++){
    float angle = 195 + timer * 12.0 / (60 * 60) - i * 12;
    if (angle > angle_in && angle < angle_out){
      fill(map(angle, angle_in + 2, angle_out, 255, 50));
      if(angle < angle_ini){
        fill(map(angle, angle_in, angle_ini, 50, 255));
      }
    } else {
      fill(50);
    }
    float radius = 1000+20;
    float x = 700 + sin(radians(angle)) * radius;
    float y = 1000 + cos(radians(angle)) * radius;
    pushMatrix();
    translate(x * SCALEFACTOR, OFFSET + y * SCALEFACTOR);
    rotate(radians(180-angle));
    textSize(16);
    textAlign(CENTER, CENTER);
    text(engine.monthdays.get(i), 0, 0);
    popMatrix();
  }

}

void drawTimer() {

  fill(255);

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  textSize(8);
  textAlign(LEFT, CENTER);

  text("FELICITOMETRO", 15, baseHeight - 15);

  /*
  if((timer / (60 * 60)) % 2 == 0){
    text("FELICIDADE", 15, baseHeight - 15);
    timer_x += (110 - timer_x) * 0.2;
  } else {
    timer_x += (15 - timer_x) * 0.2;
  }

  text(getTime(timer), timer_x, baseHeight - 15);
  */

}

String getTime(int unixtime) {

  DecimalFormat df = new DecimalFormat("00");

  int hours = floor(unixtime / (60 * 60));
  int minutes = floor(unixtime / 60) % 60;

  return df.format(hours) + "h" + df.format(minutes) + "m";

}