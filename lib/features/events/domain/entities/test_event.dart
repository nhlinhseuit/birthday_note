class TestEvent {
  List<int>? a;

  TestEvent() {
    a = List.generate(1000000, (index) => index);
  }

  dispose() {
    a?.clear();
    a = null;
  }
}
