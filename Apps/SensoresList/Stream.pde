class Stream {

  int life;
  int maxlife;
  float mult;
  float lastValue;
  String addr;
  int frame;

  PVector p;

  ArrayList<Float> values = new ArrayList<Float>();
  ArrayList<Float> oldValues = new ArrayList<Float>();

  Stream(String _addr){
    maxlife = 300;
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
        oldValues.clear();
        for (int i = 1; i < values.size(); i++) {
          oldValues.add(values.get(i));
        }
        values.clear();
      }
      values.add(lastValue);
    }
    frame = (frame + 1) % 1000;
  }

  void display(int index, int total, color c){
  
    int offset = 120;
    
    float h = (HEIGHT-4) * 1.0 / total;
    float w = (WIDTH * 1.0 - offset) / maxlife;

    float val = values.size() > 0 ? values.get(0) / mult : 0.5;
    float val2 = oldValues.size() > 0 ? oldValues.get(0) / mult : 0.5;

    noStroke();
    fill(c);

    int lastValue = 0;

    if(values.size()>0){
         lastValue = int(values.get(values.size()-1));
    }
    
    textAlign(LEFT, CENTER);
    text(addr + "/" + lastValue, 10, index * h + h * 0.5);
    
    noFill();
    strokeWeight(2);
    
    pushMatrix();
    
    translate(offset,0);
    
    stroke(c, max(50.0, map(values.size(),0.0,30.0,255.0,50.0)));
    
    for (int i = 1; i < oldValues.size(); i++) {
      float next_val = oldValues.get(i) / mult;
      line( (i-1) * w, 2 + index * h + (1-val2) * h, i * w, 2 + index * h + (1-next_val) * h );
      // vertex((i-1) * w, 1 + index * h + (1-val) * h);
      // vertex((i-1) * w, 1 + index * h + h);
      // vertex(i * w, 1 + index * h + h);
      // vertex(i * w, 1 + index * h + (1-next_val) * h);
      val2 = next_val;
    }
    
    
    stroke(c);
    // fill(c);
    // noStroke();

    // beginShape();

    for (int i = 1; i < values.size(); i++) {
      float next_val = values.get(i) / mult;
      line( (i-1) * w, 2 + index * h + (1-val) * h, i * w, 2 + index * h + (1-next_val) * h );
      // vertex((i-1) * w, 1 + index * h + (1-val) * h);
      // vertex((i-1) * w, 1 + index * h + h);
      // vertex(i * w, 1 + index * h + h);
      // vertex(i * w, 1 + index * h + (1-next_val) * h);
      val = next_val;
    }
    
    // endShape(CLOSE);

    popMatrix();
    

  }

}