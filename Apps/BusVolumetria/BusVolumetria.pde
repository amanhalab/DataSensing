PFont font;
DataEngineBus engine;
ArrayList<Target> targets = new ArrayList<Target>();

String yesterday;

int simulation_time = 4 * 60 * 60;

float flow = 0;
float timer_x = 80;
float timer_bus_alpha = 0;

void setup() {

  background(0);

  // Tipografia
  font = loadFont("FFFEstudio-8.vlw");
  textFont(font, 8);

  // Carregar dados
  engine = new DataEngineBus();
  thread("loadDataEngineJSON");
}


void draw() {

  background(0);

  // Checar status dos dados
  switch (engine.state) {
    case 0:
      drawFlowGrid();
      drawLoading();
      break;
    case 1:
      updateTargets();
      drawFlowGrid();
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
  text("GPS  " + engine.num_positions, 15, baseHeight - 35);
  text("ÔNIBUS  " + engine.num_buses, 15, baseHeight - 15);

}

void drawTimer() {

  fill(255);

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  if(simulation_time % (60 * 60) < 60 * 20){
    text("ÔNIBUS", 15, baseHeight - 15);
    timer_x += (80 - timer_x) * 0.2;
  } else {
    timer_x += (15 - timer_x) * 0.2;
  }

  text(getTime(simulation_time), timer_x, baseHeight - 15);

}

void updateTargets() {

  targets.clear();

  for (Map.Entry entry : engine.buses.entrySet()) {
    Bus bus = (Bus)(entry.getValue());
    if(bus.checkTime(simulation_time)){
      PVector pos = bus.getInterpolatedPosition();
      pos.x = lng2screen(pos.x);
      pos.y = lat2screen(pos.y);
      targets.add(new Target(pos, bus));
    }
  }

}

void drawFlowGrid() {

  int cols = 132;
  int rows = 22;

  int spacing = 8;

  float minSize = 12;
  float maxSize = 50;
  float maxDist = 50;

  PVector p = new PVector();

  int hour_interval = simulation_time % (60 * 60);

  for (int i = 0; i < cols * rows; i++) {

    int col = i % cols;
    int row = floor(i / cols);

    p.x = flow - 16 + col * spacing;
    p.y = -10 + row * spacing + cos(p.x * 0.03) * 10;

    float s = minSize;

    for (Target t : targets) {
      float d = t.pos.dist(p);
      if (d < maxDist) {
        float _s = map(d, 0, maxDist, t.bus.speed * 0.8, minSize);
        //s += 0.25;
        //s = min(maxSize, max(s, _s));
        s = max(s, _s);
      }
    }

    float alpha = min(100, map(s, minSize, maxSize, 40, 150));

    strokeWeight(1);
    stroke(255, alpha);

    fill(0);

    ellipse(p.x * SCALEFACTOR, OFFSET + p.y * SCALEFACTOR, s * SCALEFACTOR, s * SCALEFACTOR);
  }

  if(hour_interval > 60 * 22 && hour_interval < 60 * 52){
    timer_bus_alpha += 0.01 * (255 - timer_bus_alpha);
  } else {
    timer_bus_alpha += 0.05 * (0 - timer_bus_alpha);
  }

  if(timer_bus_alpha > 0){
    for (Target t : targets) {
      noStroke();
      fill(255, timer_bus_alpha);
      float radius = 3 * SCALEFACTOR;
      ellipse(t.pos.x * SCALEFACTOR, OFFSET + t.pos.y * SCALEFACTOR, radius, radius);
    }
  }

  flow += 0.4;
  flow = flow % 16;
}

String getTime(int unixtime) {

  DecimalFormat df = new DecimalFormat("00");

  int hours = floor(unixtime / (60 * 60));
  int minutes = floor(unixtime / 60) % 60;

  return df.format(hours) + "h" + df.format(minutes) + "m";

}

float lng2screen(float lng){
  return map(lng, -43.4, -43.15, 0, WIDTH);
}

float lat2screen(float lat){
  return map(lat, -22.75, -23, 0, HEIGHT);
}

// THREAD

void loadDataEngineJSON() {
  engine.loadJSON();
}
