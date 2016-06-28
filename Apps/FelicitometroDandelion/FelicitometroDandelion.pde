import java.text.*;

PFont font;

ArrayList<FlowerGenerator> flowers;
int num_flowers = 10;

int frame = 0;
float timer_x = 80;

void setup() {

    colorMode(HSB);

    // Tipografia
    font = loadFont("FFFEstudio-8.vlw");
    textFont(font, 8);

    flowers = new ArrayList<FlowerGenerator>();

    for(int i = 0; i < num_flowers; i++){
      float x = map(i, 0, (num_flowers-1), 80, WIDTH - 80);
      float hue = map(i, 0, (num_flowers-1), 0, 255);
      flowers.add(new FlowerGenerator(x,color(hue,255,255),(int)random(3,12)));
    }

}

void draw() {

  colorMode(RGB);
  background(0);
  drawTimer();

  colorMode(HSB);

  for (FlowerGenerator f : flowers) {
    f.update();

    if(frame % (f.val > 5 ? 60 : 120) == 0){
      f.add(f.val, f.c, 0.05, 0.5);
    }

    if(frame % (60 * 20) == 0 ){
      if(random(0,10) < 8){
        f.val = (int)random(3,6);
      } else {
        f.val = (int)random(6,12);
      }
    }
  }



  frame = (frame + 5) % (24 * 60 * 60);

}


void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}


String getTime(int unixtime) {

  DecimalFormat df = new DecimalFormat("00");

  int hours = floor(unixtime / (60 * 60));
  int minutes = floor(unixtime / 60) % 60;

  return df.format(hours) + "h" + df.format(minutes) + "m";

}

void drawTimer() {


  fill(255);
  //text(yesterday + " às " + getTime(simulation_time), 15, height - 15);

  if((frame / (60 * 60)) % 2 == 0){
    text("FELICIDADE", 15, height - 15);
    timer_x += (110 - timer_x) * 0.2;
  } else {
    timer_x += (15 - timer_x) * 0.2;
  }

  text(getTime(frame), timer_x, HEIGHT - 15);

}
