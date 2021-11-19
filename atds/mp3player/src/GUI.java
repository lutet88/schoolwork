import io.qt.widgets.*;

public class GUI {
    public static void testApp(String[] args) {
        QApplication.initialize(args);
        var mw = new QMainWindow();
        var s = new QLabel("test");
        mw.setCentralWidget(s);
    }
}
