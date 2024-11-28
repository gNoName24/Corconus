uifxml uifxml = new uifxml();
class uifxml {
  String pathMain;
  String pathPack;
  
  String globalLang = "ru";
  
  HashMap<String, ArrayList> events = new HashMap<String, ArrayList>();
  ArrayList getEvents(String typeEvent) {
    ArrayList temp = new ArrayList();
    try{
      if(events.containsKey(typeEvent)) {
        temp = events.get(typeEvent);
        events.remove(typeEvent);
      }
    } catch(Exception e) {
      printlne(e.getMessage());
    }
    return temp;
  }
  void addEvent(String typeEvent, JSONObject event) {
    if(!events.containsKey(typeEvent)) {
      events.put(typeEvent, new ArrayList());
    }
    events.get(typeEvent).add(event);
  }
  
  XML vars;
  HashMap<String, String> gvars;
  void bv() {
      gvars = new HashMap<String, String>();
      XML[] temp_vars = vars.getChildren();
      for(int i = 0; i < temp_vars.length; i++) {
        gvars.put(temp_vars[i].getName(), temp_vars[i].getContent());
      }
    }
  
  void setup() {
    pathMain = sketchPath()+"\\data\\uif\\";
    printlne("pathMain -", pathMain);
  }
  
  void importPack(String fileName) {
    pathPack = pathMain+fileName;
    
    printlne("Загрузка UIF (XML) пакета началась");
    printlne("pathPack -", pathPack);
    
    XML tempPack = loadXML(pathPack);
    scenes = new HashMap<String, ui>();
    
    //printlne("tempPack:", tempPack);
    
    XML[] sceneList = tempPack.getChildren("scene");
    
    // Форматирование стилей
    XML[] loadstyles = tempPack.getChildren("loadstyle");
    ArrayList<XML> map = new ArrayList<XML>();
    for(int i = 0; i < loadstyles.length; i++) {
      XML loadedxml = loadXML(pathMain+loadstyles[i].getString("file"));
      loadedxml = parseXML(loadedxml.toString().replaceAll("<"+loadedxml.getName()+"[^>]*>", "").replaceAll("</"+loadedxml.getName()+">", ""));
      map.add(loadedxml);
    }
    //printlne(map);
    
    // Обьединение стилей
    XML[] styles = tempPack.getChildren("style");
    XML stylesMerge = new XML("style");
    for(int i = 0; i < styles.length; i++) {
      for (XML child : styles[i].getChildren()) {
        stylesMerge.addChild(child);
      }
    }
    for(int s = 0; s < map.size(); s++) {
      for (XML child : map.get(s).getChildren()) {
        stylesMerge.addChild(child);
      }
    }
    //printlne(stylesMerge);
    //printlne(map);
    //stylesMerge = parseXML(formater(stylesMerge.toString(), map, "", ""));
    //printlne(stylesMerge);
    
    // Загрузка глобальных переменных
    vars = tempPack.getChild("globalvars");
    if(vars != null) { bv(); }
    
    for(int i = 0; i < sceneList.length; i++) {
      XML lef = sceneList[i];
      printlne("Загрузка сцены "+lef.getString("name"));
      ui ui = new ui();
      
      ui.data = lef.getChild("data");
      ui.lang = lef.getChild("lang");
      ui.vars = lef.getChild("vars");
      ui.style = stylesMerge;
      ui.buildLang();
      ui.buildVars();
      //printlne(ui.data, ui.lang, ui.vars);
      
      scenes.put(lef.getString("name"), ui);
    }
  }
  
  HashMap<String, ui> scenes = new HashMap<String, ui>();
  class ui {
    String sceneName;
    XML data;
    XML lang;
    XML vars;
    XML style;
    
    // Дополнения к переменным eval
    HashMap<String, String> DLC_lang;
    HashMap<String, String> DLC_vars;
    
    void buildLang() {
      DLC_lang = new HashMap<String, String>();
      if(lang.getChild(globalLang) != null) {
        XML[] temp_lang = lang.getChild(globalLang).getChildren();
        //println(temp_lang);
        for(int i = 0; i < temp_lang.length; i++) {
          DLC_lang.put(temp_lang[i].getName(), temp_lang[i].getContent());
        }
        // Пересборка с использованием replacement
        for(int i = 0; i < temp_lang.length; i++) {
          DLC_lang.remove(temp_lang[i].getName());
          DLC_lang.put("lang."+temp_lang[i].getName(), replacement(temp_lang[i].getContent()));
        }
      }
    }
    
    void buildVars() {
      DLC_vars = new HashMap<String, String>();
      XML[] temp_vars = vars.getChildren();
      for(int i = 0; i < temp_vars.length; i++) {
        DLC_vars.put(temp_vars[i].getName(), temp_vars[i].getContent());
      }
    }
    
    void render() {
      XML[] temp = data.getChildren();
      newRecurs(temp, 0, 0);
    }
    
    // В основной контент входит:
    // position
    
    // В побочный контент входит:
    // ___TEXT:
    // fill ; text ; textSize
    // ___BUTTON (+ID):
    // size ; fill (t1 -, t2, t3) ; round
    
    // Создание рекурсии
    void newRecurs(XML rec[], float recx, float recy) {
      for(int i = 0; i < rec.length; i++) {
        if(rec[i].getName().equals("object")) {
          
          // Использование STYLE
          // Получение всех <style></style>
          XML[] allstyle = rec[i].getChildren("style");
          //XML[] styles = style.getChildren();
          HashMap<String, String> temp = new HashMap<String, String>();
          for(int s = 0; s < allstyle.length; s++) {
            XML temp_style = style.getChild(allstyle[s].getString("id"));
            
            // Получение нужных аргументов
            JSONArray argslist = parseJSONArray(temp_style.getString("input").toString());
            
            // Получение значений аргументов из allstyle[s]
            HashMap<String, String> finalargs = new HashMap<String, String>();
            for(int s2 = 0; s2 < argslist.size(); s2++) {
              finalargs.put("input."+argslist.getString(s2), allstyle[s].getString(argslist.getString(s2)));
            }
            
            // Применение аргументов из finalargs к temp_style
            temp_style = parseXML(formater(temp_style.toString(), finalargs));
            
            temp.put(allstyle[s].toString(), temp_style.toString().replaceAll("<"+temp_style.getName()+"[^>]*>", "").replaceAll("</"+temp_style.getName()+">", ""));
          }
          rec[i] = parseXML( formater(rec[i].toString(), temp, "", "") );
          
          recurs(rec[i], recx, recy);
        }
      }
    }
    
    // Текст
    void recurs_text(XML temp, float x, float y) {
      // FILL
      float rgba[] = {255,255,255,255};
      if(temp.getChild("fill") != null) {
        rgba[0] = temp.getChild("fill").getString("r") != null ? form(temp.getChild("fill").getString("r")) : 255;
        rgba[1] = temp.getChild("fill").getString("g") != null ? form(temp.getChild("fill").getString("g")) : 255;
        rgba[2] = temp.getChild("fill").getString("b") != null ? form(temp.getChild("fill").getString("b")) : 255;
        rgba[3] = temp.getChild("fill").getString("a") != null ? form(temp.getChild("fill").getString("a")) : 255;
      }
      // TEXT
      String text = temp.getChild("text") != null
        ? replacement(temp.getChild("text").getContent())
        : "Text No Found";
      // TEXTSIZE
      float textSize = temp.getChild("textSize") != null
        ? form(temp.getChild("textSize").getContent())
        : 32;
      fill(rgba[0], rgba[1], rgba[2], rgba[3]);
      stext(text, x, y, textSize);
    }
    
    // Кнопка
    void recurs_button(XML temp, float x, float y) {
      // SIZE
      float sx = 100, sy = 100;
      if(temp.getChild("size") != null) {
        sx = temp.getChild("size").getString("x") != null ? form(temp.getChild("size").getString("x")) : 100;
        sy = temp.getChild("size").getString("y") != null ? form(temp.getChild("size").getString("y")) : 100;
      }
      
      // дополнительная переменная - buttonState
      int buttonState = 0;
      if(tap(x,y,sx,sy)) { buttonState = 1;
        if(mousePressed) { buttonState = 2;
      }}
      userDLC.put("buttonState", str(buttonState));
      
      // FILL
      float rgba[][] = new float[1][4];
      rgba[0][0] = 255;
      rgba[0][1] = 255;
      rgba[0][2] = 255;
      rgba[0][3] = 255;
      if(temp.getChild("fill") != null) {
        XML[] stages = temp.getChild("fill").getChildren("stage");
        rgba = new float[stages.length][4];
        for(int i = 0; i < stages.length; i++) {
          rgba[i][0] = stages[i].getString("r") != null ? form(stages[i].getString("r")) : 255;
          rgba[i][1] = stages[i].getString("g") != null ? form(stages[i].getString("g")) : 255;
          rgba[i][2] = stages[i].getString("b") != null ? form(stages[i].getString("b")) : 255;
          rgba[i][3] = stages[i].getString("a") != null ? form(stages[i].getString("a")) : 255;
        }
      }
      // ROUND
      float round = temp.getChild("round") != null
        ? form(temp.getChild("round").getContent())
        : 0;
      clearudlc();
      if(rgba.length == 1) {
        fill(rgba[0][0], rgba[0][1], rgba[0][2], rgba[0][3]);
      } else {
        fill(rgba[buttonState][0], rgba[buttonState][1], rgba[buttonState][2], rgba[buttonState][3]);
      }
      sblockRound(x,y,sx,sy,round);
      
      // Обработка нажатия
      if(mousePressed && tap(x,y,sx,sy)) {
        JSONObject event = new JSONObject();
        event.setString("token", temp.getString("token"));
        event.setFloat("size.x", sx).setFloat("size.y", sy);
        event.setFloat("position.x", x).setFloat("position.y", y);
        addEvent("button.press", event);
      }
    }
    
    // Рекурсия
    void recurs(XML init, float recx, float recy) {
      try {
        if(init.getName().equals("object")) {
          Boolean hider;
          if(init.getString("hider") == null) { hider = false;
            if(init.getString("hiderif") != null) { // Второй вид hider, сравнение
              if(!replacement(init.getString("hiderif")).equals(replacement(init.getString("hidereq")))) {
                hider = true;
              }
            }
          } else { hider = boolean(replacement(init.getString("hider")));
          }
          if(!hider) {
            // POSITION.x
            float x = recx + (init.getChild("position") != null && init.getChild("position").getString("x") != null 
              ? form(init.getChild("position").getString("x"))
              : 0
            );
            // POSITION.y
            float y = recy + (init.getChild("position") != null && init.getChild("position").getString("y") != null 
              ? form(init.getChild("position").getString("y"))
              : 0
            );
            String type = init.getString("type");
            if(type != null) {
              // TEXT
              if(type.equals("text")) {
                recurs_text(init, x, y);
              }
              // BUTTON
              if(type.equals("button")) {
                recurs_button(init, x, y);
              }
            }
            newRecurs(init.getChildren(), x, y);
          }
        }
      } catch(Exception e) {
        printlne(e.getMessage());
        e.printStackTrace();
        exit();
      }
    }
    
    // Работа с переменными
    void editVarRepl(String key, String d) {
      DLC_vars.put(key, replacement(d));
    }
    void editVarForm(String key, String d) {
      DLC_vars.put(key, str(form(d)));
    }
    String getVar(String key) {
      return DLC_vars.get(key);
    }
    
    float form(String string) {
      return eval(replacement(string));
    }
    
    HashMap<String, String> userDLC = new HashMap<String, String>();
    void clearudlc() { userDLC = new HashMap<String, String>(); }
    String replacement(String string) {
      HashMap<String, String> map = new HashMap<String, String>();
      
      map.putAll(userDLC);
      
      if(DLC_vars != null) { for (String key : DLC_vars.keySet()) { map.put("vars." + key, DLC_vars.get(key));
        }
      }
      if(gvars != null) { for (String key : gvars.keySet()) { map.put("vars." + key, gvars.get(key));
        }
      }
      
      map.putAll(DLC_lang);
      
      // Стандартные переменные
      map.put("disW", str(disW)); map.put("disH", str(disH));
      map.put("disW2", str(disW2)); map.put("disH2", str(disH2));
      map.put("frameCount", str(frameCount));
      map.put("frameRate", str(frameRate));
      map.put("moux", str(moux)); map.put("mouy", str(mouy));
      map.put("mouseX", str(mouseX)); map.put("mouseY", str(mouseY));
      map.put("TOP", str(TOP)); map.put("DOWN", str(DOWN)); map.put("LEFT", str(LEFT)); map.put("RIGHT", str(RIGHT));
      map.put("mousePressed", str(int(mousePressed)));
      
      //println(map);
      
      return formater(string, map);
    }
    
    // Кастомная функция кнопки
    void button(float x, float y, float sx, float sy, float b) {
      sblockRound(x,y,sx,sy,b);
    }
  }
}
