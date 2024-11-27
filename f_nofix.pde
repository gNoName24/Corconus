// by Lavok, modified NoName24
// version 26.10.2024

// Контейнер
void sclip(float xPos, float yPos, float xSize, float ySize) {
  pushMatrix();
  clip(disW2 + xPos - xSize/2, disH2 - yPos - ySize/2, xSize, ySize);
  popMatrix();
}

// Rect (отличительная особенность в том, что он рендерится от центра к нижнему правому углу)
void srect(float xPos, float yPos, float xSize, float ySize) {
  pushMatrix();
  rect(disW2 + xPos, disH2 - yPos, xSize, ySize);
  popMatrix();
}

// Прямоугольник
void sblock(float xPos, float yPos, float xSize, float ySize) {
  pushMatrix();
  rect(disW2 + xPos - xSize/2, disH2 - yPos - ySize/2, xSize, ySize);
  popMatrix();
}
// Прямоугольник + поворот
void sblock(float xPos, float yPos, float xSize, float ySize, float rotate) {
  pushMatrix();
  translate (disW2+xPos, disH2-yPos);
  rotate(rotate);
  sblock(-disW2, disH2, xSize, ySize);
  popMatrix();
}
// Прямоугольник с загругленными краями
void sblockRound(float xPos, float yPos, float xSize, float ySize, float k) {
  pushMatrix();
  rect(disW2 + xPos - xSize/2, disH2 - yPos - ySize/2, xSize, ySize, k);
  popMatrix();
}

void simage(PImage fImage, float xPos, float yPos, float xSize, float ySize) {
  pushMatrix();
  image(fImage, disW2 + xPos - xSize/2, disH2 - yPos - ySize/2, xSize, ySize);
  popMatrix();
}
void simage(PImage fImage, float xPos, float yPos, float xSize, float ySize, float rotate) {
  pushMatrix();
  translate (disW2+xPos, disH2-yPos);
  rotate(rotate);
  simage(fImage, -disW2, disH2, xSize, ySize);
  popMatrix();
}

// Кнопка
void sbutton(float xPos, float yPos, float xSize, float ySize) {
  if(mousePressed&&tap(xPos,yPos,xSize,ySize)) { fill( fillColor[0] );
  } else if(tap(xPos,yPos,xSize,ySize)) {        fill( fillColor[1] );
  } else {                                       fill( fillColor[2] );
  }
  rect(disW2 + xPos - xSize/2, disH2 - yPos - ySize/2, xSize, ySize);
}
// Кнопка + свой цвет
void sbutton(float xPos, float yPos, float xSize, float ySize, color color1, color color2, color color3) {
  if(mousePressed&&tap(xPos,yPos,xSize,ySize)) { fill(color3);
  } else if(tap(xPos,yPos,xSize,ySize)) {        fill(color2);
  } else {                                       fill(color1);
  }
  rect(disW2 + xPos - xSize/2, disH2 - yPos - ySize/2, xSize, ySize);
}

// Текст
void stext(String txt, float xPos, float yPos, float size) {
  textAlign(CENTER, CENTER);
  textSize(size);
  text(txt, disW2 + xPos, disH2 - (yPos+2.5));
}
// Текст + ограничение по ширине +/ добавление к высоте между строк
void stext(String txt, float xPos, float yPos, float size, float... args) {
  textAlign(CENTER, CENTER);
  textSize(size);
  String[] words = txt.split("\\s+"); // Разбиваем текст на слова по пробелам
  StringBuilder currentLine = new StringBuilder();
  float y = yPos;
  for (String word : words) {
    String testLine = currentLine + " " + word;
    float testWidth = textWidth(testLine); // Ширина строки с добавлением текущего слова
    if (testWidth > args[0]) { // Если ширина строки превышает максимальную ширину
      text(currentLine.toString(), disW2 + xPos, disH2 - (y+2.5));
      currentLine = new StringBuilder(word);
      if(args.length >= 2) { y -= size + args[1]; }
      else { y -= size; }
    } else {
      currentLine.append(" ").append(word);
    }
  }
  if (currentLine.length() > 0) { // Выводим оставшуюся часть текста
    text(currentLine.toString(), disW2 + xPos, disH2 - (y+2.5));
  }
}
// Текст + свои настройки выравнивания
void stext(int a, int b, String txt, float xPos, float yPos, float size) {
  textAlign(a, b);
  textSize(size);
  text(txt, disW2 + xPos, disH2 - (yPos+2.5));
}
// Текст + свои настройки выравнивания + ограничение по ширине +/ добавление к высоте между строк
void stext(int a, int b, String txt, float xPos, float yPos, float size, float... args) {
  textAlign(a, b);
  textSize(size);
  String[] words = txt.split("\\s+"); // Разбиваем текст на слова по пробелам
  StringBuilder currentLine = new StringBuilder();
  float y = yPos;
  for (String word : words) {
    String testLine = currentLine + " " + word;
    float testWidth = textWidth(testLine); // Ширина строки с добавлением текущего слова
    if (testWidth > args[0]) { // Если ширина строки превышает максимальную ширину
      text(currentLine.toString(), disW2 + xPos, disH2 - (y+2.5));
      currentLine = new StringBuilder(word);
      if(args.length >= 2) { y -= size + args[1]; }
      else { y -= size; }
    } else {
      currentLine.append(" ").append(word);
    }
  }
  if (currentLine.length() > 0) { // Выводим оставшуюся часть текста
    text(currentLine.toString(), disW2 + xPos, disH2 - (y+2.5));
  }
}

// Линия
void sline(float xPos, float yPos, float xPos2, float yPos2) {
  line(disW2 + xPos, disH2 - yPos, disW2 + xPos2, disH2 - yPos2);
}

// Овал
void seps(float xPos, float yPos, float xSize, float ySize) {
  ellipse(disW2 + xPos, disH2 - yPos, xSize, ySize);
}
// Овал + поворот
void seps(float xPos, float yPos, float xSize, float ySize, float Rotate) {
  pushMatrix();
  translate (disW2+xPos, disH2-yPos);
  rotate(Rotate);
  seps(-disW2, disH2, xSize, ySize);
  popMatrix();
}


// создание текста без выравнивания и с 
/* void stext_n_o(String txt, float xPos, float yPos, float size, int n) {
  int nnew = n-1;String endtxt = "";
  for(int i = 0; i < txt.length(); i++) {
    if(i > nnew) {endtxt+="\n";nnew+=n;}
    endtxt+=txt.charAt(i);
  }
  textSize(size);
  text(endtxt, disW2 + xPos, disH2 - (yPos+2.5));
} */
