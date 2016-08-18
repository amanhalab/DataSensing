JSONObject config;

int WIDTH, HEIGHT, SCALEDWIDTH, SCALEDHEIGHT;
boolean SCALED, FULLSCREEN;
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
      FULLSCREEN = config.getBoolean("fullScreen");
      if(SCALED){
        size(SCALEDWIDTH, SCALEDHEIGHT, FX2D);
        SCALEFACTOR = 1.0 * SCALEDWIDTH / WIDTH;
        OFFSET = (int)((SCALEDHEIGHT - HEIGHT * SCALEFACTOR) * 0.5);
      } else {
        size(WIDTH, HEIGHT, FX2D);
      }
    } catch(Exception e) {
      SCALED = false;
      FULLSCREEN = false;
      WIDTH = 1040;
      HEIGHT = 160;
      size(WIDTH, HEIGHT, FX2D);
    }
    if(FULLSCREEN) fullScreen(1);
}
