class Stream {

  int life;
  float mult;
  String addr;

  PVector p;

  ArrayList<Float> values = new ArrayList<Float>();

  Stream(String _addr){
    life = 100;
    addr = _addr;
    p = new PVector(0,0);
  }

  void addValue(float value, float _mult){
    life = 200;
    mult = _mult;
    if(values.size()>=100){
      values.clear();
    }
    values.add(value);
  }

  void update(){
    life--;
    if(life < 100 && values.size() >= 1){
      values.remove(0);
    }
  }

  void display(int index, int total, color c){

    float h = (height-2) * 1.0 / total;
    float w = width / 100.0;

    float val = values.size() > 0 ? values.get(0) / mult : 0.5;

    noStroke();
    fill(c);

    int lastValue = int(values.get(values.size()-1));

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
