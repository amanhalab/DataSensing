import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

int NUM_PARTICLES = 800;
int NUM_GROUPS = 8;

ColorScale scale = new ColorScale();

VerletPhysics2D physics;
AttractionBehavior mouseAttractor;

ArrayList<Target> groups = new ArrayList<Target>();

void setup() {


  background(0);


  // setup physics with 10% drag
  physics = new VerletPhysics2D();
  physics.setDrag(0.5f);
  physics.setWorldBounds(new Rect(-50, -50, WIDTH * SCALEFACTOR + 100, HEIGHT * SCALEFACTOR + 100));
  // the NEW way to add gravity to the simulation, using behaviors
  //physics.addBehavior(new GravityBehavior(new Vec2D(0, 0.15f)));

  for (int i = 0; i < NUM_GROUPS; i++) {
    groups.add(new Target(new Vec2D(random(WIDTH * SCALEFACTOR), random(HEIGHT * SCALEFACTOR)), new Vec2D(random(-0.5, 0.5), random(-0.5,0.5))));
  }

  scale.addColor(color(168, 33, 108), 100);
  scale.addColor(color(237, 27, 77), 50);
  scale.addColor(color(243, 108, 68), 50);
  scale.addColor(color(248, 220, 105), 50);
  scale.addColor(color(46, 150, 152), 100);

}

void addParticle(int index) {

  int i = index % NUM_GROUPS;

  println(index + " " + i + " --- " + groups.size());

  VerletParticle2D p = new VerletParticle2D(Vec2D.randomVector().scale(5).addSelf(WIDTH * SCALEFACTOR / 2, 0));
  p.addBehavior(new AttractionBehavior(groups.get(i).pos, 1000 * SCALEFACTOR, 0.8f));
  for (Target g : groups) {
    p.addBehavior(new AttractionBehavior(g.pos, 10 * SCALEFACTOR, -2.2f));
  }
  physics.addParticle(p);
  // add a negative attraction force field around the new particle
  physics.addBehavior(new AttractionBehavior(p, 12 * SCALEFACTOR, -1.2f));
}

void draw() {

  fill(0,15);
  rect(0,0,width,height);
  background(0);

  //blendMode(ADD);

  if (physics.particles.size() < NUM_PARTICLES) {
    addParticle(physics.particles.size());
  }

  physics.update();


  // draw network

  int k = 0;

  for (VerletParticle2D a : physics.particles) {

    int index = k % NUM_GROUPS;
    float distToGroup = a.distanceToSquared(groups.get(index).pos);

    color c = scale.getColorAt((index) * 1.0 / NUM_GROUPS);

    k++;

    int j = 0;

    for (VerletParticle2D b : physics.particles) {

      int bindex = j % NUM_GROUPS;
      float dist = b.distanceToSquared(a);

      if (dist < 150 * SCALEFACTOR){
        if(bindex != index){
          float alpha = map(dist, 150 * SCALEFACTOR, 0, 0, 70);
          stroke(255, alpha);
        } else {
          float alpha = map(dist, 150 * SCALEFACTOR, 0, 0, 40);
          stroke(c, alpha);
        }
        // stroke(c, 25);
        line(a.x * SCALEFACTOR,a.y * SCALEFACTOR,b.x * SCALEFACTOR,b.y * SCALEFACTOR);
      }
      j++;

    }

  }

  // draw particles

  k = 0;

  for (VerletParticle2D a : physics.particles) {
    int index = k % NUM_GROUPS;
    color c = scale.getColorAt((index) * 1.0 / NUM_GROUPS);
    noStroke();
    fill(c);
    ellipse(a.x * SCALEFACTOR, a.y * SCALEFACTOR, 2 * SCALEFACTOR, 2 * SCALEFACTOR);
    k++;
  }

  int i = 0;

  for (Target g : groups) {

    g.update();

  }

}


class Target {
  Vec2D pos, velo;
  Target (Vec2D _pos, Vec2D _velo) {
    pos = _pos;
    velo = _velo;
  }
  void update() {
    pos.x += velo.x;
    pos.y += velo.y;
    if (pos.x > WIDTH * SCALEFACTOR) {
      velo.x *= -1;
      pos.x--;
    } else if(pos.x < 0){
      velo.x *= -1;
      pos.x++;
    }
    if (pos.y > HEIGHT * SCALEFACTOR) {
      velo.y *= -1;
      pos.y--;
    } else if(pos.y < 0){
      velo.y *= -1;
      pos.y++;
    }
  }
}
