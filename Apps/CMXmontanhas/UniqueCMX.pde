class UniqueCMX {
  TreeMap<Integer, UniqueRecord> records = new TreeMap<Integer, UniqueRecord>();
  String site_id;
  int step, nextstep;
  float frag;
  float connected, visitors, passerby;

  UniqueCMX(String id) {
    site_id = id;
    connected = 0;
    visitors = 0;
    passerby = 0;
  }
  boolean update(int time) {

    int first = records.firstKey();
    int last = records.lastKey();

    if(time < first || time > last)
      return false;

    step = records.floorKey(time);

    if(step == last)
      return false;

    nextstep = records.higherKey(step);

    frag = 1.0 * (time-step) / (nextstep-step);

    UniqueRecord r1 = records.get(step);
    UniqueRecord r2 = records.get(nextstep);

    connected = lerp(r1.connected, r2.connected, frag);
    visitors = lerp(r1.visitors, r2.visitors, frag);
    passerby = lerp(r1.passerby, r2.passerby, frag);

    return true;

  }
}