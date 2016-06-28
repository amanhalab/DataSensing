class Bus {

  TreeMap<Integer, BusPosition> positions;

  String bus_id;
  int bus_line_id;
  int m, interval, step, nextstep;
  int quarantine;
  float frag;
  float speed;
  float targetSpeed;

  Bus(String _bus_id, int _bus_line_id) {
    positions = new TreeMap<Integer, BusPosition>();
    bus_id = _bus_id;
    bus_line_id = _bus_line_id;

    m = millis() + 1 * 1000;
    interval = 2 * 1000;
    step = 0;
    nextstep = 0;
    frag = 0;
    quarantine = 0;
    targetSpeed = speed = 0;
  }

  boolean checkTime(int time) {

    int first = positions.firstKey();
    int last = positions.lastKey();

    if(time < first || time > last)
      return false;

    step = positions.floorKey(time);

    if(step == last)
      return false;

    nextstep = positions.higherKey(step);

    frag = 1.0 * (time-step) / (nextstep-step);

    targetSpeed = getSpeed();

    return true;

  }

  float getSpeed() {

    BusPosition p1 = positions.get(step);
    BusPosition p2 = positions.get(nextstep);

    float time = (nextstep - step);

    PVector v1 = new PVector(p1.lng, p1.lat);
    PVector v2 = new PVector(p2.lng, p2.lat);

    float dist = v1.dist(v2) * 400 * 1000.0;
    return min(100, dist * 1.0 / time);
  }

  PVector getInterpolatedPosition() {

    //println(bus_id + " step " + step);
    //println(bus_id + " next " + nextstep);

    BusPosition p1 = positions.get(step);
    BusPosition p2 = positions.get(nextstep);

    speed = lerp(speed, targetSpeed, 0.05);

    float x = lerp(p1.lng, p2.lng, frag);
    float y = lerp(p1.lat, p2.lat, frag);

    return new PVector(x,y);

  }

}
