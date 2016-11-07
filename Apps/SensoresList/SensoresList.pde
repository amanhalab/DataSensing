import mqtt.*;
import java.util.*;

MQTTClient client;
HashMap<String,Stream> streams = new HashMap<String,Stream>();

PFont font;
ColorScale scale = new ColorScale();

float angle_loading = 0;

void setup() {
  
  background(0);
  
  client = new MQTTClient(this);
  client.connect("mqtt://192.168.137.200:1883", "sensores_display");
  //client.connect("mqtt://localhost", "sensores_display");
  client.subscribe("#");

  font = loadFont("FFFCorporate-8.vlw");
  textFont(font, 8);

  scale.addColor(color(168, 33, 108), 10);
  scale.addColor(color(237, 27, 77), 10);
  scale.addColor(color(243, 108, 68), 10);
  scale.addColor(color(248, 220, 105), 10);
  scale.addColor(color(46, 150, 152), 10);

  surface.setTitle("processing_vis");

}

void draw() {

  colorMode(RGB);
  background(0);

  angle_loading += 5;

  float val = sin(radians(angle_loading)) * 128;

  int total = streams.size();
  int k = 0;

  colorMode(HSB);

  if(total > 0){

    Iterator<Map.Entry<String, Stream>> iter = streams.entrySet().iterator();
    while (iter.hasNext()) {
      Map.Entry<String, Stream> entry = iter.next();
      Stream s = streams.get( entry.getKey() );
      s.update();
      if (s.life <= 0) {
        iter.remove();
      } else {
        color c = color( scale.getColorAt(k * 1.0 / total) );
        s.display(k, total, c);
        k++;
      }
    }

  } else {

    noStroke();
    fill(128 + val);
    //ellipse(width * 0.5, height * 0.5, 10, 10);
    textAlign(CENTER, CENTER);
    text("aguardando dados dos sensores", WIDTH * 0.5, HEIGHT * 0.5);

  }

}


void messageReceived(String topic, byte[] payload) {

  String[] topics = topic.split("-");
  JSONObject json = parseJSONObject(new String(payload));

  if (topics[topics.length-1].endsWith("data")) {

    float rotary = json.getJSONObject( topics[0] + "_rotary").getFloat("angle");
    float light = json.getJSONObject(topics[0] + "_light").getFloat("level");
    float ranger = json.getJSONObject(topics[0] + "_ranger").getFloat("distance");
    float temperature = json.getJSONObject(topics[0] + "thermometer").getFloat("temperature");
    float humidity = json.getJSONObject(topics[0] + "thermometer").getFloat("humidity");
    float button = json.getJSONObject(topics[0] + "_button").getFloat("pressed");

    addStreamValue(topics[0], "rotary", rotary, 1023.0);
    addStreamValue(topics[0], "light", light, 1023.0);
    addStreamValue(topics[0], "ranger", ranger, 300.0);
    addStreamValue(topics[0], "temperature", temperature, 50.0);
    addStreamValue(topics[0], "humidity", humidity, 100.0);
    addStreamValue(topics[0], "button", button, 1.0);

  }

  //println(topics[0] + " -- " + topics[topics.length-1] + " -- " + json);
  println(topics[0]);
}

void addStreamValue(String topic, String topicData, float value, float mult) {

  String addr = topic + "/" + topicData;

  if (!streams.containsKey(addr)) {
    streams.put(addr , new Stream(addr));
  }

  Stream stream = streams.get(addr);
  value = Float.isNaN(value) ? 0 : value;
  value = constrain(value, 0, mult);
  stream.addValue(value, mult);

}