float MapValues(float dado, String type) {

  float maxIn = 0;
  float value;
  float minOut = 0;
  float maxOut = 350;

  if (type == "PASSERBY") {
    maxIn = 10000;
    
    maxOut = 500;
    minOut = 0;
  } else 
  if (type == "VISITORS") {
    maxIn = 800;

    maxOut = 500;
    minOut = 0;
  } else 
  if (type == "CONNECTED") {
    maxIn = 85;
    
    maxOut = 500;
    minOut = 0;
  }
  
  value = min(dado, maxOut);
  value = max(dado, minOut);
  value = map(dado, 0, maxIn, minOut, maxOut);

  return value;
}