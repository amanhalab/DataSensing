JSONObject config;

int WIDTH, HEIGHT, SCALEDWIDTH, SCALEDHEIGHT;
boolean SCALED;
float SCALEFACTOR = 1.0;
int OFFSET = 0;

void settings() {
    try {
      config = loadJSONObject("../../processing-settings.json");
      WIDTH = config.getInt("width");
      HEIGHT = config.getInt("height");
      SCALEDWIDTH = config.getInt("scaledWidth");
      SCALEDHEIGHT = config.getInt("scaledHeight");
      SCALED = config.getBoolean("scaled");
      if(SCALED){
        size(SCALEDWIDTH, SCALEDHEIGHT, P2D);
        SCALEFACTOR = 1.0 * SCALEDWIDTH / WIDTH;
        OFFSET = (int)((SCALEDHEIGHT - HEIGHT * SCALEFACTOR) * 0.5);
      } else {
        size(WIDTH, HEIGHT, P2D);
      }
    } catch(Exception e) {
      SCALED = false;
      WIDTH = 1040;
      HEIGHT = 160;
      size(WIDTH, HEIGHT, P2D);
    }
    fullScreen(1);
}