


class Landscape {

  int scl;            // siz_0e of each cell
  int w, h;           // width and height of thingie
  int rows, cols;     // number of rows and columns
  float posX, posY;   // X and Y position of each line()
  int marginX = 20;   // margin X
  int marginY = 10;   // margin Y

  float zoff = 0.0;   // perlin noise argument
  float passerbyData;      // data of perlin noise map
  float visitorsData;      // data of perlin noise map
  float connectedData;      // data of perlin noise map
  float xoff, yoff;   // values for noise functin

  float[][] z_0;        // using an array to store all the height values 
  float[][] z_1;        // using an array to store all the height values 
  float[][] z_2;        // using an array to store all the height values 

  Landscape(int scl_, int w_, int h_) {
    scl = scl_;
    w = w_;
    h = h_;
    cols = w/scl;
    rows = h/scl;
    z_0 = new float[cols][rows];
    z_1 = new float[cols][rows];
    z_2 = new float[cols][rows];

    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        z_0[x][y] = 0;
        z_1[x][y] = 0;
        z_2[x][y] = 0;
      }
    }
  }

  // Calculate height values (based off a neural netork)
  void calculate() {

    // get first and only CMX
    UniqueCMX cmx = engine.cmxList.get(0);

    // update simulation time
    cmx.update(simulation_time);

    // mapear os valores;
    passerbyData = MapValues(cmx.passerby, "PASSERBY");     // Função passando o dado de passerby
    visitorsData = MapValues(cmx.visitors, "VISITORS");     // "  "  "  "  "  "  "  "  " visitors
    connectedData= MapValues(cmx.connected, "CONNECTED");   // "  "  "  "  "  "  "  "  " connected
    xoff = 0;
    for (int x = 0; x < cols; x++) {
      z_0[x][0] = (2*noise(xoff, yoff)-1)/2 * passerbyData*1.5;
      xoff -= 0.11;
      z_1[x][0] =  (2*noise(xoff, yoff)-1)/1.8 * visitorsData;
      xoff -= 0.11;
      z_2[x][0] =  (2*noise(xoff, yoff)-1)/2 * connectedData/1.5;
      xoff -= 0.11;
    }
    yoff += 0.2 -random(1)/20;

    /*
    // show interpolated numbers
     int inter_x = 50;
     int inter_y = 25;
     
     // DATA TEXT
     fill(255);
     
     text("USUARIOS CONECTADOS --- " + cmx.connected, inter_x, height-inter_y * 2);
     text("USUARIOS VISITANTES --- " + cmx.visitors, inter_x, height-inter_y * 3);
     text("USUARIOS AO LONGE ----- " + cmx.passerby, inter_x, height-inter_y * 4);
     */
  }



  void render() {

    background(0);

    // Change height of the camera with mouseY
    camera(0.0, 308, 220.0, // eyeX, eyeY, eyeZ
      0.0, 0.0, 0.0, // centerX, centerY, centerZ
      0.0, 1.0, 0.0); // upX, upY, upZ
   // println(mouseX);
  //  println(mouseY);

    translate(-width+342,77, 80);

    for (int x = cols-1; x > 0; x--) {
      for (int y = rows-1; y > 0; y--) {  
        z_0[x][y] = z_0[x][y-1];
        z_1[x][y] = z_1[x][y-1];
        z_2[x][y] = z_2[x][y-1];
      }
    }
    int gap = 80;
    posY = 0;
    for (int x = 1; x < cols-1; x++) {
      float jpos = 0;
      posY++; 
      posX = 0;
      for (int y = 1; y < rows-1; y++) {    
        posX++;
        jpos+= 0.015;
        strokeWeight(1);
        //point(posX*scl, posY*scl);

        //passerby
        stroke( 255*noise(jpos/1.0), 255-255*noise(jpos/1.0), 255);
        line(posX*scl, (posY)*scl-gap*2 + x*15, z_0[x][y], posX*scl+scl, (posY)*scl-gap*2 + x*15, z_0[x][y+1]);
        //visitors
        stroke( 255-255*noise(jpos/1.0), 255*noise(jpos/1.0), 255);
        line(posX*scl, (posY)*scl, z_1[x][y], posX*scl+scl, (posY)*scl, z_1[x][y+1]);
        //conected
        stroke( 255, 255*noise(1-jpos/1.0), 255*noise(1-jpos/1.0));
        line(posX*scl, (posY)*scl+gap, z_2[x][y], posX*scl+scl, (posY)*scl+gap, z_2[x][y+1]);
      }
    }

    frame = (frame + 1) % (60 * 60 * 24);

    // Shader Blur
    filter(blur);
    filter(BLUR, 0.6);
  }
}