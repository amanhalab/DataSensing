class Poi {
  
  int id;
  String name;
  ArrayList<Integer> count;
  int score;
  String datetime;

  Poi(String poi_name, int poi_id, String poi_datetime) {
  	count = new ArrayList<Integer>();
    id = poi_id;
    name = poi_name;
    score = 0;
    datetime = poi_datetime;
  }

}
