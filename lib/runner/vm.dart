part of arrow_runner;

const int arrowStackTraceLimit = 50;
const int arrowStackOverflowLimit = 500;

final rng = Random();

class ArrowStackTraceElement {
  String name;
  String file;
  int line;

  ArrowStackTraceElement(this.name, this.file, this.line);

  @override
  String toString() {
    return "$name in \"$file\" at line ${line + 1}";
  }
}

class ArrowStackTrace {
  final List<ArrowStackTraceElement> stack = [];

  ArrowVM vm;

  ArrowStackTrace(this.vm);

  void push(ArrowStackTraceElement element) {
    stack.add(element);
    if (stack.length > arrowStackOverflowLimit) {
      final error = ArrowStackTraceElement("Stack Trace Limit Exceeded (Depth is ${stack.length})", "arrow:internal", 0);
      stack.add(error);
      throw error;
    }
  }

  void pop() {
    stack.removeLast();
  }

  void crash(ArrowStackTraceElement error) {
    push(error);
    throw error;
  }

  void show() {
    print(render());
  }

  String render() {
    var lowest = stack.length - arrowStackTraceLimit;
    if (lowest < 0) lowest = 0;

    final l = <String>[];

    for (var i = stack.length - 1; i >= lowest; i--) {
      l.add("${i + 1}. ${stack[i]}");
    }

    return l.join("\n");
  }
}

typedef ArrowLibMap = Map<String, ArrowResource>;
typedef ArrowLibrary = void Function(ArrowLibMap toModify);

/// The VM
class ArrowLibs {
  ArrowVM vm;
  Map<String, ArrowLibrary> map = {};
  ArrowLibs(this.vm) {
    init();
  }

  void addLib(String lib, ArrowLibrary func) {
    map[lib] = func;
  }

  void init() {
    addLib("terminal", loadTerminal);
    addLib("internal", loadInternal);
  }

  void load(List<String> libs) {
    for (var lib in libs) {
      if (map[lib] != null) {
        map[lib]!(vm.globals._globals);
      }
    }
  }

  void loadMath(ArrowLibMap map) {
    final math = <String, ArrowResource>{};

    math["sin"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        params = [ArrowNull()];
      }
      final n = params.first;

      if (n is ArrowNumber) {
        return ArrowNumber(sin(n.number));
      }

      return ArrowNull();
    }));

    math["cos"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        params = [ArrowNull()];
      }
      final n = params.first;

      if (n is ArrowNumber) {
        return ArrowNumber(cos(n.number));
      }

      return ArrowNull();
    }));

    math["tan"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        params = [ArrowNull()];
      }
      final n = params.first;

      if (n is ArrowNumber) {
        return ArrowNumber(tan(n.number));
      }

      return ArrowNull();
    }));

    math["asin"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        params = [ArrowNull()];
      }
      final n = params.first;

      if (n is ArrowNumber) {
        return ArrowNumber(asin(n.number));
      }

      return ArrowNull();
    }));

    math["floor"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        params = [ArrowNull()];
      }
      final n = params.first;

      if (n is ArrowNumber) {
        return ArrowNumber(n.number.toInt().toDouble());
      }

      return ArrowNull();
    }));

    math["maxfloat"] = ArrowNumber(double.maxFinite);

    math["maxint"] = ArrowNumber(9223372036854775807);

    math["pi"] = ArrowNumber(pi);
    math["e"] = ArrowNumber(e);

    math["abs"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        params = [ArrowNull()];
      }
      final n = params.first;

      if (n is ArrowNumber) {
        return ArrowNumber(n.number.abs());
      }

      return ArrowNull();
    }));

    math["atan2"] = ArrowExternalFunction(((params, stackTrace) {
      while (params.length < 2) {
        params = [...params, ArrowNumber(0)];
      }

      if ((params[0] is ArrowNumber) && (params[1] is ArrowNumber)) {
        return ArrowNumber(atan2((params[0] as ArrowNumber).number, (params[1] as ArrowNumber).number));
      }

      return ArrowNull();
    }));

    math["exp"] = ArrowExternalFunction(((params, stackTrace) {
      while (params.isEmpty) {
        params = [...params, ArrowNumber(0)];
      }

      if ((params[0] is ArrowNumber)) {
        return ArrowNumber(exp((params[0] as ArrowNumber).number));
      }

      return ArrowNull();
    }));

    math["atan2"] = ArrowExternalFunction(((params, stackTrace) {
      while (params.length < 2) {
        params = [...params, ArrowNumber(0)];
      }

      if ((params[0] is ArrowNumber) && (params[1] is ArrowNumber)) {
        return ArrowNumber(atan2((params[0] as ArrowNumber).number, (params[1] as ArrowNumber).number));
      }

      return ArrowNull();
    }));

    math["atan"] = ArrowExternalFunction(((params, stackTrace) {
      while (params.isEmpty) {
        params = [...params, ArrowNumber(0)];
      }

      if ((params[0] is ArrowNumber)) {
        return ArrowNumber(atan((params[0] as ArrowNumber).number));
      }

      return ArrowNull();
    }));

    math["ceil"] = ArrowExternalFunction(((params, stackTrace) {
      while (params.isEmpty) {
        params = [...params, ArrowNumber(0)];
      }

      if ((params[0] is ArrowNumber)) {
        return ArrowNumber(((params[0] as ArrowNumber).number).ceil());
      }

      return ArrowNull();
    }));

    math["sqrt"] = ArrowExternalFunction(((params, stackTrace) {
      while (params.isEmpty) {
        params = [...params, ArrowNumber(0)];
      }

      if ((params[0] is ArrowNumber)) {
        return ArrowNumber(sqrt((params[0] as ArrowNumber).number));
      }

      return ArrowNull();
    }));

    math["log"] = ArrowExternalFunction(((params, stackTrace) {
      while (params.isEmpty) {
        params = [...params, ArrowNumber(0)];
      }

      if ((params[0] is ArrowNumber)) {
        return ArrowNumber(log((params[0] as ArrowNumber).number));
      }

      return ArrowNull();
    }));

    math["min"] = ArrowExternalFunction(((params, stackTrace) {
      var number = double.infinity;

      for (var param in params) {
        if (param is ArrowNumber) {
          if (param.number < number) {
            number = param.number;
          }
        }
      }

      return ArrowNumber(number);
    }));

    math["max"] = ArrowExternalFunction(((params, stackTrace) {
      var number = double.negativeInfinity;

      for (var param in params) {
        if (param is ArrowNumber) {
          if (param.number > number) {
            number = param.number;
          }
        }
      }

      return ArrowNumber(number);
    }));

    math["sinh"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        params = [ArrowNull()];
      }
      final n = params.first;

      if (n is ArrowNumber) {
        final num = n.number;
        return ArrowNumber((pow(e, num) - pow(e, -num)) / 2);
      }

      return ArrowNull();
    }));

    math["cosh"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        params = [ArrowNull()];
      }
      final n = params.first;

      if (n is ArrowNumber) {
        final num = n.number;
        return ArrowNumber((pow(e, num) + pow(e, -num)) / 2);
      }

      return ArrowNull();
    }));

    math["tanh"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        params = [ArrowNull()];
      }
      final n = params.first;

      if (n is ArrowNumber) {
        final num = n.number;
        return ArrowNumber((pow(e, num) - pow(e, -num)) / (pow(e, num) + pow(e, -num)));
      }

      return ArrowNull();
    }));

    math["random"] = ArrowExternalFunction(((params, stackTrace) {
      return ArrowNumber(rng.nextDouble());
    }));

    map["math"] = ArrowMap(math);
  }

  void loadInternal(ArrowLibMap map) {
    map["import"] = ArrowExternalFunction((params, stackTrace) {
      if (params.isEmpty) {
        stackTrace.crash(ArrowStackTraceElement("Invalid path specified to import()", "arrow:internal", 0));
        return ArrowNull();
      }
      if (params[0] is ArrowString) {
        final file = File(params[0].string);
        if (!file.existsSync()) {
          stackTrace.crash(ArrowStackTraceElement("File at \"${params[0].string}\" does not exist", "arrow:internal", 0));
          return ArrowNull();
        }
        return vm.runFile(file);
      } else {
        stackTrace.crash(ArrowStackTraceElement("Invalid path specified to import()", "arrow:internal", 0));
        return ArrowNull();
      }
    });

    map["eval"] = ArrowExternalFunction((params, stackTrace) {
      final p = params.isEmpty ? ArrowNull() : params[0];

      return vm.run(p.string, "arrow:eval(${p.string})");
    });

    map["crash"] = ArrowExternalFunction((params, stackTrace) {
      if (params.isEmpty) {
        stackTrace.crash(ArrowStackTraceElement("null", "arrow:internal", 0));
      } else {
        stackTrace.crash(ArrowStackTraceElement(params.map((p) => p.string).join(" "), "arrow:internal", 0));
      }

      return ArrowNull();
    });

    map["size"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        params = [ArrowNull()];
      }

      final value = params.first;

      if (value is ArrowString) {
        return ArrowNumber(value.str.length.toDouble());
      }
      if (value is ArrowBool) {
        return ArrowNumber(1);
      }
      if (value is ArrowNumber) {
        return ArrowNumber(value.number.toString().length.toDouble());
      }
      if (value is ArrowFunction) {
        return ArrowNumber(value.params.length.toDouble());
      }
      if (value is ArrowExternalFunction) {
        return ArrowNumber(0);
      }
      if (value is ArrowMap) {
        return ArrowNumber(value.map.length.toDouble());
      }
      if (value is ArrowList) {
        return ArrowNumber(value.elements.length.toDouble());
      }

      return ArrowNumber(0);
    }));
  }

  void loadTerminal(ArrowLibMap map) {
    map["print"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        print("null");
      } else {
        print(params.map((p) => p.string).join(" "));
      }

      return ArrowNull();
    }));

    map["write"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        stdout.write("null");
      } else {
        stdout.write(params.map((p) => p.string).join(" "));
      }

      return ArrowNull();
    }));

    map["read"] = ArrowExternalFunction(((params, stackTrace) {
      if (params.isEmpty) {
        return ArrowString(stdin.readLineSync() ?? "");
      } else {
        stdout.write(params.map((p) => p.string).join(" "));
        return ArrowString(stdin.readLineSync() ?? "");
      }
    }));
  }
}

class ArrowVM {
  final globals = ArrowGlobals();
  final exports = ArrowGlobals();
  final locals = ArrowLocals();

  late ArrowStackTrace stackTrace;
  late ArrowParser parser;
  late ArrowLibs libs;

  ArrowVM() {
    stackTrace = ArrowStackTrace(this);
    parser = ArrowParser(this);
    libs = ArrowLibs(this);
  }

  /// Runs some code from a string. Returns what the code returned.
  ArrowResource run(String code, String fileName) {
    final codeSegs = parser.splitCode(code, fileName, 0);

    final codeTokens = codeSegs.map((e) => parser.parseSegments(parser.splitLine(e.content, e.file, e.line), true));

    for (var token in codeTokens) {
      if (locals.has("")) break;
      token.run(locals, globals, stackTrace);
    }

    return locals.getByName("") ?? ArrowNull();
  }

  ArrowResource runFile(File file) {
    return run(file.readAsStringSync(), file.path);
  }

  void loadLibs([List<String> libs = const ["terminal", "fs", "math", "internal"]]) {
    this.libs.load(libs);
  }
}
