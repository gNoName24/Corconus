// Редактор для corconus
// Дополнение

crcecore crcecore = new crcecore();
class crcecore {
  // Локализация
  String lang = "ru";
  
  void setup() {
    langSetup();
  }
  
  void draw() {
    fill(255);
    //sltext("{test1}--- {test222}", 0, 0, 40);
  }
  
  void mousePressed() {
    
  }
  
  void mouseReleased() {
    
  }
  
  void csbutton(float x, float y, float sx, float sy) {
    if(tap(x, y, sx, sy)) {stroke(191);}
    sblockRound(x, y, sx, sy, 6);
    stroke(0);
  }
  void csbutton2(float x, float y, float sx, float sy) {
    fill(32);
    if(tap(x, y, sx, sy)) {stroke(191);}
    sblockRound(x, y, sx, sy, 6);
    stroke(0);
  }
  void csbutton2_image(float x, float y, float sx, float sy, PImage image) {
    fill(32);
    if(tap(x, y, sx, sy)) {stroke(191);}
    simage(image, x, y, sx, sy);
    stroke(0);
  }
  
  void sltext(String txt, float xPos, float yPos, float size) {
    stext(formater(txt, langMap.get(lang)), xPos, yPos, size);
  }
  
  
  HashMap<String, HashMap<String, String>> langMap = new HashMap<String, HashMap<String, String>>();
  void langSetup() {
    // RU
    HashMap<String, String> ru = new HashMap<String, String>();
    ru.put("test1", "abcde");
    ru.put("test222", "KOOSLLSL");
    
    langMap.put("ru", ru);
  }
}
