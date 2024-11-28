consoleDis condis = new consoleDis();

void setup() {
  size(1280, 720, P2D);
  surface.setResizable(true);
  surface.setLocation(100, 50);
  textSize(32);
  cdm_st = condis;
  //uif.setup();
  //uif.loadPack("testpack.json");
  //uif.changeLang("en");
  uifxml.setup();
  //uifxml.importPack("testpack.xml");
  crcecore.setup();
}

void draw() {
  background(0);
  disUpdate();
  
  crcecore.draw();
  
  /*uif.scenes.get("testui1").render();
  JSONArray events = uif.getEvents();
  for (int i = 0; i < events.size(); i++) {
    JSONObject data = events.getJSONObject(i);
    if(data.getString("scene").equals("testui1")) {
      if(data.getString("event").equals("button_pressed")) {
        if(data.getString("id").equals("plus")) {
          uif.scenes.get("testui1").vars.put("count", (int)uif.scenes.get("testui1").vars.get("count") + 10);
        }
        if(data.getString("id").equals("minus")) {
          uif.scenes.get("testui1").vars.put("count", (int)uif.scenes.get("testui1").vars.get("count") - 10);
        }
        if(data.getString("id").equals("trueorfalse")) {
          uif.scenes.get("testui1").vars.put("booleanvar", !(Boolean)uif.scenes.get("testui1").vars.get("booleanvar"));
        }
      }
    }
  }*/
  
  /*uifxml.scenes.get("uiTester").render();
  
  ArrayList<JSONObject> events = uifxml.getEvents("button.press");
  for(int i = 0; i < events.size(); i++) {
    JSONObject t = events.get(i);
    if(t.getString("token").equals("button+")) {
      uifxml.scenes.get("uiTester").editVarForm("count", uifxml.scenes.get("uiTester").getVar("count") + "+1");
    }
    if(t.getString("token").equals("button-")) {
      uifxml.scenes.get("uiTester").editVarForm("count", uifxml.scenes.get("uiTester").getVar("count") + "-1");
    }
  }*/
  
  condis.draw(); // Дисплейная консоль
  
  //debug();
}

void mousePressed() {
  crcecore.mousePressed();
}

void mouseReleased() {
  crcecore.mouseReleased();
}
