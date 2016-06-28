import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import megamu.mesh.*;

PFont font;
DataEngineBus engine;
VerletPhysics2D physics;

ArrayList<Target> targets = new ArrayList<Target>();
ArrayList<Vec2D> particles = new ArrayList<Vec2D>();
ArrayList<Integer> bus_lines = new ArrayList<Integer>();

HashMap<String, Vec2D> buses_vec = new HashMap<String, Vec2D>();

ColorScale scale = new ColorScale();

float[][] points;
color[] bus_lines_color;

String yesterday;

int simulation_time = 4 * 60 * 60;

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

  scale.addColor(color(168, 168, 168), 50);
  scale.addColor(color(205, 82, 123), 50);
  scale.addColor(color(232, 23, 94), 50);
  scale.addColor(color(50), 50);
  scale.addColor(color(70), 50);

  physics = new VerletPhysics2D();
  physics.setDrag(0.5f);
  physics.setWorldBounds(new Rect(-10, -10, (SCALED ? SCALEDWIDTH : WIDTH) + 20, (SCALED ? SCALEDHEIGHT : HEIGHT) + 20));

  int numParticles = SCALED ? 200 : 100;

  for(int i = 0; i < numParticles; i++){

    float x = random(SCALED ? SCALEDWIDTH : WIDTH);
    float y = random(SCALED ? SCALEDHEIGHT : HEIGHT);

    VerletParticle2D p = new VerletParticle2D(x, y);
    physics.addBehavior(new AttractionBehavior(p, 20, -1.2f));
    physics.addParticle(p);
    particles.add(p);
  }

}


void draw() {

  background(0);

  // Checar status dos dados
  switch (engine.state) {
    case 0:
      //drawFlowGrid();
      drawLoading();
      break;
    case 1:
      updateTargets();
      physics.update();
      drawVoronoi();
      simulation_time += 2;
      simulation_time = simulation_time % (24 * 60 * 60);
      drawTimer();
      break;
    }

}

void drawLoading(){

  fill(255);

  int baseHeight = OFFSET + int(HEIGHT * SCALEFACTOR);

  DateFormat dt = DateFormat.getDateInstance(DateFormat.FULL, new Locale("pt","br"));
  yesterday = dt.format(engine.calendar.getTime()).toUpperCase();

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
    if(bus_lines.indexOf(bus.bus_line_id) == -1) {
      bus_lines.add(bus.bus_line_id);
    }
    if (!buses_vec.containsKey(bus.bus_id)) {
      Vec2D v = new Vec2D(0,0);
      buses_vec.put(bus.bus_id, v );
      physics.addBehavior(new AttractionBehavior(v, 30, -1.2f));
    }

    Vec2D v = buses_vec.get(bus.bus_id);

    if(bus.checkTime(simulation_time)){
      PVector pos = bus.getInterpolatedPosition();
      v.x = pos.x = lng2screen(pos.x);
      v.y = pos.y = lat2screen(pos.y);
      if(bus.speed >= 1){
        if(targets.size() > 1){
          float d = 100;
          for (Target t : targets) {
            d = min(d, t.pos.dist(pos));
          }
          if(d > 1){
            targets.add(new Target(pos, bus));
          }
        } else {
          targets.add(new Target(pos, bus));
        }
      }
    } else {
      v.x = 0;
      v.y = 0;
    }
  }

}

void drawVoronoi() {

  int hour_interval = simulation_time % (60 * 60);

  if(hour_interval > 60 * 22 && hour_interval < 60 * 52){
    timer_bus_alpha += 0.01 * (255 - timer_bus_alpha);
  } else {
    timer_bus_alpha += 0.05 * (0 - timer_bus_alpha);
  }

  points = new float[targets.size() + particles.size()][2];
  bus_lines_color = new int[targets.size() + particles.size()];

  int k = 0;
  for (Target t : targets) {
      points[k][0] = t.pos.x;
      points[k][1] = t.pos.y;
      bus_lines_color[k] = scale.getColorAt(bus_lines.indexOf(t.bus.bus_line_id)*1.0/bus_lines.size());
      k++;
  }

  for (Vec2D p : particles) {
      points[k][0] = p.x;
      points[k][1] = p.y;
      bus_lines_color[k] = color(0);
      k++;
  }

  // println(k + " -- " + targets.size() + " -- " + points.length);

  try {
    Voronoi myVoronoi = new Voronoi( points );
    MPolygon[] myRegions = myVoronoi.getRegions();

    for (int i = 0; i < myRegions.length; i++) {
      float[][] regionCoordinates = myRegions[i].getCoords();
      noStroke();
      fill(bus_lines_color[i]);
      myRegions[i].draw(this);
    }
  } catch (ArrayIndexOutOfBoundsException e) {
    println("Array index out of bounds.");
  }

  //filter(BLUR, 1);

  //timer_bus_alpha = 255;
  if(timer_bus_alpha > 0) {
    for (Target t : targets) {
        noStroke();
        //color c = getColor(t.bus.bus_line_id);
        fill(255, timer_bus_alpha);
        //fill(c);
        ellipse(t.pos.x, t.pos.y, 3, 3);
    }
  }

  // for (Vec2D p : particles) {
  //     fill(50);
  //     ellipse(p.x, p.y, 3, 3);
  // }

}

String getTime(int unixtime) {

  DecimalFormat df = new DecimalFormat("00");

  int hours = floor(unixtime / (60 * 60));
  int minutes = floor(unixtime / 60) % 60;

  return df.format(hours) + "h" + df.format(minutes) + "m";

}

float lng2screen(float lng){
  return map(lng, -43.4, -43.15, 0, SCALED ? SCALEDWIDTH : WIDTH);
}

float lat2screen(float lat){
  return map(lat, -22.75, -23, 0, SCALED ? SCALEDHEIGHT : HEIGHT);
}

// THREAD

void loadDataEngineJSON() {
  engine.loadJSON();
}
