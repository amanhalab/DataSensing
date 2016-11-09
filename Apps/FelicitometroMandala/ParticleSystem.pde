
class ParticleSystem {

  ArrayList<Particle> particles;
  int total;
  int cont; 

  int max = 2500;
  int startingPoints;

  float orbit;
  float limitTime;

  int rand;
  float Velocityf;
  float minVel;
  float maxVel;

  String currentDate = "";

  boolean isInitialized = false; 
  boolean allCreated = false;
  boolean destroyObject = false;
  boolean isReleased = false;

  Particle currentPart;

  long startTime; 
  long startTimer;
  long currentTime;

  ParticleSystem() {
    particles = new ArrayList<Particle>();

    // total = int(random(100 ))+1;
    orbit = particles.size();

    startTime = millis();
  }

  void init (String datetime, int value, int id) {

    println("object index: " + id);

    //total numer of particles in the day
    total = value;   
    currentDate = datetime;

    //start timer
    startTimer = millis();

    // seting starting number. these are the number of points create per draw()
    // it is calculated from the current total number in comparison with the max
    //  if(count != 0){
    startingPoints= int(map(total, 0, max, 1, 8));
    //  } else {
    //    startingPoints = 0;
    //  }
    // orbit is equal id
    orbit = id;
    // are all sub-objects created ?
    allCreated = false;
    // contador 
    cont = 0;
    //time gap between subobjects creation
    limitTime = 500 + random(total/2);

    //random value that will define velocity in each particle group
    // rand = random(-startingPoints, startingPoints)/2;
    rand =  int(random(1, 10));

    //set velocity
    if (total < 50) {
      Velocityf = total/150.0;
    } else {
      Velocityf = total/75.0;
    }

    isInitialized = true;
  }

  void addParticle() {

    for (int i = 0; i < startingPoints; i++) {

      if (currentTime - startTime  > limitTime) {
        cont++;
        if (cont == 1) {
          println("total: "+ total + " sPoints: "+ startingPoints);
          println("random velocity value: " + Velocityf);
          println("particle created");
        }
        particles.add(new Particle(total/startingPoints, orbit, cont, startingPoints, Velocityf));
        currentPart = particles.get(particles.size()-1);
        isReleased = false;

        //restart timer 
        startTime = millis();
      }
    }
    if (cont == startingPoints) {
      allCreated = true;
      println("done");
      println();
    }
  }

  void run() {

    int previousSize; 

    previousSize = particles.size();

    currentTime = millis();
    for (Particle part : particles) {
      // if particles already passed X times the screen width, erase from memory
      if (part.radius[0].x > WIDTH*5) {
        destroyObject = true;
      }
      if (previousSize != particles.size()) {
        destroyObject = false;
      }
      part.run();
    }
    // println("currentTime: "+ currentTime);
    // println("startTime: "+ startTime);
    if (destroyObject) {
      particles.remove(0);
      println("last pparticle object removed");
      destroyObject= false;
    }
    // check if last point of the object was released
    if (currentPart != null && currentPart.isReleased == true && isReleased == false) {
      //start timer plus minDuration
      startTimer = millis() + 1000;
      isReleased = true;
    }
  }

  void timer() {
    startTimer = millis();
  }
}