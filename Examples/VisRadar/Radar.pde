class Radar {

  float a1,a2,a3;
  float v1,v2,v3;
  float x,y;
  float max;

  Radar (float _x, float _y) {

    x = _x;
    y = _y;

    a1 = 0;
    a2 = 0;
    a3 = 0;

    v1 = 10;
    v2 = 20;
    v3 = 30;

    max = 40;

  }

  void update(PGraphics pg) {

    pg.noFill();

    float div = pow(max,2) * 2;

    a1 = (a1 + v1 / div) % 1.0;
    a2 = (a2 + v2 / div) % 1.0;
    a3 = (a3 + v3 / div) % 1.0;

    float aa1 = (a1 + 0.5) % 1.0;
    float aa2 = (a2 + 0.5) % 1.0;
    float aa3 = (a3 + 0.5) % 1.0;

    // V1
    pg.strokeWeight(getSize(a1));
    pg.stroke(c1, getOpacity(a1));
    pg.ellipse(x, y, getH(v1, a1), getH(v1, a1));
    pg.strokeWeight(getSize(aa1));
    pg.stroke(c1, getOpacity(aa1));
    pg.ellipse(x, y, getH(v1, aa1), getH(v1, aa1));

    // V2
    pg.strokeWeight(getSize(a2));
    pg.stroke(c2, getOpacity(a2));
    pg.ellipse(x, y, getH(v2, a2), getH(v2, a2));
    pg.strokeWeight(getSize(aa2));
    pg.stroke(c2, getOpacity(aa2));
    pg.ellipse(x, y, getH(v2, aa2), getH(v2, aa2));

    // V3
    pg.strokeWeight(getSize(a3));
    pg.stroke(c3, getOpacity(a3));
    pg.ellipse(x, y, getH(v3, a3), getH(v3, a3));
    pg.strokeWeight(getSize(aa3));
    pg.stroke(c3, getOpacity(aa3));
    pg.ellipse(x, y, getH(v3, aa3), getH(v3, aa3));


  }

  float getH(float v, float t){
    return lerp(0, v / max * HEIGHT * 2, t);
  }

  float getOpacity(float t){
    float o = 100;
    if(t<0.2){
      o = map(t,0,0.2,0,o);
    } else if (t > 0.8){
      o = map(t,1.0,0.8,0,o);
    }
    return o;
  }

  float getSize(float t){
    return map(t,0,1,10,2);
  }

}
