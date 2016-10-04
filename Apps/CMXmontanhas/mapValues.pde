float MapValues(float dado, String type) {

  float maxIn = 0;
  float value;
  float minOut = 0;
  float maxOut = 350;

  if (type == "PASSERBY") {
    maxIn = 8000;
    
    maxOut = 600;
    minOut = -10;
  } else 
  if (type == "VISITORS") {
    maxIn = 550;
    
    maxOut = 300;
    minOut = -7;
  } else 
  if (type == "CONNECTED") {
    maxIn = 65;
    
    maxOut = 150;
    minOut = 0;
  }
  
  value = min(dado, maxOut);
  value = max(dado, minOut);
  value = map(dado, 0, maxIn, minOut, maxOut);

  return value;
}