import java.util.*;

class ColorScalePhase {

  color c;
  int score;

  ColorScalePhase(color _c, int _score){
    c = _c;
    score = _score;
  }

}

class ColorScale {

  ArrayList<ColorScalePhase> colors;
  TreeMap<Integer, Integer> colormap;

  int totalScore;

  ColorScale(){
    colors = new ArrayList<ColorScalePhase>();
    colormap = new TreeMap<Integer, Integer>();
  }

  void addColor(color c, int score){
    colors.add(new ColorScalePhase(c, score));
    recalculate();
  }

  void recalculate() {

    int k = 0;
    totalScore = 0;
    colormap.clear();

    for(ColorScalePhase phase : colors) {
        if(k == 0){
          colormap.put(totalScore, phase.c);
          totalScore += phase.score;
        } else if(k == colors.size() - 1){
          totalScore += phase.score;
          colormap.put(totalScore, phase.c);
        } else {
          totalScore += phase.score * 0.5;
          colormap.put(totalScore, phase.c);
          totalScore += phase.score * 0.5;
        }
        k++;
    }

  }

  color getColorAt(float position){

    int pos = int(position * totalScore);

    Map.Entry<Integer, Integer> before = colormap.floorEntry(pos);
    Map.Entry<Integer, Integer> after = colormap.higherEntry(pos);

    float posf = map(pos, before.getKey(), after.getKey(), 0, 1);

    //println("pos: " + pos + " --- before: " + before.getKey() + " --- after:" + after.getKey() + " --- lerp: " + posf );

    return lerpColor(color(before.getValue()), color(after.getValue()), posf);

  }

  void drawRect(int x, int y, int w, int h){

    int k = 0;
    float score = 0;
    float score_factor = w * 1.0 / totalScore;

    noStroke();

    for(ColorScalePhase phase : colors) {
      fill(phase.c);
      rect(x + score, y, phase.score * score_factor, h);
      score += phase.score * score_factor;
      k++;
    }

  }

}
