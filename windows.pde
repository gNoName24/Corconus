windowsRender windowsRender = new windowsRender();
class windowsRender {
  ArrayList<window> winList = new ArrayList<window>();
  ArrayList<Integer> winLayer = new ArrayList<Integer>();
  
  int winActive = 0;
  
  void add(window win) {
    winList.add(win);
    winLayer.add(0, winList.size()-1);
  }
  
  Boolean winHold = false;
  int winHoldInt = 0;
  float mouseXreg, mouseYreg;
  float winXreg, winYreg;
  
  Boolean winHoldResize = false;
  int winHoldResizeInt = 0;
  
  void setActive(window win) {
    int index = winList.indexOf(win); // Находим индекс окна в списке winList
    if (index != -1) { // Если окно найдено
      winLayer.remove(index); // Удаляем текущий индекс из winLayer
      winLayer.add(0, index); // Добавляем его в начало
      winActive = index; // Устанавливаем активное окно
    }
  }
  
  void removeWindow(window win) {
    int index = winList.indexOf(win);
    if (index != -1) {
      winLayer.remove(index);
      winList.remove(index);
    }
  }
  
  void render() {
    
    for(int i = winList.size()-1; i >= 0; i--) {
      window win = winList.get(winLayer.get(i));
      if(win.show) {
        win.render();
      }
    }
    
    // MousePressed
    Boolean br = false;
    for(int i = 0; i < winList.size(); i++) {
      window win = winList.get(winLayer.get(i));
      if(win.show) {
        if(win.x < -win.w/2) { win.x = (int)-win.w/2; }
        if(win.x > disW-(win.w/2)) { win.x = (int)disW-(win.w/2); }
        if(win.y > disH-win.hbHeight) { win.y = (int)disH-win.hbHeight; }
        if(win.y < 0) { win.y = 0; }
        
        if(mousePressed &&
           !winHold &&
           !winHoldResize &&
           !br) {
          // Удерживание окна
          if(oldtap(win.x,win.y,win.w,win.hbHeight)) {
            winHold = true;
            winHoldInt = winLayer.get(i);
            mouseXreg = mouseX;
            mouseYreg = mouseY;
            winXreg = mouseX-win.x;
            winYreg = mouseY-win.y;
          } else
          // Изменение размера окна
          if(oldtap(win.x+win.w-16,win.y+win.h-16+win.hbHeight,32,32)) {
            winHoldResize = true;
            winHoldResizeInt = winLayer.get(i);
            mouseXreg = mouseX;
            mouseYreg = mouseY;
            winXreg = win.w;
            winYreg = win.h;
          }
        }
      }
    }
    
    // Удерживание окна
    if(mousePressed) {
      if(winHold) {
        window win = winList.get(winHoldInt);
        win.x = int((mouseXreg-winXreg)+(mouseX-mouseXreg));
        win.y = int((mouseYreg-winYreg)+(mouseY-mouseYreg));
        //fill(255);
        //rect(mouseXreg, mouseYreg, 5, 5);
      } else if(winHoldResize) { // Изменение размера окна
        window win = winList.get(winHoldResizeInt);
        win.w = int(winXreg+(mouseX-mouseXreg));
        win.h = int(winYreg+(mouseY-mouseYreg));
        if(win.w <= 128) { win.w = 128; }
        if(win.h <= 64) { win.h = 64; }
      }
    } else {
      winHold = false;
      winHoldResize = false;
    }
  }
  
  void mousePressed() {
    Boolean br = false;
    for(int i = 0; i < winList.size(); i++) {
      window win = winList.get(winLayer.get(i));
      if(win.show) {
        if(oldtap(win.x, win.y, win.w, win.h + win.hbHeight) && !br) {
          winActive = winLayer.get(i);
          winLayer.remove(i);
          winLayer.add(0, winActive);
          br = true;
        }
      }
    }
    for(int i = 0; i < winList.size(); i++) {
      window win = winList.get(winLayer.get(i));
      if(winActive == winLayer.get(i)) {
        win.mousePressed();
        //printlne("act", i, winLayer, win.hideButton, win.winName);
        if(win.hideButton) {
          if(oldtap((win.x+7)+(win.w-(win.hbHeight+7)), win.y+7, win.hbHeight-14, win.hbHeight-14)) {
            win.hide();
          }
        }
      }
    }
  }
}

// Window нужен для создания множеств отдельных функциональных окон на рабочей столе
class window {
  action act = new action() { void setup(){} void draw(){} void mousePressed(){} };
  glayer gl = new glayer(0,0,10,10);
  
  void setAction(action action) {
    act = action;
    act.setup();
  }
  
  glayer getgl() {
    return gl;
  }
  
  messageZone collapse = new messageZone(); // Свернуть окно
  
  Boolean debugMode = false;
  
  // Свойства
  int x, y;
  int w, h;
  String winName = "";
  Boolean movePossible = true;
  int defcol = 63;
  Boolean hideButton = true;
  Boolean show = true;
  
  // Свойства HighBar
  int hbHeight = 40;
  
  void show() {
    show = true;
  }
  void hide() {
    show = false;
  }
  
  window(int startX, int startY, int startW, int startH, String name) {
    x = startX; y = startY;
    w = startW; h = startH;
    winName = name;
    collapse.rectcolor = color(defcol);
    collapse.textSize = 16;
    collapse.text = "Свернуть";
  }
  
  void highBar() {
    stroke(0);
    cusButton(x, y, w, hbHeight);
    if(hideButton) {
      ncusButton((x+7)+(w-(hbHeight+7)), y+7, hbHeight-14, hbHeight-14, 16);
      collapse.zone((x+7)+(w-(hbHeight+7)), y+7, hbHeight-14, hbHeight-14);
    }
    int size = 20;
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(size);
    text(winName, x+8, y+(hbHeight/2)-2.5);
  }
  
  void render() {
    stroke(0);
    fill(defcol);
    rect(x,y+hbHeight,w,h);
    gl.setAll(x,y+hbHeight,w,h);
    gl.preup(mouseX,mouseY);
    gl.beginDraw();
    act.draw();
    gl.endDraw();
    gl.render();
    highBar();
    
    // Debug
    if(debugMode) {
      fill(0,255,0);
      textAlign(LEFT, TOP);
      textSize(16);
      String text = "x: "+x+" / y: "+y+"\n"+
                    "w: "+w+" / h: "+h+"\n"+
                    "gl.mouseX: "+gl.mouseX+" / gl.mouseY: "+gl.mouseY+"\n"+
                    "gl.moux: "+gl.moux+" / gl.mouy: "+gl.mouy+"\n";
      text(text, x, y);
      
      rect(x-3,y-3,6,6);
      rect((x+(w/2))-3,(y+((h+(hbHeight*2))/2))-3,6,6);
      
      text("windowsRender.winActive: "+windowsRender.winActive, mouseX, mouseY);
      
      if(mousePressed) {
        stroke(63,255,0);
        line(mouseX,mouseY,x+(w/2),y+((h+(hbHeight*2))/2));
        fill(255);
        text(str((int)leng((x+(w/2)-mouseX), (y+((h+(hbHeight*2))/2))-mouseY)),x+(w/2),y+((h+(hbHeight*2))/2));
      }
    }
  }
  
  void cusButton(float x, float y, float xs, float xy) {
    if(oldtap(x, y, xs, xy)) {
      if(!mousePressed) {
        fill(defcol+15);
      } else {
        fill(defcol+30);
      }
    } else {
      fill(defcol);
    }
    rect(x, y, xs, xy);
  }
  void ncusButton(float x, float y, float xs, float xy) {
    if(oldtap(x, y, xs, xy)) {
      if(!mousePressed) {
        fill(defcol+15);
      } else {
        fill(defcol+30);
      }
    }
    rect(x, y, xs, xy);
  }
  void ncusButton(float x, float y, float xs, float xy, float dop) {
    if(oldtap(x, y, xs, xy)) {
      if(!mousePressed) {
        fill(defcol+15+dop);
      } else {
        fill(defcol+30+dop);
      }
    }
    rect(x, y, xs, xy);
  }
  
  // Обработка нажатий
  void mousePressed() {
    gl.beginDraw();
    act.mousePressed();
    gl.endDraw();
  }
  abstract class actionMP { abstract void run(); }
}

abstract class action { abstract void setup(); abstract void draw(); abstract void mousePressed(); }

// GLayer создает отдельный PGraphics для рисования на нем со всеми необходимыми инструментами
class glayer {
  PGraphics pg;
  int wx, wy;
  float disW, disH, disW2, disH2;
  float mouseX, mouseY;
  float moux, mouy;
  glayer(int x, int y, int w, int h) {
    pg = createGraphics(w, h);
    wx = x; wy = y;
    disW = w; disH = h;
    disW2 = w/2; disH2 = h/2;
  }
  void setAll(int x, int y, int w, int h) {
    setPosition(x,y);
    setSize(w,h);
  }
  void setPosition(int x, int y) {
    wx = x; wy = y;
  }
  void setSize(int w, int h) {
    PImage temp = pg;
    if(disW != w || disH != h) {
      pg = createGraphics(w, h);
      pg.beginDraw();
      pg.image(temp, 0, 0, temp.width, temp.height);
      pg.endDraw();
      disW = w; disH = h;
      disW2 = w/2; disH2 = h/2;
    }
  }
  // Используйте до использования других функций
  void preup(float mouseX, float mouseY) {
    this.mouseX = mouseX-wx;
    this.mouseY = mouseY-wy;
    moux = this.mouseX-disW2; mouy = -this.mouseY+disH2;
  }
  void render() {
    image(pg, wx, wy, disW, disH);
  }
  
  void beginDraw() {
    pg.beginDraw();
  }
  void endDraw() {
    pg.endDraw();
  }
  
  void clear() { pg.clear(); }
  void background(float r, float g, float b) { pg.background(r,g,b); }
  void background(float r, float g, float b, float a) { pg.background(r,g,b,a); }
  void background(float r) { pg.background(r); }
  void noStroke() { pg.noStroke(); }
  void stroke(color col) { pg.stroke(col); }
  void fill(float r, float g, float b) { pg.fill(r,g,b); }
  void fill(float r, float g, float b, float a) { pg.fill(r,g,b,a); }
  void fill(float r) { pg.fill(r); }
  void rect(float x, float y, float w, float h) { pg.rect(x,y,w,h); }
  void sclip(float xPos, float yPos, float xSize, float ySize) {
    pg.pushMatrix();
    pg.clip(disW2 + xPos - xSize/2, disH2 - yPos - ySize/2, xSize, ySize);
    pg.popMatrix();
  }
  void srect(float xPos, float yPos, float xSize, float ySize) {
    pg.pushMatrix();
    pg.rect(disW2 + xPos, disH2 - yPos, xSize, ySize);
    pg.popMatrix();
  }
  void sblock(float xPos, float yPos, float xSize, float ySize) {
    pg.pushMatrix();
    pg.rect(disW2 + xPos - xSize/2, disH2 - yPos - ySize/2, xSize, ySize);
    pg.popMatrix();
  }
  void stext(String txt, float xPos, float yPos, float size) {
    pg.textAlign(CENTER, CENTER);
    pg.textSize(size);
    pg.text(txt, disW2 + xPos, disH2 - (yPos-2));
  }
  void stext(String txt, float xPos, float yPos, float size, float... args) {
    pg.textAlign(CENTER, CENTER);
    pg.textSize(size);
    String[] words = txt.split("\\s+"); // Разбиваем текст на слова по пробелам
    StringBuilder currentLine = new StringBuilder();
    float y = yPos;
    for (String word : words) {
      String testLine = currentLine + " " + word;
      float testWidth = pg.textWidth(testLine); // Ширина строки с добавлением текущего слова
      if (testWidth > args[0]) { // Если ширина строки превышает максимальную ширину
        pg.text(currentLine.toString(), disW2 + xPos, disH2 - (y+2.5));
        currentLine = new StringBuilder(word);
        if(args.length >= 2) { y -= size + args[1]; }
        else { y -= size; }
      } else {
        currentLine.append(" ").append(word);
      }
    }
    if (currentLine.length() > 0) { // Выводим оставшуюся часть текста
      pg.text(currentLine.toString(), disW2 + xPos, disH2 - (y+2.5));
    }
  }
  
  Boolean tap(float xPos, float yPos, float xSize, float ySize) {
    if (((moux>xPos-xSize/2)&&(moux<xPos+xSize/2))&&((mouy>yPos-ySize/2)&&(mouy<yPos+ySize/2))) { return true;
    } else { return false; }
  }
  Boolean oldtap(float xPos, float yPos, float xSize, float ySize) {
    if ((mouseX>xPos)&&(mouseX<xPos+xSize)&&(mouseY>yPos)&&(mouseY<yPos+ySize)) { return true;
    } else { return false; }
  }
}
