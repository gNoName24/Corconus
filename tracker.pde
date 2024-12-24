import java.lang.reflect.Method;

class FunctionTracker {
  HashMap<String, Integer> callCount;

  FunctionTracker() {
    callCount = new HashMap<String, Integer>();
  }

  void trackCall(Object obj, String methodName, Object... args) {
    try {
      if (!callCount.containsKey(methodName)) {
        callCount.put(methodName, 0);
      }
      callCount.put(methodName, callCount.get(methodName) + 1);

      // Используем Reflection для вызова метода
      Method method = obj.getClass().getMethod(methodName, getArgClasses(args));
      method.invoke(obj, args);

    } catch (Exception e) {
      println("Error calling method: " + methodName + " - " + e);
    }
  }

  Class[] getArgClasses(Object... args) {
    Class[] classes = new Class[args.length];
    for (int i = 0; i < args.length; i++) {
      classes[i] = args[i].getClass();
    }
    return classes;
  }

  void printCallCount() {
    for (String method : callCount.keySet()) {
      println(method + " called " + callCount.get(method) + " times");
    }
  }
}
