class FlowerGenerator {

ArrayList<Flower> flowers = new ArrayList<Flower>();

float x;
color c;
int val;

FlowerGenerator(float _x, color _c, int _val) {
  x = _x;
  c = _c;
  val = _val;
}

void update() {

  // origin: center
  pushMatrix();
  translate(x, HEIGHT * 0.5);

  // draw flowers
  for (int i = flowers.size() - 1; i >= 0; i--) {
    Flower f = flowers.get(i);
    if (f.z > f.zmax) {
      flowers.remove(i);
    } else {
      f.update();
    }
  }

  popMatrix();

}

void add(int num, color c, float zvel, float anglevel) {
  flowers.add(new Flower(num, c, zvel, anglevel));
}

}


class Flower {

float z = 1;
float zmin = 1;
float zmax = 5;
float zfade = 2;

float zvel, anglevel;

float angleoffset = 0;

color c;
int num;
float radius;

Flower(int _num, color _c, float _zvel, float _anglevel) {
  num = _num;
  c = _c;
  zvel = _zvel;
  anglevel = _anglevel;
  radius = num;
  angleoffset = random(0,360);
}

void update() {

  radius += 0.06 * num;
  float anglefrag = 360 / num;

  noStroke();
  fill(c, getAlpha());

  for(int i = 0; i < num; i++){
    float angle = i * anglefrag + angleoffset;
    float x = radius * cos(radians(angle));
    float y = radius * sin(radians(angle));

    pushMatrix();
      translate(x, y);
      rotate(radians(angle));
      polygon(0, 0, z, 3);
    popMatrix();
  }

  z += zvel;
  angleoffset += anglevel;

}

float getRadius() {
    // if(z < zmin + (zmax-zmin) * 0.5){
    //   return num * 10 * map(z, zmin, zmin + (zmax-zmin) * 0.5, 0.2, 1);
    // }
    return num;
}

float getAlpha() {
  if(z < zmin + zfade) {
    return map(z, zmin, zmin + zfade, 0, 255);
  } else if(z > zmax - zfade){
    return map(z, zmax - zfade, zmax, 255, 0);
  }
  return 255;
}

}
