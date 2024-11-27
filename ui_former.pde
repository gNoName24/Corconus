// Что-то для удобства создания UI

// Логика работы:
// - В uif класс загружается один файл, в котором находятся множество файлов, каждый из них который представляет отдельный интерфейс
// - Для каждого файла из загруженного файла будет создан свой класс ui


uif uif = new uif();
class uif {
  String pathMain;
  String pathPack;
  
  // Тут очередь из всех событий произошедших во всех сценах за один кадр
  JSONArray events = new JSONArray();
  
  JSONArray getEvents() {
    JSONArray temp = events;
    events = new JSONArray();
    return temp;
  }
  
  String globalLang = "ru";
  
  void setup() {
    pathMain = sketchPath()+"\\data\\uif\\";
    printlne("pathMain -", pathMain);
  }
  
  void loadPack(String namePack) {
    pathPack = pathMain+namePack;
    
    printlne("Загрузка UIF пакета началась");
    printlne("pathPack -", pathPack);
    
    JSONArray temp_pack = loadJSONArray(pathPack);
    //printlne(temp_pack);
    
    // Создание классов
    scenes = new HashMap<String, ui>();
    for(int i = 0; i < temp_pack.size(); i++) {
      JSONObject temp_scene = temp_pack.getJSONObject(i);
      printlne("Загружается сцена", temp_scene.getString("nameScene"), "(i: "+i+")");
      scenes.put(temp_scene.getString("nameScene"), new ui());
      scenes.get(temp_scene.getString("nameScene")).nameScene = temp_scene.getString("nameScene");
      scenes.get(temp_scene.getString("nameScene")).data = temp_scene.getJSONArray("sceneData");
      scenes.get(temp_scene.getString("nameScene")).variables = temp_scene.getJSONObject("variables");
      scenes.get(temp_scene.getString("nameScene")).langData = temp_scene.getJSONObject("langData");
      scenes.get(temp_scene.getString("nameScene")).buildLang();
      scenes.get(temp_scene.getString("nameScene")).buildVariables();
    }
    printlne("FINAL / scenes -", scenes);
    //println(TOP, DOWN, LEFT, RIGHT);
  }
  
  void changeLang(String newLang) {
    globalLang = newLang;
    for (String key : scenes.keySet()) {
      scenes.get(key).buildLang();
    }
  }
  
  HashMap<String, ui> scenes = new HashMap<String, ui>();
  class ui {
    String nameScene;
    JSONArray data;
    XML dataxml;
    JSONObject variables;
    JSONObject langData;
    HashMap<String, String> lang = new HashMap<String, String>();
    
    //
    Boolean mousePressedTemp = false;
    
    // VARIABLES
    HashMap<String, Object> vars = new HashMap<String, Object>();
    
    // Построение переменных (с нуля)
    void buildVariables() {
      vars = new HashMap<String, Object>();
      Set<String> keys = variables.keys();
      for(String key : keys) {
        vars.put(key, variables.get(key));
      }
      printlne(vars);
    }
    
    // DEBUG
    Boolean debugText = false;
    
    // Построение языка
    void buildLang() {
      lang = new HashMap<String, String>();
      Set<String> keys = langData.getJSONObject(globalLang).keys();
      for(String key : keys) {
        printlne("Загружается язык "+globalLang+": ID-"+key);
        lang.put("lang."+key, langData.getJSONObject(globalLang).getString(key));
      }
    }
    
    void render() {
      for(int i = 0; i < data.size(); i++) {
        JSONObject object = data.getJSONObject(i);
        // TEXT
        if(object.getString("type").equals("text")) {
          fill(
            combo(object.getJSONArray("text.color").getString(0)),
            combo(object.getJSONArray("text.color").getString(1)),
            combo(object.getJSONArray("text.color").getString(2))
          );
          stext(standartDL(object.getString("text.text")),
            eval(standartDL(object.getJSONArray("text.position_align").getString(0))+"+"+standartDL(object.getJSONArray("text.position").getString(0))),
            eval(standartDL(object.getJSONArray("text.position_align").getString(1))+"+"+standartDL(object.getJSONArray("text.position").getString(1))),
            combo(object.getString("text.size"))
          );
        }
        // BUTTON
        if(object.getString("type").equals("button")) {
          float x = eval(standartDL(object.getJSONArray("button.position_align").getString(0))+"+"+standartDL(object.getJSONArray("button.position").getString(0)));
          float y = eval(standartDL(object.getJSONArray("button.position_align").getString(1))+"+"+standartDL(object.getJSONArray("button.position").getString(1)));
          float xs = combo(object.getJSONArray("button.size").getString(0));
          float ys = combo(object.getJSONArray("button.size").getString(1));
          
          // Если мышка прикасается к кнопке
          int bp = 0;
          if(tap(x,y,xs,ys)) {
            if(mousePressed) { dl.put("buttonPress", "2"); bp = 2;
            } else { dl.put("buttonPress", "1"); bp = 1; }
          } else { dl.put("buttonPress", "0"); }
          
          if(object.getJSONArray("button.color").size() > 1) {
            fill(
              combo(object.getJSONArray("button.color").getJSONArray(bp).getString(0)),
              combo(object.getJSONArray("button.color").getJSONArray(bp).getString(1)),
              combo(object.getJSONArray("button.color").getJSONArray(bp).getString(2))
            );
          } else {
            fill(
              combo(object.getJSONArray("button.color").getJSONArray(0).getString(0)),
              combo(object.getJSONArray("button.color").getJSONArray(0).getString(1)),
              combo(object.getJSONArray("button.color").getJSONArray(0).getString(2))
            );
          }
          button(x, y, xs, ys, combo(object.getString("button.radii")));
          
          fill(
            combo(object.getJSONArray("button.text.color").getString(0)),
            combo(object.getJSONArray("button.text.color").getString(1)),
            combo(object.getJSONArray("button.text.color").getString(2))
          );
          stext(standartDL(object.getString("button.text.text")), x, y+2.5, combo(object.getString("button.text.size")));
            
          clearDL();
          
          // EVENT
          if(mousePressed) {
            if(tap(x, y, xs, ys)) {
              if(!mousePressedTemp) {
                JSONObject dump = new JSONObject();
                dump.setString("scene", nameScene);
                dump.setString("id", object.getString("id"));
                dump.setString("event", "button_pressed");
                events.setJSONObject(events.size(), dump);
                //printlne("NEW EVENT:", nameScene+" /", object.getString("id")+" /", "button_pressed");
              }
              mousePressedTemp = true;
            }
          } else {
            mousePressedTemp = false;
          }
        }
      }
    }
    
    float combo(String text) {
      return eval(standartDL(text));
    }
    HashMap<String, String> dl = new HashMap<String, String>();
    String standartDL(String text) {
      HashMap<String, String> map = new HashMap<String, String>();
      
      map.putAll(dl);
      if(!debugText) { map.putAll(lang); }
      
      for (String key : vars.keySet()) {
        //map.put("vars."+key, vars.get(key).toString());
        map.put("vars." + key, vars.get(key) instanceof Boolean ? (Boolean) vars.get(key) ? "1" : "0" : vars.get(key).toString());
      }
      
      // Standart values
      map.put("disW", str(disW)); map.put("disH", str(disH));
      map.put("disW2", str(disW2)); map.put("disH2", str(disH2));
      map.put("frameCount", str(frameCount));
      map.put("moux", str(moux)); map.put("mouy", str(mouy));
      map.put("mouseX", str(mouseX)); map.put("mouseY", str(mouseY));
      
      return formater(text, map);
    }
    void clearDL() { dl = new HashMap<String, String>(); }
  }
  
  // Кастомная функция кнопки
  void button(float x, float y, float sx, float sy, float b) {
    sblockRound(x,y,sx,sy,b);
  }
  
  float eval(String expr) {
    try {
      Expression e = new ExpressionBuilder(expr).build();
      double res = e.evaluate();
      return (float) res;
    } catch(Exception e) {
      return (frameCount*2)%rand(20,40);
    }
  }
}


class uifEditor {
  
}
