// Редактор для corconus
// Дополнение

crcecore crcecore = new crcecore();
class crcecore {
  // Локализация
  String lang = "ru";
  
  String scene = "menu";
  
  void setup() {
    langSetup();
    uifxml.importPack("corconus.xml");
  }
  
  void draw() {
    fill(255);
    uifxml.scenes.get(scene).render();
  }
  
  void mousePressed() {
    
  }
  
  void mouseReleased() {
    
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
