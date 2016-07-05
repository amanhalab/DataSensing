class Stream {

  int life;
  int maxlife;
  float mult;
  float lastValue;
  String addr;
  int frame;

  PVector p;

  ArrayList<Float> values = new ArrayList<Float>();

  Stream(String _addr){
    maxlife = WIDTH / 2;
    life = maxlife;
    addr = _addr;
    p = new PVector(0,0);
    frame = 0;
  }

  void addValue(float value, float _mult){
    life = maxlife;
    mult = _mult;
    lastValue = value;
  }

  void update(){
    life--;
    if(life < maxlife / 3 && values.size() >= 1){
      values.remove(0);
    }
    if(frame % 2 == 0){
      if(values.size()>=maxlife){
        values.clear();
      }
      values.add(lastValue);
    }
    frame = (frame + 1) % 1000;
  }

  void display(int index, int total, color c){

    float h = (HEIGHT-2) * 1.0 / total;
    float w = WIDTH / maxlife;

    float val = values.size() > 0 ? values.get(0) / mult : 0.5;

    noStroke();
    fill(c);

    int lastValue = 0;

if(values.size()>0){
     lastValue = int(values.get(values.size()-1));
}
    textAlign(LEFT, CENTER);
    text(addr + "/" + lastValue, 10, index * h + h * 0.5);



    noFill();
    stroke(c);
    // fill(c);
    // noStroke();

    // beginShape();

    for (int i = 1; i < values.size(); i++) {
      float next_val = values.get(i) / mult;
      line( (i-1) * w, 1 + index * h + (1-val) * h, i * w, 1 + index * h + (1-next_val) * h );
      // vertex((i-1) * w, 1 + index * h + (1-val) * h);
      // vertex((i-1) * w, 1 + index * h + h);
      // vertex(i * w, 1 + index * h + h);
      // vertex(i * w, 1 + index * h + (1-next_val) * h);
      val = next_val;
    }

    // endShape(CLOSE);

  }

}
