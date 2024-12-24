uifxml uifxml = new uifxml();
class uifxml {
  String pathMain;
  String pathPack;
  
  String globalLang = "ru";
  
  // <Scene, <Event, Data>>
  HashMap<String, HashMap<String, ArrayList>> events = new HashMap<String, HashMap<String, ArrayList>>();
  ArrayList getEvents(String scene, String typeEvent) {
    ArrayList temp = new ArrayList();
    if(events.containsKey(scene)) {
      if(events.get(scene).containsKey(typeEvent)) {
        temp = events.get(scene).get(typeEvent);
        events.get(scene).remove(typeEvent);
      } else {
        //printlne("Тип ивента (",typeEvent,") не найден в events.",scene);
      }
    } else {
      //printlne("Сцена (",scene,") не найдена в events");
    }
    return temp;
  }
  void addEvent(String scene, String typeEvent, JSONObject event) {
    if(!events.containsKey(scene)) {
      events.put(scene, new HashMap<String, ArrayList>());
      printlne("Автоматически добавлена сцена: " + scene);
    }
    HashMap<String, ArrayList> sceneEvents = events.get(scene);
    if(!sceneEvents.containsKey(typeEvent)) {
      sceneEvents.put(typeEvent, new ArrayList());
      //printlne("Автоматически добавлен typeEvent: " + typeEvent + " в сцену: " + scene);
    }
    sceneEvents.get(typeEvent).add(event);
  }
  
  XML vars;
  HashMap<String, String> gvars;
  String getGVar(String key) {
    return uifxml.gvars.get(key);
  }
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
    if(stylesMerge.getChildren("style") != null) {
      printlne("В одном из стилей или в нескольких стилях вызывается <style> (это бесполезно)");
    }
    //printlne(stylesMerge);
    //printlne(map);
    //stylesMerge = parseXML(formater(stylesMerge.toString(), map, "", ""));
    //printlne(stylesMerge);
    
    // Загрузка глобальных переменных
    vars = tempPack.getChild("globalvars");
    if(vars != null) { bv(); }
    
    HashMap<String, HashMap<String, ArrayList>> events = new HashMap<String, HashMap<String, ArrayList>>();
    
    for(int i = 0; i < sceneList.length; i++) {
      XML lef = sceneList[i];
      printlne("Загрузка сцены "+lef.getString("name"));
      ui ui = new ui();
      
      // Выделение места в events под сцену
      events.put(lef.getString("name"), new HashMap<String, ArrayList>());
      //printlne(lef.getString("name"), new HashMap<String, ArrayList>());
      
      ui.sceneName = lef.getString("name");
      ui.data = lef.getChild("data");
      ui.lang = lef.getChild("lang");
      if(ui.lang == null) { ui.lang = new XML("lang"); }
      ui.vars = lef.getChild("vars");
      if(ui.vars == null) { ui.vars = new XML("vars"); }
      ui.style = stylesMerge;
      ui.buildLang();
      ui.buildVars();
      //printlne(ui.data, ui.lang, ui.vars);
      
      scenes.put(lef.getString("name"), ui);
    }
    printlne(events);
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
        // IF
        if(rec[i].getName().equals("if")) {
          String arg1 = replacement(rec[i].getString("arg1"));
          String type = rec[i].getString("type");
          String arg2 = replacement(rec[i].getString("arg2"));
          int iarg1 = 0, iarg2 = 0;
          if(type.equals("==")) {
            if(arg1.equals(arg2)) { newRecurs(rec[i].getChildren(), recx, recy);
            }
          } else if(type.equals("!=")) {
            if(!arg1.equals(arg2)) { newRecurs(rec[i].getChildren(), recx, recy);
            }
          } else {
            iarg1 = int(eval(arg1));
            iarg2 = int(eval(arg2));
          }
          if(type.equals("<=")) {
            if(iarg1 <= iarg2) { newRecurs(rec[i].getChildren(), recx, recy);
            }
          } else
          if(type.equals(">=")) {
            if(iarg1 >= iarg2) { newRecurs(rec[i].getChildren(), recx, recy);
            }
          }
        }
        // FOR
        if(rec[i].getName().equals("for")) {
          for(int s = int(form(rec[i].getString("vardef"))); s < int(form(rec[i].getString("varend"))); s += int(form(rec[i].getString("varadd")))) {
            userDLC.put("for."+replacement(rec[i].getString("varname")), str(s));
            newRecurs(rec[i].getChildren(), recx, recy);
          }
        }
        // STYLE
        if(rec[i].getName().equals("style")) {
          // Использование STYLE
          // Получение всех <style></style>
          XML allstyle = rec[i];
          //XML[] styles = style.getChildren();
          HashMap<String, String> temp = new HashMap<String, String>();
          XML temp_style = style.getChild(allstyle.getString("id"));
          println(temp_style);
          
          // Применение стилей внутри стиля
          XML[] temp_style_style = temp_style.getChildren(allstyle.getString("style"));
          for(int s = 0; s < temp_style_style.length; s++) {
            if(temp_style_style[i].getName().equals("style")) {
              
            }
          }
          
          // Получение нужных аргументов
          JSONArray argslist = parseJSONArray(temp_style.getString("input").toString());
          // Получение значений аргументов из allstyle[s]
          HashMap<String, String> finalargs = new HashMap<String, String>();
          for(int s2 = 0; s2 < argslist.size(); s2++) {
            finalargs.put("input."+argslist.getString(s2), allstyle.getString(argslist.getString(s2)));
          }
          // Применение аргументов из finalargs к temp_style
          temp_style = parseXML(formater(temp_style.toString(), finalargs));
          temp.put(allstyle.toString(), temp_style.toString().replaceAll("<"+temp_style.getName()+"[^>]*>", "").replaceAll("</"+temp_style.getName()+">", ""));
          rec[i] = parseXML( formater(rec[i].toString(), temp, "", "") );
          recurs(rec[i], recx, recy);
        }
        // OBJECT
        if(rec[i].getName().equals("object")) {
          recurs(rec[i], recx, recy);
        }
      }
    }
    
    void recurs_interpretation_stroke(XML temp) {
      XML datastroke = temp.getChild("stroke");
      if(datastroke != null) {
        // FILL
        float rgba[] = {255,255,255,255};
        if(temp.getChild("fill") != null) {
          rgba[0] = datastroke.getChild("fill").getString("r") != null ? form(datastroke.getChild("fill").getString("r")) : 255;
          rgba[1] = datastroke.getChild("fill").getString("g") != null ? form(datastroke.getChild("fill").getString("g")) : 255;
          rgba[2] = datastroke.getChild("fill").getString("b") != null ? form(datastroke.getChild("fill").getString("b")) : 255;
          rgba[3] = datastroke.getChild("fill").getString("a") != null ? form(datastroke.getChild("fill").getString("a")) : 255;
        }
        // SIZE
        float size = datastroke.getChild("size") != null
          ? form(datastroke.getChild("size").getContent())
          : 1;
        strokeWeight(size);
        stroke(rgba[0], rgba[1], rgba[2], rgba[3]);
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
      stext(text, x, y+2.5, textSize);
    }
    
    Boolean taplock = false;
    
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
      // STROKEILL
      float strrgba[][] = new float[0][4];
      if(temp.getChild("strokefill") != null) {
        XML[] stages = temp.getChild("strokefill").getChildren("stage");
        strrgba = new float[stages.length][4];
        for(int i = 0; i < stages.length; i++) {
          strrgba[i][0] = stages[i].getString("r") != null ? form(stages[i].getString("r")) : 255;
          strrgba[i][1] = stages[i].getString("g") != null ? form(stages[i].getString("g")) : 255;
          strrgba[i][2] = stages[i].getString("b") != null ? form(stages[i].getString("b")) : 255;
          strrgba[i][3] = stages[i].getString("a") != null ? form(stages[i].getString("a")) : 255;
        }
      }
      // ROUND
      float round = temp.getChild("round") != null
        ? form(temp.getChild("round").getContent())
        : 0;
      if(rgba.length == 1) {
        fill(rgba[0][0], rgba[0][1], rgba[0][2], rgba[0][3]);
      } else {
        fill(rgba[buttonState][0], rgba[buttonState][1], rgba[buttonState][2], rgba[buttonState][3]);
      }
      if(strrgba.length != 0) {
        if(strrgba.length == 1) {
          stroke(strrgba[0][0], strrgba[0][1], strrgba[0][2], strrgba[0][3]);
        } else {
          stroke(strrgba[buttonState][0], strrgba[buttonState][1], strrgba[buttonState][2], strrgba[buttonState][3]);
        }
      }
      sblockRound(x,y,sx,sy,round);
      noStroke();
      
      // Обработка нажатия
      if(mousePressed) {
        if(!taplock && tap(x,y,sx,sy)) {
          taplock = true;
          JSONObject event = new JSONObject();
          event.setString("token", temp.getString("token"));
          event.setFloat("size.x", sx).setFloat("size.y", sy);
          event.setFloat("position.x", x).setFloat("position.y", y);
          addEvent(sceneName, "button.press", event);
        }
      } else { taplock = false; }
    }
    
    // Рекурсия
    void recurs(XML init, float recx, float recy) {
      try {
        if(init.getName().equals("object")) {
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
            recurs_interpretation_stroke(init);
            // TEXT
            if(type.equals("text")) {
              recurs_text(init, x, y);
            }
            // BUTTON
            if(type.equals("button")) {
              recurs_button(init, x, y);
            }
            noStroke();
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
    
    // Другая система кастомных значений
    
    
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
      return formater(string, map);
    }
  }
}
