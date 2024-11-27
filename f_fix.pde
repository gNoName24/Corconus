// by Lavok, modified NoName24
// version 26.10.2024

// Контейнер
void sfclip(float disx, float xPos, float disy, float yPos, float xSize, float ySize) {
  clip(disW2 + (disx+(xPos/_fix)) - (xSize/_fix)/2, disH2 - (disy+(yPos/_fix)) - (ySize/_fix)/2, xSize/_fix, ySize/_fix);
}

// Прямоугольник
void sfblock(float disx, float xPos, float disy, float yPos, float xSize, float ySize) {
  pushMatrix();
  rect(disW2 + (disx+(xPos/_fix)) - (xSize/_fix)/2, disH2 - (disy+(yPos/_fix)) - (ySize/_fix)/2, xSize/_fix, ySize/_fix);
  popMatrix();
}
// Прямоугольник + поворот
void sfblock(float disx, float xPos, float disy, float yPos, float xSize, float ySize, float rotate) {
  pushMatrix();
  translate(disW2+(disx+(xPos/_fix)), disH2-(disy+(yPos/_fix)));
  rotate(rotate);
  sblock(-disW2, disH2, xSize/_fix, ySize/_fix);
  popMatrix();
}

// Прямоугольник с загругленными краями
void sfblockRound(float disx, float xPos, float disy, float yPos, float xSize, float ySize, float round) {
  pushMatrix();
  rect(disW2 + (disx+(xPos/_fix)) - (xSize/_fix)/2, disH2 - (disy+(yPos/_fix)) - (ySize/_fix)/2, xSize/_fix, ySize/_fix, round);
  popMatrix();
}

// установка блока с текстурой
void sfimage(PImage t, float disx, float xPos, float disy, float yPos, float xSize, float ySize) {
  pushMatrix();
  image(t, round(disW2 + (disx+(xPos/_fix)) - (xSize/_fix)/2), round(disH2 - (disy+(yPos/_fix)) - (ySize/_fix)/2), xSize/_fix, ySize/_fix);
  popMatrix();
}
void sfimage(PImage t, float disx, float xPos, float disy, float yPos, float xSize, float ySize, float rotate) {
  pushMatrix();
  translate(disW2+(disx+(xPos/_fix)), disH2-(disy+(yPos/_fix)));
  rotate(rotate);
  simage(t, -disW2, disH2, xSize/_fix, ySize/_fix);
  popMatrix();
}

// Кнопка
void sfbutton(float disx, float xPos, float disy, float yPos, float xSize, float ySize) {
  pushMatrix();
  if(mousePressed&&tapfix(disx,xPos,disy,yPos,xSize,ySize)) { fill( fillColor[0] );
  } else if(tapfix(disx,xPos,disy,yPos,xSize,ySize)) {        fill( fillColor[1] );
  } else {                                                    fill( fillColor[2] );
  }
  rect(disW2 + (disx+(xPos/_fix)) - (xSize/_fix)/2, disH2 - (disy+(yPos/_fix)) - (ySize/_fix)/2, xSize/_fix, ySize/_fix);
  popMatrix();
}

// Кнопка + свой цвет
void sfbutton(float disx, float xPos, float disy, float yPos, float xSize, float ySize, color color1, color color2, color color3) {
  pushMatrix();
  if(mousePressed&&tapfix(disx,xPos,disy,yPos,xSize,ySize)) { fill( color3 );
  } else if(tapfix(disx,xPos,disy,yPos,xSize,ySize)) {        fill( color2 );
  } else {                                                    fill( color1 );
  }
  rect(disW2 + (disx+(xPos/_fix)) - (xSize/_fix)/2, disH2 - (disy+(yPos/_fix)) - (ySize/_fix)/2, xSize/_fix, ySize/_fix);
  popMatrix();
}
// Кнопка + закругленные края
void sfbutton(float disx, float xPos, float disy, float yPos, float xSize, float ySize, float round) {
  pushMatrix();
  if(mousePressed&&tapfix(disx,xPos,disy,yPos,xSize,ySize)) { fill( fillColor[0] );
  } else if(tapfix(disx,xPos,disy,yPos,xSize,ySize)) {        fill( fillColor[1] );
  } else {                                                    fill( fillColor[2] );
  }
  rect(disW2 + (disx+(xPos/_fix)) - (xSize/_fix)/2, disH2 - (disy+(yPos/_fix)) - (ySize/_fix)/2, xSize/_fix, ySize/_fix, round/_fix);
  popMatrix();
}
// Кнопка + свой цвет + закругленные края
void sfbutton(float disx, float xPos, float disy, float yPos, float xSize, float ySize, color color1, color color2, color color3, float round) {
  pushMatrix();
  if(mousePressed&&tapfix(disx,xPos,disy,yPos,xSize,ySize)) { fill( color3 );
  } else if(tapfix(disx,xPos,disy,yPos,xSize,ySize)) {        fill( color2 );
  } else {                                                    fill( color1 );
  }
  rect(disW2 + (disx+(xPos/_fix)) - (xSize/_fix)/2, disH2 - (disy+(yPos/_fix)) - (ySize/_fix)/2, xSize/_fix, ySize/_fix, round/_fix);
  popMatrix();
}

// Текст
void sftext(String txt, float disx, float xPos, float disy, float yPos, float size) {
  textAlign(CENTER, CENTER);
  textSize(size/_fix);
  try {
    text(txt, disW2 + (disx+(xPos/_fix)), disH2 - ((disy+(yPos/_fix)) ));
  } catch(Exception e) {
    e.printStackTrace();
    textSize(20);
    text(e.getMessage(), disW2 + (disx+(xPos/_fix)), disH2 - ((disy+(yPos/_fix)) ));
  }
}
// Текст + ограничение по ширине +/ добавление к высоте между строк
void sftext(String txt, float disx, float xPos, float disy, float yPos, float size, float... args) {
  textAlign(CENTER, CENTER);
  textSize(size/_fix);
  String[] words = txt.split("\\s+"); // Разбиваем текст на слова по пробелам
  StringBuilder currentLine = new StringBuilder();
  float y = yPos;
  for (String word : words) {
    String testLine = currentLine + " " + word;
    float testWidth = textWidth(testLine); // Ширина строки с добавлением текущего слова
    if (testWidth > args[0]) { // Если ширина строки превышает максимальную ширину
      text(currentLine.toString(), disW2 + (disx+(xPos/_fix)), disH2 - ((disy+(y/_fix))+2.5 ));
      currentLine = new StringBuilder(word);
      if(args.length >= 2) { y -= size + args[1]; }
      else { y -= size; }
    } else {
      currentLine.append(" ").append(word);
    }
  }
  if (currentLine.length() > 0) { // Выводим оставшуюся часть текста
    text(currentLine.toString(), disW2 + (disx+(xPos/_fix)), disH2 - ((disy+(y/_fix))+2.5 ));
  }
}
// Текст + свои настройки выравнивания
void sftext(int a, int b, String txt, float disx, float xPos, float disy, float yPos, float size) {
  textAlign(a, b);
  textSize(size/_fix);
  text(txt, disW2 + (disx+(xPos/_fix)), disH2 - ((disy+(yPos/_fix))+2.5));
}
// Текст + свои настройки выравнивания + ограничение по ширине +/ добавление к высоте между строк
void sftext(int a, int b, String txt, float disx, float xPos, float disy, float yPos, float size, float... args) {
  textAlign(a, b);
  textSize(size/_fix);
  String[] words = txt.split("\\s+"); // Разбиваем текст на слова по пробелам
  StringBuilder currentLine = new StringBuilder();
  float y = yPos;
  for (String word : words) {
    String testLine = currentLine + " " + word;
    float testWidth = textWidth(testLine); // Ширина строки с добавлением текущего слова
    if (testWidth > args[0]) { // Если ширина строки превышает максимальную ширину
      text(currentLine.toString(), disW2 + (disx+(xPos/_fix)), disH2 - ((disy+(y/_fix))+2.5 ));
      currentLine = new StringBuilder(word);
      if(args.length >= 2) { y -= size + args[1]; }
      else { y -= size; }
    } else {
      currentLine.append(" ").append(word);
    }
  }
  if (currentLine.length() > 0) { // Выводим оставшуюся часть текста
    text(currentLine.toString(), disW2 + (disx+(xPos/_fix)), disH2 - ((disy+(y/_fix))+2.5 ));
  }
}

// установка текста со второй версией ограничения длинны
/* void stextfix_n_o2(String txt, float disx, float xPos, float disy, float yPos, float size, int maxSize) {
  String endtxt = "";
  for(int i = 0; i < txt.length(); i++) {
    if(textWidth(endtxt) > (maxSize/_fix)) {endtxt+="..";break;}
    endtxt+=txt.charAt(i);
  }
  textSize(size/_fix);
  text(endtxt, disW2 + (disx+(xPos/_fix)), disH2 - ((disy+(yPos/_fix))+2.5));
} */

// установка блока
/*void sboxfix(float disx, float xPos, float disy, float yPos, float zPos, float xSize, float ySize, float zSize) {
  pushMatrix();
  translate(disW2 + (disx+(xPos/_fix)) + (xSize/_fix)/2, disH2 - (disy+(yPos/_fix)) - (ySize/_fix)/2, zPos);
  box(xSize/_fix, ySize/_fix, zSize);
  popMatrix();
}*/
