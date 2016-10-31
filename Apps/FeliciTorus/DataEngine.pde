import java.util.*;
import java.text.*;
import java.net.*;

class DataEngine {

  String server = "http://187.111.110.14:8085";
  String datastore = "b60f2405-4e0d-4459-ac52-aff1eabd9734";
  String path = server +"/api/action/datastore_search_sql?sql=";

  int state;
  int days;
  int startingDay = 60;
  JSONObject json;

  ArrayList<FeliciDate> felicidates;

  Calendar calMonthAgo, calToday;
  SimpleDateFormat dt, dtfile;

  DataEngine(int _days) {
    
    days = _days + startingDay;

    felicidates = new ArrayList<FeliciDate>();
    
    state = 0;

    dt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    dtfile = new SimpleDateFormat("yyyy-MM-dd--HH-mm");

    calMonthAgo = new GregorianCalendar();
    calMonthAgo.add(Calendar.DATE, -days);
    calMonthAgo.set(Calendar.HOUR_OF_DAY, 0);
    calMonthAgo.set(Calendar.MINUTE, 0);
    calMonthAgo.set(Calendar.SECOND, 0);
    calMonthAgo.set(Calendar.MILLISECOND, 0);

    calToday = new GregorianCalendar();
    calToday.add(Calendar.DATE, -startingDay);
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

    String file =  "/cache/" + dtfile.format(calMonthAgo.getTime()) + "_to_" + dtfile.format(calToday.getTime()) + ".json";

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

      file =  "/cache/" + dtfile.format(calMonthAgo.getTime()) + "_to_" + dtfile.format(calToday.getTime()) + ".json";

      String sql = "SELECT to_char(processed_date, 'MM/DD/YYYY') as datetime, sum(count) as count from \"" + datastore
        + "\" WHERE poi_id = 1 and (processed_date >= '" + dt.format(calMonthAgo.getTime())
        + "'  AND processed_date <= '" + dt.format(calToday.getTime()) + "') GROUP BY datetime ORDER BY datetime ASC";

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
      String datetime = record.getString("datetime");

      felicidates.add(new FeliciDate(datetime, count, i));
      
      println("-- " + nf(i,2) + " " + datetime + " => count: " + count);

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