import java.util.*;
import java.text.*;
import java.net.*;

class DataEngine {

  String server = "http://187.111.110.14:8085";
  String datastore = "b60f2405-4e0d-4459-ac52-aff1eabd9734";
  String path = server +"/api/action/datastore_search_sql?sql=";

  int state;

  JSONObject json;

  HashMap<Integer, Poi> pois;
  TreeMap<Integer, Integer> scores;

  Calendar calDaysAgo, calToday;
  SimpleDateFormat dt, dtfile;

  DataEngine(int days) {

    pois = new HashMap<Integer, Poi>();
    scores = new TreeMap<Integer, Integer>();
    
    state = 0;

    dt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    dtfile = new SimpleDateFormat("yyyy-MM-dd--HH-mm");

    calDaysAgo = new GregorianCalendar();
    calDaysAgo.add(Calendar.DATE, -days);
    calDaysAgo.set(Calendar.HOUR_OF_DAY, 0);
    calDaysAgo.set(Calendar.MINUTE, 0);
    calDaysAgo.set(Calendar.SECOND, 0);
    calDaysAgo.set(Calendar.MILLISECOND, 0);

    calToday = new GregorianCalendar();
    //calendarEnd.add(Calendar.DATE, -1);
    calToday.set(Calendar.HOUR_OF_DAY, 0);
    calToday.set(Calendar.MINUTE, 0);
    calToday.set(Calendar.SECOND, 0);
    calToday.set(Calendar.MILLISECOND, 0);

  }

  void validateData(){
    
  }

  void loadJSON() {

    clearCache();
    validateData();

    String file =  "/cache/" + dtfile.format(calDaysAgo.getTime()) + "_to_" + dtfile.format(calToday.getTime()) + ".json";

    // check if cached file exists
    if(fileExists(sketchPath() + file)){

      println();
      println(file + " exists, just process");
      println();

      // load json from cache
      json = loadJSONObject( sketchPath() + file );

    } else {

      println();
      println(file + " not founded, load data");
      println();

      file =  "/cache/" + dtfile.format(calDaysAgo.getTime()) + "_to_" + dtfile.format(calToday.getTime()) + ".json";

      String sql = "SELECT to_char(processed_date, 'MM/DD/YYYY') as datetime, poi_id, poi_name, sum(count) as count from \"" + datastore
        + "\" WHERE (processed_date >= '" + dt.format(calDaysAgo.getTime())
        + "'  AND processed_date <= '" + dt.format(calToday.getTime()) + "') GROUP BY datetime, poi_id, poi_name ORDER BY datetime ASC, count DESC";
      
      println(sql);
      println(path + URLEncoder.encode(sql));
      println();

      println("prepare to load");
      println();

      // load json from url
      json = loadJSONObject( path + URLEncoder.encode(sql));

      println("prepare to save");
      println();

      // save file to cache
      saveJSONObject(json, sketchPath() + file);

    }

    // filter records
    JSONArray records = json.getJSONObject("result").getJSONArray("records");

    // loop records
    for (int i = 0; i < records.size(); i++) {

      // get object
      JSONObject record = records.getJSONObject(i);

      // get values
      int count = record.getInt("count");
      int poi_id = record.getInt("poi_id");
      String poi_name = record.getString("poi_name");
      String datetime = record.getString("datetime");

      if (!pois.containsKey(poi_id)) {
        pois.put(poi_id, new Poi(poi_name, poi_id, datetime));
      }

      Poi p = pois.get(poi_id);

      p.score += count;
      p.count.add(count);
      
    }

    for (Map.Entry entry : pois.entrySet()) {
      Poi p = (Poi)(entry.getValue());
      scores.put(p.score, p.id);
    }

    for (Map.Entry entry : scores.descendingMap().entrySet()) {
      Integer id = (Integer)(entry.getValue());
      Poi p = pois.get(id);
      println(nf(p.score,5) + "      " + p.name);
    }

    println();
    println();
    println("JSON LOADED!");
    println("-");

    state = 1;

  }

  // clear cache: files older than 15 days
  void clearCache() {
    File folder = new File(sketchPath("") + "/cache/");
    if(!folder.exists()){
      folder.mkdir();
    }
    File[] listOfFiles = folder.listFiles();
    for (int i = 0; i < listOfFiles.length; i++) {
      if (listOfFiles[i].isFile()) {
        //
        long diff = new Date().getTime() - listOfFiles[i].lastModified();
        if (diff > 15 * 24 * 60 * 60 * 1000) {
            println("Deleted cached file " + listOfFiles[i].getName());
            listOfFiles[i].delete();
        }
      }
    }
  }

  // check if file exists
  boolean fileExists(String filename) {
    File file = new File(filename);
    if(!file.exists()){
      return false;
    }
    return true;
  }

}
