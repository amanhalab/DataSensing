
PFont font;
DataEngine engine;


void setup() {
  
  background(0);

  // Tipografia
  font = loadFont("FFFEstudio-8.vlw");
  textFont(font, 8);

  // Carregar dados
  // parametro: quantos dias para tras
  engine = new DataEngine(75);
  thread("loadDataEngineJSON");

  surface.setTitle("processing_vis");
  
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
      drawVis();
      break;
    }

}

// Loading

void drawLoading(){

  fill(255);

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  text("ANALISANDO FELICITOMETRO", 15, baseHeight - 35);
  text("NOS ÚLTIMOS 30 DIAS", 15, baseHeight - 15);

}

// Vis

void drawVis() {

  
  int space = 6;
  int radius = 4;
  int x = 6;

  // percorrer todos os dias

  for (FeliciDate f : engine.felicidates) {
    
    // se existe count

    fill(0,0,255);
    noStroke();

    for (int i = 0; i < f.count ; i++) {
      ellipse(x, space + i * space, radius, radius);
    }

    // senao

    noFill();
    stroke(50);

    if(f.count == 0){
      line(x, space, x, space * space);
    }

    // proximo dia

    x += space;

  }

}
