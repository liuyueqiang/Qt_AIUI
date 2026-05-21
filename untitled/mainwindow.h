#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QLabel>
#include <QMouseEvent>

class ClickableLabel : public QLabel
{
    Q_OBJECT
public:
    explicit ClickableLabel(QWidget *parent = nullptr);
    void setNormalImage(const QString &path);
    void setHoverImage(const QString &path);

signals:
    void clicked();

protected:
    void mousePressEvent(QMouseEvent *event) override;
    void enterEvent(QEvent *event) override;
    void leaveEvent(QEvent *event) override;

private:
    QString normalImagePath;
    QString hoverImagePath;
};

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

protected:
    void resizeEvent(QResizeEvent *event) override;

private slots:
    void onJiankongClicked();
    void onShishiquxianClicked();
    void onShengchanbaobiaoClicked();
    void onCanshushezhiClicked();
    void onIoClicked();
    void onBaojingClicked();
    void onDaijiClicked();

private:
    void updateLayout();

    QString imagePath;
    double scale;

    // 图片元素
    QLabel *lblBackground;
    QLabel *lblGsmc;
    QLabel *lblSidebar;
    QLabel *lblJx;
    QLabel *lblXiaobaikuang1;
    QLabel *lblYunxingzhuangtai;
    QLabel *lblDangqianzhuangtai;
    QLabel *lblXiaobaikuang2;
    QLabel *lblYunxingshuju;
    QLabel *lblJiechuweizhi;

    // 按钮元素
    ClickableLabel *btnJiankong;
    ClickableLabel *btnShishiquxian;
    ClickableLabel *btnShengchanbaobiao;
    ClickableLabel *btnCanshushezhi;
    ClickableLabel *btnIo;
    ClickableLabel *btnBaojing;
    ClickableLabel *btnDaiji;
};

#endif // MAINWINDOW_H
