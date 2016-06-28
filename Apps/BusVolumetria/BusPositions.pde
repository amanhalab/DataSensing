class BusPosition {
  int id;
  int timestamp;
  float lat, lng, speed;
  BusPosition(int _id, int _timestamp, float _lat, float _lng, float _speed) {
    id = _id;
    timestamp = _timestamp;
    lat = _lat;
    lng = _lng;
    speed = _speed;
  }
}
