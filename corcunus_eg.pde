crceg crceg = new crceg();

JSONObject config;

// ПУТИ
String egpConfig, egpProjects;

class crceg {
  int egversion = 0;
  
  Boolean debug = false;
  Boolean debugEditing = false;
  void setup() {
    egpConfig = dataPath("eg_config.json");
    egpProjects = dataPath("projects")+"\\";
    if(!checkFolder(egpProjects)) {
      createFolders(egpProjects);
    }
    loadConfig();
  }
  
  void loadConfig() {
    printlne("Загрузка конфига");
    try {
      config = loadJSONObject(egpConfig);
      JSONObject temp;
      
      // FPS
      printlne("config > fps");
      temp = config.getJSONObject("fps");
      frameRate(temp.getInt("maximum"));
      
      // EXPERIMENTAL
      printlne("config > experimental");
      temp = config.getJSONObject("experimental");
      Boolean td = debug;
      debug = temp.getBoolean("debug");
      if(td != debug) {
        debugEditing = true;
      }
      
    } catch (Exception e) {
      printlne("ERROR:", e.getMessage());
    }
    printlne("Загрузка конфига завершена");
  }
  
  // LOAD PROJECT (WIN - 0)
  class_win0 class_win0 = new class_win0();
  window win0;
  void win0_setup() {
    win0 = new window((int)disW2-200, (int)disH2-200, 400, 400, "Меню при запуске");
    win0.hideButton = false;
    win0.debugMode = debug;
    windowsRender.add(win0);
    
    win0.setAction(class_win0);
    
    if(debugEditing) {
      popup.newPopup("debugEditing", "onlyOk", "Параметр debug изменен, для применения изменений перезапустите программу");
    }
  }
  class class_win0 extends action {
    int event = 0;
    glayer gl;
    void setup() {
      gl = win0.gl;
    }
    
    ArrayList<JSONObject> listProject = new ArrayList<JSONObject>();
    
    Boolean preopenProject = false; // Если проект по каким-то причинам ждет запрос от попупа
    String preopenProjectFoldername;
    void draw() {
      gl.clear();
      if(!preopenProject) {
        if(event == 0) {
          glbutton(gl, 0, 0, 200, 50);
          glbutton(gl, -gl.disW2+110, -gl.disH2+30, 200, 40);
          gl.fill(255);
          gl.stext("Открыть проект", 0, 2.5, 22);
          if(win1.show) { gl.fill(0,255,0);
          } else { gl.fill(255); }
          gl.stext("Настройки движка", -gl.disW2+110,-gl.disH2+32.5, 22);
        } else
        if(event == 1) {
          // Кнопка Назад
          glbutton(gl, -gl.disW2+30, gl.disH2-25, 50, 40);
          gl.fill(255);
          gl.stext("<", -gl.disW2+30, (gl.disH2-25)+2.5, 25);
          
          gl.fill(255);
          gl.stext("Открытие проекта", 0, gl.disH2-20, 20);
          
          // Список проектов
          for(int i = 0; i < listProject.size()+1; i++) {
            JSONObject temp_config;
            if(i > listProject.size()-1) { // Кнопка добавления нового проекта
              temp_config = new JSONObject().setString("name", "+");
            } else {
              temp_config = listProject.get(i);
            }
            glbutton(gl, 0, gl.disH2-80-(i*55), gl.disW-75, 50);
            if(temp_config.hasKey("compatVersion")) {
              gl.fill(255,63,63);
            } else {
              gl.fill(255);
            }
            gl.stext(temp_config.getString("name"), 0, gl.disH2-80-(i*55)+2.5, 22);
          }
        }
      } else {
        gl.fill(255);
        gl.stext("Ожидание ответа от попупа", 0, 5, 24);
        
        String req = popup.getOutput("openProjectNotVerREQ");
        if(!req.equals("false")) {
          if(req.equals("Yes")) {
            
          } else if(req.equals("No")) {
            preopenProject = false;
          }
        }
      }
    }
    void mousePressed() {
      if(!preopenProject) {
        if(event == 0) {
          // Открыть проект
          if(gl.tap(0,0,200,50)) { event = 1; generateProjectList(); }
          // Настройки
          if(gl.tap(-gl.disW2+110,-gl.disH2+30,200,40)) {
            win1.show = !win1.show;
            win1.x = 0;
            win1.y = 0;
          }
        } else
        if(event == 1) {
          // Назад
          if(gl.tap(-gl.disW2+30, gl.disH2-25, 50, 40)) {
            event = 0;
          }
          // Открытие проекта
          for(int i = 0; i < listProject.size()+1; i++) {
            JSONObject temp_config;
            if(i > listProject.size()-1) { temp_config = new JSONObject().setString("name", "+");
            } else { temp_config = listProject.get(i); }
            if(gl.tap(0, gl.disH2-80-(i*55), gl.disW-75, 50)) {
              // Проверка на критическую ошибку
              if(!temp_config.hasKey("error")) {
                if(temp_config.getString("name").equals("+")) {
                  
                } else {
                  // Если проект может быть не совместим из-за разногласий в версиях, то появляется предупреждение об этом
                  if(temp_config.hasKey("compatVersion")) {
                    preopenProjectFoldername = temp_config.getString("foldername");
                    preopenProject = true;
                    popup.newPopup("openProjectNotVerREQ", "YesOrNo", "Версия движка на котором был сделан проект не совпадает с текущей версией движка. Вы уверены, что хотите загрузить этот проект?");
                  } else {
                    
                  }
                }
              } else {
                popup.newPopup("openProjectError", "onlyOk", "Открыть невозможно открыть, так как он содержит критическую ошибку. Гляньте в консоль");
              }
            }
          }
        }
      }
    }
    void generateProjectList() {
      listProject = new ArrayList<JSONObject>();
      String folders[] = getFolderNames(egpProjects);
      for(int i = 0; i < folders.length; i++) {
        JSONObject temp = new JSONObject();
        try {
          int tempProjectEGVersion = int(loadStrings(egpProjects+folders[i]+"/egversion.txt")[0]);
          JSONObject tempProjectConfig = loadJSONObject(egpProjects+folders[i]+"/config.json");
          temp.setString("name", tempProjectConfig.getString("name"));
          if(tempProjectEGVersion < egversion) { temp.setString("compatVersion", "<");
          } else
          if(tempProjectEGVersion > egversion) { temp.setString("compatVersion", ">");
          }
          temp.setString("foldername", folders[i]);
        } catch (Exception e) { printlne(e.getMessage());
          temp.setString("name", "LOADERROR: "+folders[i]);
          temp.setBoolean("error", true);
        }
        listProject.add(temp);
      }
    }
  }
  
  // ENGINE SETTINGS (WIN - 1)
  class_win1 class_win1 = new class_win1();
  window win1;
  void win1_setup() {
    win1 = new window(0, 0, 400, 300, "Настройки движка");
    win1.hide();
    win1.debugMode = debug;
    windowsRender.add(win1);
    
    win1.setAction(class_win1);
  }
  class class_win1 extends action {
    
    int event = 0;
    String[][][] settings = {
      {{"Пути"},
        {"textOnly"},
      },
    };
    
    int openCategory = 0;
    
    glayer gl;
    void setup() {
      gl = win1.gl;
    }
    void draw() {
      gl.clear();
      /*// Список категорий
      if(event == 0) {
        for(int i = 0; i < settings.length; i++) {
          glbutton(gl, 0, gl.disH2-50+(50*i), gl.disW-50, 50);
          gl.fill(255);
          gl.stext(settings[i][0][0], 0, gl.disH2-50+(50*i)+2.5, 20);
        }
      } else
      // Список параметров
      if(event == 1) {
        gl.fill(255);
        gl.stext(settings[openCategory][0][0], 0, gl.disH2-16, 20);
        
        
      }*/
      glbutton(gl, 0, -gl.disH2+50, 250, 50);
      glbutton(gl, 0, -gl.disH2+110, 250, 50);
      gl.fill(255);
      gl.stext("Открыть файл конфига", 0, -gl.disH2+50+2.5, 20);
      gl.stext("Загрузить конфиг", 0, -gl.disH2+110+2.5, 20);
      gl.stext("Встроенный редактор пока не сделан", 0, gl.disH2-50, 20);
    }
    void mousePressed() {
      /*if(event == 0) {
        for(int i = 0; i < settings.length; i++) {
          if(gl.tap(0, gl.disH2-50+(50*i), gl.disW-50, 50)) {
            event = 1;
            openCategory = i;
          }
        }
      }*/
      if(gl.tap(0, -gl.disH2+50, 250, 50)) {
        launch(egpConfig);
      } else if(gl.tap(0, -gl.disH2+110, 250, 50)) {
        loadConfig();
        if(debugEditing) {
          popup.newPopup("debugEditing", "onlyOk", "Параметр debug изменен, для применения изменений перезапустите программу");
        }
      }
    }
  }
}

popup popup = new popup();
class popup {
  Boolean out = false;
  String outputTag;
  String output;
  
  //ArrayList<JSONObject> data = new ArrayList<JSONObject>();
  window win;
  ArrayList<JSONObject> popups = new ArrayList<JSONObject>();
  
  void newPopup(String tag, String type, String text) {
    out = false;
    
    if(win == null) {
      win = new window((int)disW-500, 0, 500, 200, "Попуп");
      win.hideButton = false;
      win.setAction(winpopup);
      windowsRender.add(win);
    }
    
    win.show();
    
    JSONObject temp = new JSONObject();
    temp.setString("tag", tag);
    temp.setString("type", type);
    temp.setString("text", text);
    
    popups.add(temp);
  }
  
  String getOutput(String tag) {
    if(out) {
      if(tag.equals(outputTag)) {
        out = false;
        return output;
      } else { return "false"; }
    } else { return "false"; }
  }
  
  void closeLastPopup() {
    if(popups.size() > 0) {
      popups.remove(0);
    }
    if(popups.size() <= 0) {
      win.hide();
    }
  }
  
  winpopup winpopup = new winpopup();
  class winpopup extends action {
    glayer gl;
    void setup() {
      gl = win.gl;
    }
    void draw() {
      gl.clear();
      if(popups.size() > 0) {
        JSONObject data = popups.get(0);
        if(data.getString("type").equals("onlyOk")) {
          glbutton(gl, 0, -gl.disH2+35, 200, 40);
          gl.fill(255);
          gl.stext("OK", 0, -gl.disH2+35+2.5, 20);
        } else
        if(data.getString("type").equals("YesOrNo")) {
          glbutton(gl, -55, -gl.disH2+35, 100, 40);
          glbutton(gl, 55, -gl.disH2+35, 100, 40);
          gl.fill(255);
          gl.stext("Yes", -55, -gl.disH2+35+2.5, 20);
          gl.stext("No", 55, -gl.disH2+35+2.5, 20);
        }
        gl.stext(data.getString("text"), 0, gl.disH2-50, 20, gl.disW-50);
      }
    }
    void mousePressed() {
      if(popups.size() > 0) {
        JSONObject data = popups.get(0);
        if(data.getString("type").equals("onlyOk")) {
          if(gl.tap(0, -gl.disH2+35, 200, 40)) {
            out = true;
            outputTag = popups.get(0).getString("tag");
            output = "OK";
            closeLastPopup();
          }
        } else if(data.getString("type").equals("YesOrNo")) {
          if(gl.tap(-55, -gl.disH2+35, 100, 40)) {
            output = "Yes";
          }
          if(gl.tap(55, -gl.disH2+35, 100, 40)) {
            output = "No";
          }
          if(gl.tap(-55, -gl.disH2+35, 100, 40) || gl.tap(55, -gl.disH2+35, 100, 40)) {
            out = true;
            outputTag = popups.get(0).getString("tag");
            closeLastPopup();
          }
        }
      }
    }
  }
}
  
void glbutton(glayer gl, float x, float y, float wx, float wy) {
  gl.stroke(0); gl.fill(80);
  if(gl.tap(x,y,wx,wy))
    { gl.fill(80+16+(int(mousePressed)*16)); gl.stroke(200); }
  gl.sblock(x,y,wx,wy);
}
