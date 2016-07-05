class Grove {

  int life;
  String addr;
  PVector pos;

  float vrotary = 0;
  float vlight = 0;
  float vranger = 0;
  float vbutton = 0;

  float nrotary = 0;
  float nlight = 0;
  float nranger = 0;
  float nbutton = 0;

  Grove(String _addr, PVector _pos) {
    addr = _addr;
    pos = _pos;
    life = 0;
  }

  void update(){
    if (life > 0) {
      life--;
    } else {
      nrotary = nbutton = nranger = nlight = 0;
    }

    vrotary = lerp(vrotary, nrotary, 0.1);
    vbutton = lerp(vbutton, nbutton, 0.1);
    vranger = lerp(vranger, nranger, 0.1);
    vlight = lerp(vlight, nlight, 0.1);

  }

  void addValue(String topicData, float value, float mult) {
    life = 100;
    switch (topicData) {
      case "rotary":
        nrotary = value / mult;
        break;
      case "button":
        nbutton = value / mult;
        break;
      case "ranger":
        nranger = value / mult;
        break;
      case "light":
        nlight = value / mult;
        break;
    }
  }

  void display(color c) {
    display(c, false);
  }

  void display(color c, boolean isIdle) {
    pushMatrix();
    translate(pos.x,pos.y);
    //rotate(radians(vrotary * 360));

    float radius = 30 + 40 - vranger * 40;

    colorMode(HSB);
    fill(c);
    arc(0, 0, radius + 30, radius + 30, 0, radians(vrotary * 360), PIE);

    colorMode(RGB);

    if (isIdle){
      fill(c);
    } else {
      fill(255 - 255 * vbutton, vbutton * 255, 0);
    }

    ellipse(0,0,radius,radius);

    if (isIdle){
      fill(80);
    } else {
      fill(255 - vbutton * 255);
    }

    textAlign(CENTER, CENTER);
    text(addr,0,0);
    popMatrix();
  }

  void displayIdle() {
    display(color(40), true);
  }

}