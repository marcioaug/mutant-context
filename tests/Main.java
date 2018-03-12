import Class1;

public class Main {
    public static void main(String[] args) {
        System.out.println("Hello Worl.ld!");
        Class1 class1 = new Class1();
    }

    public int initialize() {
        Test test = new Test();
        return test.method();
    }

    private class Test {
        public int method() {
            return 1;
        }
    }
}