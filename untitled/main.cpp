#include "mainwindow.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    // 启用高DPI缩放支持
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    QApplication a(argc, argv);
    MainWindow w;
    w.show();
    return a.exec();
}
