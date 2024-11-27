// by Lavok, modified NoName24
// version 26.10.2024

// https://github.com/fasseg/exp4j
import net.objecthunter.exp4j.Expression;
import net.objecthunter.exp4j.ExpressionBuilder;

import java.util.*;
import java.nio.file.*;
import java.io.File;

float disH, disW, disH2, disW2, mouy, moux; // экранные переменные
int event = 0; // ивент
float _fix; // фикс под экраны
//float _customFix;
int _fixCount = 1600; // разрешение под которое будет подстаиваться фикс
int lastTime;
float deltaTime;
Date unix;

color fillColor[] = new color[3];
void fillColor(color col1, color col2, color col3) { fillColor[0] = col1; fillColor[1] = col2; fillColor[2] = col3; }
void fillColor(color col, int force) { fillColor[0] = col; fillColor[1] = col - (force/2); fillColor[2] = col - force; }

public void disUpdate() {
  unix = new Date();
  disW = width; disH = height;
  disH2 = disH/2; disW2 = disW/2;
  moux = mouseX-disW2; mouy = -mouseY+disH2;
  _fix = _fixCount/disW;
  //deltaTime = 60 / frameRate;
  int currentTime = millis();
  deltaTime = (currentTime - lastTime) / 1000.0; // Переводим миллисекунды в секунды
  lastTime = currentTime;
}

void debug() {
  String text = "FPS: "+int(frameRate)+" / event: "+event+"\n"+
    "deltaTime: "+deltaTime+"\n"+
    //"position.x: "+core.mainPlayer.position.x+" / position.x: "+core.mainPlayer.position.y+"\n"+
    "Total Memory: " + bytesToMB(getTotalMemory()) + " MB"+"\n"+
    "Free Memory: " + int(bytesToMB(getFreeMemory())) + " MB"+"\n"+
    "Used Memory: " + int(bytesToMB(getUsedMemory())) + " MB"+"\n"+
    "Memory Usage Percentage: " + round(getMemoryUsagePercentage()) + "%";
    //"cameraPos:"+testscene.playerCam;
  fill(0,127-32);
  rect(0, 0, 35+textWidth(text), lengthLine(text)*32);
  fill(255);
  stext(LEFT, TOP, text, -disW2+20, disH2-20, 16);
}

long getTotalMemory() {
  Runtime runtime = Runtime.getRuntime();
  return runtime.totalMemory();
}

long getFreeMemory() {
  Runtime runtime = Runtime.getRuntime();
  return runtime.freeMemory();
}

long getUsedMemory() {
  return getTotalMemory() - getFreeMemory();
}

float getMemoryUsagePercentage() {
  long totalMemory = getTotalMemory();
  long usedMemory = getUsedMemory();
  return (float) usedMemory / totalMemory * 100;
}

float eval(String expr) {
  try {
    Expression e = new ExpressionBuilder(expr).build();
    double res = e.evaluate();
    return (float) res;
  } catch(Exception e) {
    printlne("EVAL ERROR:", expr);
    return (frameCount*2)%rand(20,40);
  }
}


String formater(String text, HashMap<String, String> maper) {
  String txtnew = text;
  for (String key : maper.keySet()) {
    String placeholder = "{"+key+"}";
    txtnew = txtnew.replace(placeholder, maper.get(key));
  }
  return txtnew;
}
String formater(String text, HashMap<String, String> maper, String str1, String str2) {
  String txtnew = text;
  for (String key : maper.keySet()) {
    String placeholder = str1+key+str2;
    txtnew = txtnew.replace(placeholder, maper.get(key));
  }
  return txtnew;
}


// выключи если не используешь consoleDis
Boolean consoleDisMode = true;
consoleDis cdm_st; // установи сюда класс consoleDis
void printlne(Object... message) {
  String text = "";
  for(int i = 0; i < message.length; i++) { text += String.valueOf(message[i]); if(i < message.length-1) { text += " "; } }
  StackTraceElement[] stackTrace = new Throwable().getStackTrace();
  String className = stackTrace[1].getClassName();  // Имя класса, вызвавшего метод
  String methodName = stackTrace[1].getMethodName(); // Имя метода, вызвавшего метод
  println("$"+className+"/"+methodName+"(): "+text);
  if(consoleDisMode) {
    cdm_st.input("$"+className+"/"+methodName+"(): "+text);
  }
}

float bytesToMB(long bytes) {
  return bytes / (1024.0 * 1024.0);
}

String removeAfterChar(String input, char delimiter) {
  int index = input.indexOf(delimiter);
  
  // Если символ найден, возвращаем подстроку до него
  if (index != -1) {
    return input.substring(0, index);
  }
  
  // Если символ не найден, возвращаем исходную строку
  return input;
}

// округление числа до определенного числа после запятой
float advRound(float number, int decimal) {
  float multiplier = pow(10, decimal);
  return round(number * multiplier) / multiplier;
}

// количество строк
int lengthLine(String str) {
  String[] lines = split(str, '\n');
  return lines.length;
}

// удаление всех элементов с заданным значением
String[] removeElement(String[] array, String element) {
  int count = 0;
  for (String s : array) { if (s.equals(element)) { count++; }}
  String[] result = new String[array.length - count];
  int index = 0;
  for (String s : array) { if (!s.equals(element)) { result[index++] = s; }}
  return result;
}

// нажатие:

Boolean oldtap(float xPos, float yPos, float xSize, float ySize) {
  if ((mouseX>xPos)&&(mouseX<xPos+xSize)&&(mouseY>yPos)&&(mouseY<yPos+ySize)) {
    return true;
  } else {
    return false;
  }
}

// проверка на касание
Boolean tap(float xPos, float yPos, float xSize, float ySize) {
  if (((moux>xPos-xSize/2)&&(moux<xPos+xSize/2))&&((mouy>yPos-ySize/2)&&(mouy<yPos+ySize/2))) {
    return true;
  } else {
    return false;
  }
}

Boolean tapfix(float disx, float xPos, float disy, float yPos, float xSize, float ySize) {
  if (((moux>disx+(xPos/_fix)-(xSize/_fix)/2)
      &&(moux<disx+(xPos/_fix)+(xSize/_fix)/2))
      &&((mouy>disy+(yPos/_fix)-(ySize/_fix)/2)
      &&(mouy<disy+(yPos/_fix)+(ySize/_fix)/2))) {
    return true;
  } else {
    return false;
  }
}

// проверка на касание с поворотом
Boolean tapfix_rotate(float disx, float xPos, float disy, float yPos, float xSize, float ySize, float rotationAngle) {
  float cosAngle = cos(rotationAngle);
  float sinAngle = sin(rotationAngle);
  float centerX = disx + (xPos / _fix);
  float centerY = disy + (yPos / _fix);
  float mouseXRotated = (moux - centerX) * cosAngle - (mouy - centerY) * sinAngle + centerX;
  float mouseYRotated = (moux - centerX) * sinAngle + (mouy - centerY) * cosAngle + centerY;
  if (((mouseXRotated > centerX - (xSize / _fix) / 2) && (mouseXRotated < centerX + (xSize / _fix) / 2)) &&
      ((mouseYRotated > centerY - (ySize / _fix) / 2) && (mouseYRotated < centerY + (ySize / _fix) / 2))) {
    return true;
  } else {
    return false;
  }
}

// оклругление (сокращенная функция)
int r(float num) {
  return round(num);
}

// рандом с округлением
int rand(float randMin, float randMax) {
  return round(random(randMin, randMax));
}

float leng(float X1, float Y1) {
  return sqrt(X1*X1+Y1*Y1);
}

float leng3d(float X1, float Y1, float Z1) {
  return sqrt(X1*X1+Y1*Y1+Z1*Z1);
}

// получение оптимизированных координат (X)
float getx(float xPos, float xSize) {
  return disW2 + xPos - xSize/2;
}

// получение оптимизированных координат (Y)
float gety(float yPos, float ySize) {
  return disH2 - yPos - ySize/2;
}

// получение оптимизированных координат (X) с фиксом
float getxfix(float disx, float xPos, float xSize) {
  return disW2 + (disx+(xPos/_fix)) - (xSize/_fix)/2;
}

// получение оптимизированных координат (Y) с фиксом
float getyfix(float disy, float yPos, float ySize) {
  return disH2 - (disy+(yPos/_fix)) - (ySize/_fix)/2;
}

// получение String из JSONObject по адресу
String get_str(JSONObject jsonobj, String[] keys) {
  JSONObject memory = jsonobj.getJSONObject(keys[0]);
  for(int i = 1; i < keys.length-1; i++) {memory = memory.getJSONObject(keys[i]);}
  return memory.getString(keys[keys.length-1]);
}

// получение Int из JSONObject по адресу
int get_int(JSONObject jsonobj, String[] keys) {
  JSONObject memory = jsonobj.getJSONObject(keys[0]);
  for(int i = 1; i < keys.length-1; i++) {memory = memory.getJSONObject(keys[i]);}
  return memory.getInt(keys[keys.length-1]);
}

// получение Float из JSONObject по адресу
float get_float(JSONObject jsonobj, String[] keys) {
  JSONObject memory = jsonobj.getJSONObject(keys[0]);
  for(int i = 1; i < keys.length-1; i++) {memory = memory.getJSONObject(keys[i]);}
  return memory.getFloat(keys[keys.length-1]);
}

// получение JSONObject из JSONObject по адресу
JSONObject get_jsonobj(JSONObject jsonobj, String[] keys) {
  JSONObject memory = jsonobj.getJSONObject(keys[0]);
  for(int i = 1; i < keys.length-1; i++) {memory = memory.getJSONObject(keys[i]);}
  return memory.getJSONObject(keys[keys.length-1]);
}

// получение String из JSONObject по адресу
void set_str(JSONObject jsonobj, String[] keys, String nameKey, String value) {
  JSONObject memory = jsonobj.getJSONObject(keys[0]);
  for(int i = 1; i < keys.length; i++) {memory = memory.getJSONObject(keys[i]);}
  memory.setString(nameKey, value);
}

// получение Int из JSONObject по адресу
void set_bool(JSONObject jsonobj, String[] keys, String nameKey, Boolean value) {
  JSONObject memory = jsonobj.getJSONObject(keys[0]);
  for(int i = 1; i < keys.length; i++) {memory = memory.getJSONObject(keys[i]);}
  memory.setBoolean(nameKey, value);
}

// получение Int из JSONObject по адресу
void set_Int(JSONObject jsonobj, String[] keys, String nameKey, int value) {
  JSONObject memory = jsonobj.getJSONObject(keys[0]);
  for(int i = 1; i < keys.length; i++) {memory = memory.getJSONObject(keys[i]);}
  memory.setInt(nameKey, value);
}

// получение Float из JSONObject по адресу
void set_Float(JSONObject jsonobj, String[] keys, String nameKey, float value) {
  JSONObject memory = jsonobj.getJSONObject(keys[0]);
  for(int i = 1; i < keys.length; i++) {memory = memory.getJSONObject(keys[i]);}
  memory.setFloat(nameKey, value);
}

// получение JSONObject из JSONObject по адресу
void set_jsonobj(JSONObject jsonobj, String[] keys, String nameKey, JSONObject value) {
  JSONObject memory = jsonobj.getJSONObject(keys[0]);
  for(int i = 1; i < keys.length; i++) {memory = memory.getJSONObject(keys[i]);}
  memory.setJSONObject(nameKey, value);
}

/*private void test(Runnable command) {
  command.run();
}*/

class consoleDis {
  //float x, y, sx, sy;
  
  float size = 16;
  
  ArrayList<String> fullConsole = new ArrayList<String>();
  
  ArrayList<Integer> displayConsoleTime = new ArrayList<Integer>();
  ArrayList<String> displayConsole = new ArrayList<String>();
  
  consoleDis() {
    
  }
  
  /*void set(float x, float y, float sx, float sy) {
    this.x=x; this.y=y; this.sx=sx; this.sy=sy;
  }*/
  
  void input(String text) {
    fullConsole.add(text);
    
    displayConsoleTime.add(400);
    displayConsole.add(text);
  }
  void input(int dest, String text) {
    fullConsole.add(text);
    
    displayConsoleTime.add(dest);
    displayConsole.add(text);
  }
  
  void draw() {
    // Отнимание времени и рендер
    for(int i = 0; i < displayConsoleTime.size(); i++) {
      // сначала рендер
      if(displayConsoleTime.get(i) < 63) { fill(255, 63 - (63-displayConsoleTime.get(i)));
      } else { fill(255, 63); }
      rect(0, i*(size+16), 15+(textWidth(displayConsole.get(i))), (size+16));
      if(displayConsoleTime.get(i) < 192/2) { fill(255, 192 - (192-(displayConsoleTime.get(i)*2)));
      } else { fill(255, 192); }
      textSize(size);
      textAlign(LEFT, CENTER);
      text(displayConsole.get(i), 10, ((size+16)/2)+(i*(size+16)));
      
      // а теперь уже обновление переменных
      displayConsoleTime.set(i, displayConsoleTime.get(i)-1);
      if(displayConsoleTime.get(i) <= 0) { // удаление сообщения
        displayConsoleTime.remove(i);
        displayConsole.remove(i);
      }
    }
  }
}
