
PFont font;
DataEngine engine;

ParticleSystem ps;

boolean adding;
boolean isNull;

PShader blur;

long startTimer;
int duration = 7000;

int totalDays = 30;
int counter = 0;

boolean print = false;
boolean isInitialized = false;

void setup() {

  background(0);

  // Tipografia
  font = loadFont("FFFEstudio-8.vlw");
  textFont(font, 8);

  // Carregar dados
  // parametro: quantos dias para tras
  engine = new DataEngine(totalDays);
  thread("loadDataEngineJSON");

  surface.setTitle("processing_vis");

  ps = new ParticleSystem();

  // Shader
  blur = loadShader("blur.glsl");

  startTimer = millis();
}

// THREAD

void loadDataEngineJSON() {
  engine.loadJSON();
}

// ADD PARTICLE OBJECT

void addParticle() {
  ps.addParticle();
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
    drawDate();
    break;
  }
}

// LOADING

void drawLoading() {

  fill(255);

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  text("ANALISANDO FELICITOMETRO", 15, baseHeight - 35);
  text("NOS ÚLTIMOS 30 DIAS", 15, baseHeight - 15);
}

void init(String day, int count, int id) {

  //initialize particle system
  ps.init(day, count, id);
  //    }
  adding = true;
  //println("key pressed");
}

// DRAW DATE

void drawDate() {

  float alpha;

  alpha = (millis() - ps.startTimer)/7;

  int baseHeight = height/2; 
  if (ps.currentDate != "") {
    if (ps.isReleased == false) {
      fill(255, alpha);
    } else {
      isInitialized = false;
      fill(255, 255 -alpha/2.5);
    }
    if (!isNull) {
      text(ps.currentDate, width/2 - textWidth(ps.currentDate)/2, height-20);
    }
  }
  //println("Current Date: " + currentDate);
}

// VIS

void drawVis() {

  background(0);

  int space = 6;
  int radius = 4;
  int x = 6;

  //check timer and if object is already initialized
  if (millis() - ps.startTimer > duration && !isInitialized) {
    // go through all the objects as much as days in engine class
    for (FeliciDate f : engine.felicidates) {  
      //if is id matches the general object counter
      if (f.id == counter) {
        // check if count number is not zero
        // if value
        if (f.value > 1) {
          isNull = false;
          ps.init(f.day, f.value, f.id);
          adding = true;
        } else {
          // if it is, start counter again with no text()
          isNull = true;
          ps.timer();
          println();
          println("-- " + counter + " null object!");
          println();
        }
      }
    }
    counter++;
    if (counter >= totalDays-1) {
      //ps.end();
      counter = 0;
      println("ended dates");
    }
    println(counter);
    isInitialized = true;
  }

  //addParticle stays running until it has create all sub-objects
  if (adding == true) {
    addParticle();
  } 
  //when particle system is done displaying, it stops addParticle()
  if (ps.allCreated == true) {
    adding = false;
  }

  // run particle system
  ps.run();
  filter(blur);
}