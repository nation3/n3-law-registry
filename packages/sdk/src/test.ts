abstract class A {
  abstract something(): string;
  abstract something2(): string;

  static isCool(value: any) {
    return true;
  }
}

abstract class B extends A {
  something2() {
    return "2";
  }
}

class C extends B {
  something() {
    return "1";
  }
}

type X = typeof C;

let c: X = new C();
c.something2();
