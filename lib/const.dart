class Const {
  static final Const _instance = Const._internal();

  factory Const() {
    return _instance;
  }

  Const._internal();

  String appName = 'Nitya Seva - ISKCON VK Hill';
  String appNameShort = 'Nitya Seva';
}
