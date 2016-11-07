import java.text.*;

PFont font;
DataEngine engine;

ArrayList<FlowerGenerator> flowers;
int num_flowers = 10;

int frame = 0;
int dayframes = 300;

float timer_x = 80;

void setup() {

  colorMode(HSB);

  // Tipografia
  font = loadFont("FFFEstudio-8.vlw");
  textFont(font, 8);

  flowers = new ArrayList<FlowerGenerator>();

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

      for(int i = 0; i < num_flowers; i++){
        float x = map(i, 0, (num_flowers-1), 80, WIDTH - 80);
        float hue = map(i, 0, (num_flowers-1), 0, 255);
        flowers.add(new FlowerGenerator(x, color(hue,255,255)));
      }

      engine.state = 2;
      break;

    case 2:
      drawVis();
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

// VIS

void drawVis() {

  colorMode(RGB);
  background(0);
  drawTimer();

  colorMode(HSB);

  int i = 0;

  for (Map.Entry entry : engine.scores.descendingMap().entrySet()) {
        
    Integer id = (Integer)(entry.getValue());
    Poi p = engine.pois.get(id);
    int val = (int)map(p.count.get(frame / dayframes), engine.minval, engine.maxval, 3, 12);
    
    FlowerGenerator f = flowers.get(i);

    f.update();

    if(frame % (val > 5 ? 15 : 30) == 0){
      f.add(val, f.c, 0.05, 0.5);
    }

    if(i >= num_flowers - 1){
      break;
    }

    i++;
    
  }

  frame = (frame + 1) % (30 * dayframes);

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

void drawTimer() {

  fill(255);
  //text(yesterday + " às " + getTime(simulation_time), 15, height - 15);

  if((frame / (dayframes * 3)) % 2 == 0){
    text("FELICIDADE", 15, height - 15);
    timer_x += (110 - timer_x) * 0.2;
  } else {
    timer_x += (15 - timer_x) * 0.2;
  }

  float daytime = (float)(frame % dayframes) / dayframes;

  text(engine.monthdays.get(frame / dayframes) + " - " + nf((int)(daytime * 24),2) + "H", timer_x, HEIGHT - 15);

}
