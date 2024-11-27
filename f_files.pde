// by Lavok, modified NoName24
// version 26.10.2024

// загрузка всех строк из файла
String loadString(String path) {
  String string = "";
  String[] file = loadStrings(path);
  for (String line : file) {string+=line+"\n";} // превращение множество строк в одну строку
  return string;
}

// проверка присутствия папки
boolean checkFolder(String path) {
  File folder = new File(path);
  return folder.exists() && folder.isDirectory();
}

// проверка присутствия файла
boolean checkFile(String path) {
  File file = new File(path);
  return file.exists() && file.isFile();
}

boolean createFolders(String path) {
  try {
    Path dirPath = Paths.get(sketchPath(path));
    Files.createDirectories(dirPath);
    return Files.exists(dirPath);
  } catch (IOException e) {
    e.printStackTrace();
    return false;
  }
}

void copyFile(String sourcePath, String destinationPath) {
  Path source = Paths.get(sourcePath);
  Path destination = Paths.get(destinationPath);
  try {
    // Создаем все папки, если их еще нет
    if (destination.getParent() != null) { Files.createDirectories(destination.getParent()); }
    Files.copy(source, destination, StandardCopyOption.REPLACE_EXISTING);
  } catch (IOException e) {
    e.printStackTrace();
  }
}

void deleteFolder(String path) {
  File folder = new File(path);
  if (folder.exists()) {
    File[] files = folder.listFiles();
    if (files != null) {
      for (File file : files) {
        if (file.isDirectory()) {
          deleteFolder(file.getAbsolutePath()); // рекурсивно удаляем вложенные папки
        } else {
          file.delete(); // удаляем файл
        }
      }
    }
    folder.delete(); // удаляем пустую папку
  }
}

String[] getFolderNames(String path) {
  Path folderPath = Paths.get(path);
  
  if (Files.isDirectory(folderPath)) {
    try (DirectoryStream<Path> stream = Files.newDirectoryStream(folderPath)) {
      List<String> folderNames = new ArrayList<>();
      for (Path entry : stream) {
        if (Files.isDirectory(entry)) {
          folderNames.add(entry.getFileName().toString());
        }
      }
      return folderNames.toArray(new String[0]);
    } catch (IOException e) {
      e.printStackTrace(); // Выводим информацию об ошибке
      return new String[0];
    }
  } else {
    return new String[0];
  }
}

String[] getFileNames(String path) {
  Path folderPath = Paths.get(path);
  
  if (Files.isDirectory(folderPath)) {
    try (DirectoryStream<Path> stream = Files.newDirectoryStream(folderPath)) {
      List<String> fileNames = new ArrayList<>();
      for (Path entry : stream) {
        if (Files.isRegularFile(entry)) {
          fileNames.add(entry.getFileName().toString());
        }
      }
      return fileNames.toArray(new String[0]);
    } catch (IOException e) {
      e.printStackTrace(); // Выводим информацию об ошибке
      return new String[0];
    }
  } else {
    return new String[0];
  }
}

// Получение списка файлов которые начинаются на заданный префикс
String[] getFileNames(String path, String prefix) {
  Path folderPath = Paths.get(path);
  
  if (Files.isDirectory(folderPath)) {
    try (DirectoryStream<Path> stream = Files.newDirectoryStream(folderPath)) {
      List<String> fileNames = new ArrayList<>();
      for (Path entry : stream) {
        if (Files.isRegularFile(entry) && entry.getFileName().toString().startsWith(prefix)) {
          fileNames.add(entry.getFileName().toString());
        }
      }
      return fileNames.toArray(new String[0]);
    } catch (IOException e) {
      e.printStackTrace(); // Выводим информацию об ошибке
      return new String[0];
    }
  } else {
    return new String[0];
  }
}


long fileLength(String path) {
  File file = new File(path);
  return file.length();
}
