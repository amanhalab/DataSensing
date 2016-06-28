import java.util.*;
import java.text.*;
import java.net.*;

class DataEngineCMX {

  String server = "http://187.111.110.14:8085";
  String datastore = "62e2e9ff-0c99-47cf-bc37-6b3a0617095b";
  String path = server +"/api/action/datastore_search_sql?sql=";

  int m, state, files, frag_hours, loaded_files, num_cmx, num_records, sql_count, top_value, avr_value;

  JSONObject json;

  HashMap<String, UniqueCMX> cmxMap;
  ArrayList<UniqueCMX> cmxList;

  Calendar calendar, nextcalendar, fullcalendar;
  SimpleDateFormat dt, dtfile;

  long today;

  DataEngineCMX() {

    m = millis();
    cmxMap = new HashMap<String, UniqueCMX>();
    cmxList = new ArrayList<UniqueCMX>();
    state = 0;
    loaded_files = 0;
    files = 6;
    frag_hours = 24 / files;

    top_value = 0;
    avr_value = 0;

    num_cmx = 0;
    num_records = 0;

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

      String sql = "SELECT COUNT(DISTINCT _id) from \"" + datastore
      + "\" WHERE timestamp >= '" + dt.format(calendar.getTime())
      + "'  AND timestamp < '" + dt.format(fullcalendar.getTime()) + "'";

      println();
      println("Check num of CMX records at date " + dt.format(calendar.getTime()));
      println(sql);
      println();

      json = loadJSONObject( path + URLEncoder.encode(sql));
      sql_count = json.getJSONObject("result").getJSONArray("records").getJSONObject(0).getInt("count");
      today = getUnixTime(dt.format(calendar.getTime()));

      println();
      println(sql_count + " CMX records at date " + dt.format(calendar.getTime()));
      println();

    }

  }

  void loadJSON() {

    clearCache();
    validateData();

    int new_items = 0;
    int new_records = 0;

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

      String sql = "SELECT * from \"" + datastore
        + "\" WHERE timestamp >= '" + dt.format(calendar.getTime())
        + "'  AND timestamp < '" + dt.format(nextcalendar.getTime()) + "'";


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
      String site_id = record.getString("site_id");
      String timestamp = record.getString("timestamp").replace('T', ' ');
      int id = record.getInt("_id");
      int connected = record.isNull("connected") ? 0 : record.getInt("connected");
      int visitors = record.isNull("visitors") ? 0 : record.getInt("visitors");
      int passerby = record.isNull("passerby") ? 0 : record.getInt("passerby");

      top_value = max(top_value, max(connected, max(visitors, passerby)));
      //avr_value = (avr_value + (connected + visitors + passerby) / 3) / 2;

      if(connected > 0) {
        avr_value = (avr_value + connected) / 2;
      }

      if(visitors > 0) {
        avr_value = (avr_value + visitors) / 2;
      }

      if(passerby > 0) {
        avr_value = (avr_value + passerby) / 2;
      }

      // trasform long to int, unixtime just for today
      long timestampunix = getUnixTime(timestamp);
      int time = (int)(timestampunix - today);

      // check if bus exists
      if (!cmxMap.containsKey(site_id)) {

        // add bus
        UniqueCMX new_cmx = new UniqueCMX(site_id);
        cmxMap.put(site_id, new_cmx);
        cmxList.add(new_cmx);

        // update counters
        new_items++;
        num_cmx++;

        // log bus
        print("new site: " + site_id);

      }

      UniqueCMX cmx = cmxMap.get(site_id);

      // check if record exists
      if (!cmx.records.containsKey(time)) {

        // add record
        cmx.records.put(time, new UniqueRecord(id, time, connected, visitors, passerby) );

        // update counters
        new_records++;
        num_records++;

        // log record
        println("-- " + site_id );
        println("-- created record " + id + " time: " + time + " connected: " + connected + " visitors: " + visitors + " passerby: " + passerby);

      }
    }

    println();
    println();
    println("JSON LOADED! " + new_items + " new CMX. " + new_records + " new records.");
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
      println("FINISH ALL LOADING! " + num_cmx + " unique CMX and " + num_records + " total records. average value is " + avr_value + ". top value is " + top_value);
      state = 1;
    }
  }

  // clear cache: files older than 15 days
  void clearCache() {
    File folder = new File(sketchPath("") + "/cache/");
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
