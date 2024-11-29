// Редактор для corconus
// Дополнение

crcecore crcecore = new crcecore();
class crcecore {
  // Локализация
  String lang = "ru";
  
  String scene = "main";
  // main
  // project
  // project_map
  
  void setup() {
    langSetup();
    uifxml.globalLang = lang;
    uifxml.importPack("corconus.xml");
  }
  
  Boolean openedblock = false;
  void draw() {
    fill(255);
    uifxml.gvars.put("scene", scene);
    uifxml.scenes.get("buttonbar").render();
    uifxml.scenes.get("openedblock").render();
    
    // Обработка нажатий
    ArrayList<JSONObject> events = uifxml.getEvents("buttonbar", "button.press");
    for(int i = 0; i < events.size(); i++) {
      JSONObject data = events.get(i);
      String token = data.getString("token");
      Boolean tap = false;
      if(token.equals("open_project")) { tap = true; }
      if(tap) {
        if(!openedblock) { openedblock = true;
          uifxml.gvars.put("openedblock", token);
        } else {           openedblock = false;
          uifxml.gvars.put("openedblock", "");
        }
      }
    }
    events = uifxml.getEvents("openedblock", "button.press");
    for(int i = 0; i < events.size(); i++) {
      JSONObject data = events.get(i);
      String token = data.getString("token");
      if(token.equals("open_project_plus")) {
        uifxml.scenes.get("openedblock").editVarForm("list", uifxml.scenes.get("openedblock").getVar("list") + "+1");
      } else  if(token.equals("open_project_minus")) {
        uifxml.scenes.get("openedblock").editVarForm("list", uifxml.scenes.get("openedblock").getVar("list") + "-1");
      }
    }
    
    /*ArrayList<JSONObject> events = uifxml.getEvents("button.press");
    for(int i = 0; i < events.size(); i++) {
      JSONObject temp = events.get(i);
      String token = temp.getString("token");
      // MAIN: _BUTTON.PRESS.open_project
      Boolean tap = false;
      if(token.equals("open_project")) {
        tap = true;
      }
      
      if(tap) {
        if(!openedblock) { openedblock = true;
          uifxml.gvars.put("openedblock", token);
        } else {           openedblock = false;
          uifxml.gvars.put("openedblock", "");
        }
      }
    }*/
  }
  
  void mousePressed() {
    //uifxml.importPack("corconus.xml");
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
