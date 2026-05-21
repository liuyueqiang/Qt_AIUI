#include "mainwindow.h"
#include <QCoreApplication>
#include <QDebug>
#include <QResizeEvent>

// ClickableLabel 实现
ClickableLabel::ClickableLabel(QWidget *parent)
    : QLabel(parent)
{
    setCursor(Qt::PointingHandCursor);
}

void ClickableLabel::setNormalImage(const QString &path)
{
    normalImagePath = path;
    setPixmap(QPixmap(path));
}

void ClickableLabel::setHoverImage(const QString &path)
{
    hoverImagePath = path;
}

void ClickableLabel::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton) {
        emit clicked();
    }
    QLabel::mousePressEvent(event);
}

void ClickableLabel::enterEvent(QEvent *event)
{
    if (!hoverImagePath.isEmpty()) {
        setPixmap(QPixmap(hoverImagePath));
    }
    QLabel::enterEvent(event);
}

void ClickableLabel::leaveEvent(QEvent *event)
{
    if (!normalImagePath.isEmpty()) {
        setPixmap(QPixmap(normalImagePath));
    }
    QLabel::leaveEvent(event);
}

// MainWindow 实现
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , scale(1.0)
{
    // 设置窗口初始大小（可调整）
    resize(1024, 768);
    setWindowTitle("能源电厂机器人巡检系统");

    // 图片路径（图片直接在exe同目录下）
    imagePath = QCoreApplication::applicationDirPath() + "/";

    // 1. 背景图
    lblBackground = new QLabel(this);
    lblBackground->setGeometry(0, 0, 1024, 768);
    lblBackground->setPixmap(QPixmap(imagePath + "bg.png"));
    lblBackground->setScaledContents(true);

    // 2. 公司名称logo
    lblGsmc = new QLabel(this);
    lblGsmc->setGeometry(10, 15, 160, 50);
    lblGsmc->setPixmap(QPixmap(imagePath + "gsmc.png"));
    lblGsmc->setScaledContents(true);

    // 3. 侧边栏
    lblSidebar = new QLabel(this);
    lblSidebar->setGeometry(17, 79, 122, 675);
    lblSidebar->setPixmap(QPixmap(imagePath + "sidebar.png"));
    lblSidebar->setScaledContents(true);

    // 4. 主面板
    lblJx = new QLabel(this);
    lblJx->setGeometry(156, 86, 846, 675);
    lblJx->setPixmap(QPixmap(imagePath + "jx.png"));
    lblJx->setScaledContents(true);

    // 5. 监控按钮
    btnJiankong = new ClickableLabel(this);
    btnJiankong->setGeometry(28, 106, 105, 90);
    btnJiankong->setNormalImage(imagePath + "btn_jiankong.png");
    btnJiankong->setHoverImage(imagePath + "btn_jiankong1.png");
    btnJiankong->setScaledContents(true);
    connect(btnJiankong, &ClickableLabel::clicked, this, &MainWindow::onJiankongClicked);

    // 5. 实时曲线按钮
    btnShishiquxian = new ClickableLabel(this);
    btnShishiquxian->setGeometry(28, 215, 105, 90);
    btnShishiquxian->setNormalImage(imagePath + "btn_shishiquxian.png");
    btnShishiquxian->setHoverImage(imagePath + "btn_shishiquxian1.png");
    btnShishiquxian->setScaledContents(true);
    connect(btnShishiquxian, &ClickableLabel::clicked, this, &MainWindow::onShishiquxianClicked);

    // 6. 生产报表按钮
    btnShengchanbaobiao = new ClickableLabel(this);
    btnShengchanbaobiao->setGeometry(28, 324, 105, 90);
    btnShengchanbaobiao->setNormalImage(imagePath + "btn_shengchanbaobiao.png");
    btnShengchanbaobiao->setHoverImage(imagePath + "btn_shengchanbaobiao1.png");
    btnShengchanbaobiao->setScaledContents(true);
    connect(btnShengchanbaobiao, &ClickableLabel::clicked, this, &MainWindow::onShengchanbaobiaoClicked);

    // 7. 参数设置按钮（注意文件名不一致：zhe vs zhi）
    btnCanshushezhi = new ClickableLabel(this);
    btnCanshushezhi->setGeometry(28, 432, 105, 90);
    btnCanshushezhi->setNormalImage(imagePath + "btn_chanshushezhi.png");
    btnCanshushezhi->setHoverImage(imagePath + "btn_chanshushezhi1.png");
    btnCanshushezhi->setScaledContents(true);
    connect(btnCanshushezhi, &ClickableLabel::clicked, this, &MainWindow::onCanshushezhiClicked);

    // 8. IO按钮
    btnIo = new ClickableLabel(this);
    btnIo->setGeometry(28, 541, 105, 90);
    btnIo->setNormalImage(imagePath + "btn_io.png");
    btnIo->setHoverImage(imagePath + "btn_io1.png");
    btnIo->setScaledContents(true);
    connect(btnIo, &ClickableLabel::clicked, this, &MainWindow::onIoClicked);

    // 9. 报警按钮
    btnBaojing = new ClickableLabel(this);
    btnBaojing->setGeometry(28, 650, 105, 90);
    btnBaojing->setNormalImage(imagePath + "btn_baojing.png");
    btnBaojing->setHoverImage(imagePath + "btn_baojing1.png");
    btnBaojing->setScaledContents(true);
    connect(btnBaojing, &ClickableLabel::clicked, this, &MainWindow::onBaojingClicked);

    // 10. 小白框1
    lblXiaobaikuang1 = new QLabel(this);
    lblXiaobaikuang1->setGeometry(179, 95, 387, 320);
    lblXiaobaikuang1->setPixmap(QPixmap(imagePath + "xiaobaikuang.png"));
    lblXiaobaikuang1->setScaledContents(true);

    // 11. 运行状态标签
    lblYunxingzhuangtai = new QLabel(this);
    lblYunxingzhuangtai->setGeometry(179, 95, 112, 39);
    lblYunxingzhuangtai->setPixmap(QPixmap(imagePath + "label_yunxingzhuangtai.png"));
    lblYunxingzhuangtai->setScaledContents(true);

    // 12. 当前状态标签
    lblDangqianzhuangtai = new QLabel(this);
    lblDangqianzhuangtai->setGeometry(217, 172, 80, 28);
    lblDangqianzhuangtai->setPixmap(QPixmap(imagePath + "dangqianzhuangtai.png"));
    lblDangqianzhuangtai->setScaledContents(true);

    // 13. 待机按钮
    btnDaiji = new ClickableLabel(this);
    btnDaiji->setGeometry(316, 169, 106, 34);
    btnDaiji->setNormalImage(imagePath + "btn_daiji.png");
    btnDaiji->setScaledContents(true);
    connect(btnDaiji, &ClickableLabel::clicked, this, &MainWindow::onDaijiClicked);

    // 14. 小白框2
    lblXiaobaikuang2 = new QLabel(this);
    lblXiaobaikuang2->setGeometry(585, 95, 387, 320);
    lblXiaobaikuang2->setPixmap(QPixmap(imagePath + "xiaobaikuang.png"));
    lblXiaobaikuang2->setScaledContents(true);

    // 15. 运行数据标签
    lblYunxingshuju = new QLabel(this);
    lblYunxingshuju->setGeometry(589, 95, 112, 39);
    lblYunxingshuju->setPixmap(QPixmap(imagePath + "label_yunxingshuju.png"));
    lblYunxingshuju->setScaledContents(true);

    // 16. 接触位置标签
    lblJiechuweizhi = new QLabel(this);
    lblJiechuweizhi->setGeometry(645, 155, 80, 28);
    lblJiechuweizhi->setPixmap(QPixmap(imagePath + "label_jiechuweizhi.png"));
    lblJiechuweizhi->setScaledContents(true);
}

MainWindow::~MainWindow()
{
}

// 按钮点击事件槽函数
void MainWindow::onJiankongClicked()
{
    qDebug() << "监控按钮被点击";
    // TODO: 切换到监控页面
}

void MainWindow::onShishiquxianClicked()
{
    qDebug() << "实时曲线按钮被点击";
    // TODO: 切换到实时曲线页面
}

void MainWindow::onShengchanbaobiaoClicked()
{
    qDebug() << "生产报表按钮被点击";
    // TODO: 切换到生产报表页面
}

void MainWindow::onCanshushezhiClicked()
{
    qDebug() << "参数设置按钮被点击";
    // TODO: 切换到参数设置页面
}

void MainWindow::onIoClicked()
{
    qDebug() << "IO按钮被点击";
    // TODO: 切换到IO控制页面
}

void MainWindow::onBaojingClicked()
{
    qDebug() << "报警按钮被点击";
    // TODO: 切换到报警页面
}

void MainWindow::onDaijiClicked()
{
    qDebug() << "待机按钮被点击";
    // TODO: 切换到待机状态
}

void MainWindow::resizeEvent(QResizeEvent *event)
{
    QMainWindow::resizeEvent(event);
    updateLayout();
}

void MainWindow::updateLayout()
{
    // 计算缩放比例（基于宽度或高度的较小值）
    double scaleX = (double)width() / 1024.0;
    double scaleY = (double)height() / 768.0;
    scale = qMin(scaleX, scaleY);

    // 更新所有元素的位置和大小
    lblBackground->setGeometry(0, 0, 1024 * scale, 768 * scale);
    lblGsmc->setGeometry(10 * scale, 15 * scale, 160 * scale, 50 * scale);
    lblSidebar->setGeometry(17 * scale, 79 * scale, 122 * scale, 675 * scale);
    lblJx->setGeometry(156 * scale, 86 * scale, 846 * scale, 675 * scale);

    btnJiankong->setGeometry(28 * scale, 106 * scale, 105 * scale, 90 * scale);
    btnShishiquxian->setGeometry(28 * scale, 215 * scale, 105 * scale, 90 * scale);
    btnShengchanbaobiao->setGeometry(28 * scale, 324 * scale, 105 * scale, 90 * scale);
    btnCanshushezhi->setGeometry(28 * scale, 432 * scale, 105 * scale, 90 * scale);
    btnIo->setGeometry(28 * scale, 541 * scale, 105 * scale, 90 * scale);
    btnBaojing->setGeometry(28 * scale, 650 * scale, 105 * scale, 90 * scale);

    lblXiaobaikuang1->setGeometry(179 * scale, 95 * scale, 387 * scale, 320 * scale);
    lblYunxingzhuangtai->setGeometry(179 * scale, 95 * scale, 112 * scale, 39 * scale);
    lblDangqianzhuangtai->setGeometry(217 * scale, 172 * scale, 80 * scale, 28 * scale);
    btnDaiji->setGeometry(316 * scale, 169 * scale, 106 * scale, 34 * scale);

    lblXiaobaikuang2->setGeometry(585 * scale, 95 * scale, 387 * scale, 320 * scale);
    lblYunxingshuju->setGeometry(589 * scale, 95 * scale, 112 * scale, 39 * scale);
    lblJiechuweizhi->setGeometry(645 * scale, 155 * scale, 80 * scale, 28 * scale);
}
