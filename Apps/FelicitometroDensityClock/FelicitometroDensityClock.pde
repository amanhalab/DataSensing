import java.text.*;

PFont font;
PGraphics pg;

ColorScale scale = new ColorScale();

int timer = 0;
int timer_max = 60 * 60 * 24;
int timer_increment = 16;

Channel[] channels = new Channel[10];

float timer_x = 110;

void setup() {

  smooth(8);

  pg = createGraphics(width, height, P2D);
  pg.beginDraw();
  pg.background(0);
  pg.endDraw();

  font = loadFont("FFFEstudio-8.vlw");
  textFont(font, 8);

  for(int i = 0; i < 10; i++){
    channels[i] = new Channel(i);
  }

  scale.addColor(color(168, 33, 108), 100);
  scale.addColor(color(237, 27, 77), 50);
  scale.addColor(color(243, 108, 68), 50);
  scale.addColor(color(248, 220, 105), 50);
  scale.addColor(color(46, 150, 152), 100);

}

void draw() {

  background(0);

  drawDensityClock();
  drawClockNumbers();
  drawTimer();

  timer = (timer + timer_increment) % timer_max;

}

void drawDensityClock() {

  pg.beginDraw();
  pg.blendMode(BLEND);

  pg.fill(0, 50);
  pg.rect(0, 0, width, height);

  pg.blendMode(ADD);

  for(int i = 0; i < 10; i++){
    channels[i].display(pg, scale.getColorAt(i * 1.0 / 10), 700, 1000, 910 + i * 11, timer);
  }
  pg.endDraw();

  image(pg,0,0);

}

void drawClockNumbers(){

  float angle_in = 194;
  float angle_ini = 195;
  float angle_out = 210;

  for(int i = 0; i < 24; i++){
    float angle = 195 - 1 + timer * 15.0 / (60 * 60) - i * 15;
    if (angle > angle_in && angle < angle_out){
      fill(map(angle, angle_in + 2, angle_out, 255, 50));
      if(angle < angle_ini){
        fill(map(angle, angle_in, angle_ini, 50, 255));
      }
    } else {
      fill(50);
    }
    float radius = 1000 + 30;
    float x = 700 + sin(radians(angle)) * radius;
    float y = 1000 + cos(radians(angle)) * radius;
    pushMatrix();
    translate(x * SCALEFACTOR, OFFSET + y * SCALEFACTOR);
    rotate(radians(180-angle));
    textSize(16);
    textAlign(CENTER, CENTER);
    text(i+":00", 0, 0);
    popMatrix();
  }

}

void drawTimer() {

  fill(255);

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  textSize(8);
  textAlign(LEFT, CENTER);

  if((timer / (60 * 60)) % 2 == 0){
    text("FELICIDADE", 15, baseHeight - 15);
    timer_x += (110 - timer_x) * 0.2;
  } else {
    timer_x += (15 - timer_x) * 0.2;
  }

  text(getTime(timer), timer_x, baseHeight - 15);

}

String getTime(int unixtime) {

  DecimalFormat df = new DecimalFormat("00");

  int hours = floor(unixtime / (60 * 60));
  int minutes = floor(unixtime / 60) % 60;

  return df.format(hours) + "h" + df.format(minutes) + "m";

}
