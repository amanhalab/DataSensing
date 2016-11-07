import mqtt.*;
import java.util.*;

MQTTClient client;
HashMap<String, Grove> groves = new HashMap<String, Grove>();

PFont font;
ColorScale scale = new ColorScale();


void setup() {

  smooth();
  background(0);

  // try connect mqqt

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

  for (int i = 1; i <= 10; i++) {
    groves.put("kit" + nf(i, 2), new Grove("kit" + nf(i, 2), new PVector(75 + (i-1) * (WIDTH-50) / 10, HEIGHT * 0.5)));
  }

  surface.setTitle("processing_vis");

}

void draw() {

  colorMode(RGB);
  background(0);
  noStroke();

  int total = groves.size();
  int k = 0;

  Iterator<Map.Entry<String, Grove>> iter = groves.entrySet().iterator();
  while (iter.hasNext()) {
    Map.Entry<String, Grove> entry = iter.next();
    Grove g = groves.get( entry.getKey() );
    g.update();
    if (g.life <= 0) {
      //iter.remove();
      g.displayIdle();
    } else {
      color c = color( scale.getColorAt(k * 1.0 / total) );
      g.display(c);
      k++;
    }
  }

}


void messageReceived(String topic, byte[] payload) {

  String[] topics = topic.split("-");
  JSONObject json = parseJSONObject(new String(payload));

  if (topics[topics.length-1].endsWith("data")) {

    float rotary = json.getJSONObject( topics[0] + "_rotary").getFloat("angle");
    float light = json.getJSONObject(topics[0] + "_light").getFloat("level");
    float ranger = json.getJSONObject(topics[0] + "_ranger").getFloat("distance");
    float button = json.getJSONObject(topics[0] + "_button").getFloat("pressed");

    addStreamValue(topics[0], "rotary", rotary, 1023.0);
    addStreamValue(topics[0], "light", light, 1023.0);
    addStreamValue(topics[0], "ranger", min(ranger, 300), 300.0);
    addStreamValue(topics[0], "button", button, 1.0);

  }

  println(topics[0] + " -- " + topics[topics.length-1] + " -- " + json);

}

void addStreamValue(String topic, String topicData, float value, float mult) {

  Grove g = groves.get(topic);
  value = Float.isNaN(value) ? 0 : value;
  value = constrain(value, 0, mult);
  g.addValue(topicData, value, mult);

}