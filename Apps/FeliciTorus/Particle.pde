

class Particle {

  // incoming value that will define number of points
  int value;
  // counter to go through each point
  int count;
  //distnace that particle can get before being removed 
  int limit;

  // current orbit, or object counter
  float orbit;
  // current objecto in particles list
  int currentObject;
  // total number of objects of particles
  int totalObjects;

  // is done creating points ?
  boolean isOver = false;
  //are all particles out of the 0, 0 radius ?
  boolean isReleased = false;


  // vectos points lists for each point
  PVector [] center;
  PVector [] pos;
  PVector [] radius;//{new PVector(150., 90.0), new PVector(240, 120.0), new PVector(340, 200)};
  float [] counter;//{0, 0, 0};
  float [] size;//{20, 10, 30};
  float [] angle;
  float vel[];//{0.05, 0.01, 0.03};
  color [] colors;

  // orbit z angle
  float orbit_angle;

  // random value that is directed to velocity of object
  float rand;

  Particle(int _value, float _orbit, int _currentObject, int _totalObjects, float _rand) {

    value = _value;
    orbit = _orbit;
    rand = _rand;

    totalObjects = _totalObjects;
    currentObject = _currentObject;

    println(currentObject + " " + totalObjects);

    center = new PVector[value];
    pos = new PVector[value];
    radius = new PVector [value];//{new PVector(150., 90.0), new PVector(240, 120.0), new PVector(340, 200)};
    vel = new float [value];//{0.05, 0.01, 0.03};
    counter = new float[value];//{0, 0, 0};
    size = new float[value];//{20, 10, 30};
    angle = new float[value];
    colors = new color[value];

    // variable for calculating the variations withing each cluster
    float max_width = (value*orbit)/300;

    float radx;   // Radius
    float rady;
    float angle1; // angle
    float x;      // result
    float y;
    float z;

    for (int i=0; i<value; i++) {

      radx=0;
      angle1= 0;
      x = radx*cos(radians(angle1));
      y = radx*sin(radians(angle1));
      z = 0;

      center[i] = new PVector(x, y, z);
    }

    for (int i=0; i<value; i++) {
      pos[i] = new PVector(0, 0, 0);
      pos[i] = new PVector(0, 0, 0);
      radius[i] = new PVector(0, 0, random(-5, 5));
      vel[i] = rand;
      counter[i] = 0;
      size[i] = random(0.8, 1.5);
      angle[i] = random(360);
      colors[i] = color(255, 0, 255);
    }

  }

  void run() {  
    if (value != 0) {
      pushMatrix();
      render();
      popMatrix();
      calculate();
    }
  }

  void calculate() {

    colors[count] = color(255 - 255*count/value, 125*count/value, 255);      

    for (int i=0; i<count; i++) {
      //set values;
      angle[i] = 1- count/value;
      counter[i] +=  vel[i];
      pos[i].x = sin(counter[i]) * radius[i].x;
      pos[i].y = cos(counter[i]) * radius[i].y;
      pos[i].z = sin(counter[i] + angle[i]) * orbit_angle;

      if (isOver) {
        radius[i].x+=0.5 * 1.1;
        radius[i].y+=0.5 * 1.1;
      } else {
        radius[count].x+=0.5 * 1.1;
        radius[count].y+=0.5 * 1.1;
      }
      // check for moment in which the object is completely released from center 
      if (currentObject == totalObjects) {
        if ((count == value-1) && (i == count-1) 
          && (!isReleased) && (radius[count-1].x != 0)) {
          isReleased = true;
          println("particles released from center!");
          println();
        }
      }
    }
    if (count < value-1) {
      count++;
    } else {
      isOver = true;
    }
  }

  void render() {

    translate(width/2, height/2, -100);
    rotateX(8.8 -PI/2);
    rotateY(4.72-PI/2);

    // translate(-width/2, -height/2);

    for (int i=0; i<count; i++) {
      pushStyle();
      stroke(colors[i]);
      strokeWeight(size[i]*2);
      noFill();
      pushMatrix();
      translate( center[i].x+pos[i].x, center[i].y+pos[i].y, center[i].z+pos[i].z);
      point(0, 0);
      popMatrix();
      popStyle();
    }
  }
}