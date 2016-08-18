import java.util.*;
import java.text.*;
import java.net.*;

class DataEngineBus {

  String server = "http://187.111.110.14:8085";
  String datastore = "186d802e-e0cd-4c7f-b182-37fe8ced7264";
  String path = server +"/api/action/datastore_search_sql?sql=";

  int m, state, files, frag_hours, loaded_files, num_buses, num_positions, sql_count;

  JSONObject json;

  HashMap<String, Bus> buses;

  Calendar calendar, nextcalendar, fullcalendar;
  SimpleDateFormat dt, dtfile;

  long today;

  DataEngineBus() {

    m = millis();
    buses = new HashMap<String, Bus>();
    state = 0;
    loaded_files = 0;
    files = 6;
    frag_hours = 24 / files;

    num_buses = 0;
    num_positions = 0;

    sql_count = 0;

    dt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    dtfile = new SimpleDateFormat("yyyy-MM-dd--HH-mm");

    calendar = new GregorianCalendar();
    //calendar.add(Calendar.DATE, -1);
    calendar.set(Calendar.HOUR_OF_DAY, 0);
    calendar.set(Calendar.MINUTE, 0);
    calendar.set(Calendar.SECOND, 0);
    calendar.set(Calendar.MILLISECOND, 0);

    nextcalendar = new GregorianCalendar();
    //nextcalendar.add(Calendar.DATE, -1);
    nextcalendar.set(Calendar.HOUR_OF_DAY, frag_hours);
    nextcalendar.set(Calendar.MINUTE, 0);
    nextcalendar.set(Calendar.SECOND, 0);
    nextcalendar.set(Calendar.MILLISECOND, 0);

    fullcalendar = new GregorianCalendar();
    fullcalendar.add(Calendar.DATE, 1);
    fullcalendar.set(Calendar.HOUR_OF_DAY, 0);
    fullcalendar.set(Calendar.MINUTE, 0);
    fullcalendar.set(Calendar.SECOND, 0);
    fullcalendar.set(Calendar.MILLISECOND, 0);

  }

  void validateData(){

    while(sql_count < 100){

      calendar.add(Calendar.DATE, -1);
      nextcalendar.add(Calendar.DATE, -1);
      fullcalendar.add(Calendar.DATE, -1);

      String sql = "SELECT COUNT(DISTINCT bus_id) from \"" + datastore
      + "\" WHERE timestamp >= '" + dt.format(calendar.getTime())
      + "'  AND timestamp < '" + dt.format(fullcalendar.getTime()) + "'";

      println();
      println("Check num of buses at date " + dt.format(calendar.getTime()));
      println(sql);
      println();

      json = loadJSONObject( path + URLEncoder.encode(sql));
      sql_count = json.getJSONObject("result").getJSONArray("records").getJSONObject(0).getInt("count");
      today = getUnixTime(dt.format(calendar.getTime()));

      println();
      println(sql_count + " buses at date " + dt.format(calendar.getTime()));
      println();

    }

  }

  void loadJSON() {

    clearCache();
    validateData();

    int newbus = 0;
    int newpos = 0;

    String file =  "/cache/" + dtfile.format(calendar.getTime()) + ".json";

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

      file =  "/cache/" + dtfile.format(calendar.getTime()) + ".json";

      String sql = "SELECT _id, bus_line_id, bus_id, speed, timestamp, lat, lng from \"" + datastore
        + "\" WHERE timestamp >= '" + dt.format(calendar.getTime())
        + "'  AND timestamp < '" + dt.format(nextcalendar.getTime()) + "' AND speed > 0";

      println(sql);
      println(path + URLEncoder.encode(sql));

      // load json from url
      json = loadJSONObject( path + URLEncoder.encode(sql));

      // save file to cache
      saveJSONObject(json, sketchPath() + file);

    }

    // filter records
    JSONArray records = json.getJSONObject("result").getJSONArray("records");

    // loop records
    for (int i = 0; i < records.size(); i++) {

      // get object
      JSONObject bus = records.getJSONObject(i);

      // get values
      int id = bus.getInt("_id");
      String bus_id = bus.getString("bus_id");
      int bus_line_id = Integer.parseInt(bus.getString("bus_line_id"));
      float lat = bus.getFloat("lat");
      float lng = bus.getFloat("lng");
      float speed = bus.getFloat("speed");
      String timestamp = bus.getString("timestamp").replace('T', ' ');
      long timestampunix = getUnixTime(timestamp);
      // trasform long to int, unixtime just for today
      int time = (int)(timestampunix - today);

      // check if bus exists
      if (!buses.containsKey(bus_id)) {

        // add bus
        buses.put(bus_id, new Bus(bus_id, bus_line_id) );

        // update counters
        newbus++;
        num_buses++;

        // log bus
        print(bus_id + "(" + bus_line_id + "); ");

      }

      Bus b = buses.get(bus_id);

      // check if record exists
      if (!b.positions.containsKey(time) && speed > 0) {

        // add record
        b.positions.put(time, new BusPosition(id, time, lat, lng, speed) );

        // update counters
        newpos++;
        num_positions++;

        // log record
        println("-- " + bus_id + " : " + bus_line_id);
        println("-- created position from record " + id + " time: " + time + " lat: " + lat + " lng: " + lng);

      }
    }

    println();
    println();
    println("JSON LOADED! " + newbus + " new buses. " + newpos + " new position records.");
    println("-");

    loaded_files++;

    if(loaded_files < files){
      // if not the last file, update calendars and load next
      calendar.add(Calendar.HOUR_OF_DAY, frag_hours);
      nextcalendar.add(Calendar.HOUR_OF_DAY, frag_hours);
      loadJSON();
    } else {
      // if last file, log and change state
      println();
      println();
      println("FINISH ALL LOADING! " + num_buses + " buses and " + num_positions + " position records.");
      state = 1;
    }
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

  // convert timestamp to unixtime
  long getUnixTime(String timestamp){
    long timestampunix = 0;
    try {
      Date date = dt.parse(timestamp);
      timestampunix = (long)date.getTime()/1000;
    }
    catch (ParseException e) {
      e.printStackTrace();
    }
    return timestampunix;
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
