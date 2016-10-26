class Channel {

  int[] density = new int[24];

  int numMax = 100;
  int numMin = 10;

  float xoff = 0;
  float yoff = 0;

  int index;

  Channel(int _index){

    index = _index;

    // TODO: FROM RANDOM TO REAL VALUES

    for(int i = 0; i < 24; i++){
      if(random(10) < 7){
        density[i] = (int)random(numMin, numMax/2);
      } else {
        density[i] = (int)random(numMin, numMax);
      }
    }

  }

  void display(PGraphics pg, color c, float x, float y, float radius, int timer) {

    xoff += 0.002;
    yoff += 0.004;

    float angle = 195 + timer * 15.0 / (60 * 60);

    int current_hour = (timer / (60 * 60)) % 24;

    pg.pushMatrix();

      pg.translate(x * SCALEFACTOR, y * SCALEFACTOR);

      displayHour(pg, c, (current_hour + 23) % 24, angle, radius);
      displayHour(pg, c, current_hour, angle, radius);

      for(int i = 1; i < 5; i++){
        int next_hour = (current_hour + i) % 24;
        displayHour(pg, c, next_hour, angle, radius);
      }

    pg.popMatrix();


    //println(timer+" - "+current_hour);

  }

  void displayHour(PGraphics pg, color c, int hour, float angle, float radius){

    int num = density[hour];
    float angle_step = 15.0 / num;

    pg.noStroke();

    float angle_in = 195;
    float angle_size = 198;
    float angle_out = 230;

    for(int i = 0; i < num; i++){

      float a = angle_step * i + angle - hour * 15;
      a += noise(i) * angle_step + noise(xoff + i * angle_step * 0.5, index) * angle_step * 5;
      a = a % 360;

      if (a > angle_in && a < angle_out){
        pg.fill(c, 30);
      } else {
        // pg.fill(30, 50, 30, 10);
        pg.fill(c, 10);
      }

      float r = radius * SCALEFACTOR;
      // r = radius + noise(i/10.0 + yoff, index) * 5 ;
      // r = radius + noise(i/10.0 + yoff, index) * 50;

      float x = sin(radians(a)) * r;
      float y = cos(radians(a)) * r;

      float size = map(num, numMin, numMax, 2, 10);

      if (a > angle_in && a < angle_size){
        size *= map(a, angle_in, angle_size, 2, 1);
      }

      pg.ellipse(x,  OFFSET + y, size * SCALEFACTOR, size * SCALEFACTOR);

    }

  }



}
