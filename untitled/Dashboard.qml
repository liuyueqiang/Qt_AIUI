import QtQuick 2.12

Item {
    id: root

    // 对外暴露的属性（从C++更新）
    property real speed: 0
    property int rpm: 0
    property real fuel: 75.0
    property real temperature: 85.0

    // 全局稳定化Timer - 等窗口稳定后统一重绘
    Timer {
        id: globalStabilizeTimer
        interval: 1000  // 窗口停止resize后1秒重绘
        repeat: false
        onTriggered: {
            console.log("========== 窗口稳定1秒，触发全局重绘 ==========")
            console.log("当前root尺寸: width=" + root.width + ", height=" + root.height)
            console.log("当前speed=" + root.speed + ", rpm=" + root.rpm)
            speedArc.requestPaint()
            rpmArc.requestPaint()
            console.log("========== 重绘请求已发送 ==========")
        }
    }

    // 监听root尺寸变化
    onWidthChanged: {
        console.log(">>> root宽度变化: " + width + " (Timer重启)")
        globalStabilizeTimer.restart()
    }
    onHeightChanged: {
        console.log(">>> root高度变化: " + height + " (Timer重启)")
        globalStabilizeTimer.restart()
    }

    // 半透明黑色背景
    Rectangle {
        anchors.fill: parent
        color: "#80000000"
        radius: 10
    }

    // 主仪表盘区域
    Row {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -50
        spacing: Math.min(root.width, root.height) * 0.1

        // 左侧：速度表
        Item {
            width: 280  // 固定尺寸测试
            height: 280

            // 速度表背景圆
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "#1a1a1a"
                border.color: "#3a3a3a"
                border.width: 3
            }

            // 彩色进度弧
            Canvas {
                id: speedArc
                anchors.fill: parent
                renderStrategy: Canvas.Cooperative
                renderTarget: Canvas.FramebufferObject

                onPaint: {
                    var ctx = getContext("2d")

                    // 完全重置上下文
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)

                    if (width <= 0 || height <= 0) {
                        console.log("速度表Canvas尺寸无效: width=" + width + ", height=" + height)
                        return
                    }

                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = width / 2 - 25

                    if (radius <= 0) {
                        console.log("速度表半径无效: radius=" + radius)
                        return
                    }

                    var startAngle = -Math.PI * 0.75
                    var endAngle = startAngle + (root.speed / 180) * Math.PI * 1.5

                    console.log("速度表绘制: speed=" + root.speed +
                                ", width=" + width +
                                ", height=" + height +
                                ", radius=" + radius +
                                ", startAngle=" + startAngle +
                                ", endAngle=" + endAngle +
                                ", 弧度范围=" + (endAngle - startAngle))

                    // 保存上下文状态
                    ctx.save()

                    ctx.lineWidth = 12
                    ctx.lineCap = "round"

                    // 渐变色
                    var gradient = ctx.createLinearGradient(0, 0, width, height)
                    gradient.addColorStop(0, "#00ff00")
                    gradient.addColorStop(0.5, "#ffff00")
                    gradient.addColorStop(1, "#ff0000")

                    ctx.strokeStyle = gradient
                    ctx.beginPath()
                    ctx.arc(centerX, centerY, radius, startAngle, endAngle, false)
                    ctx.stroke()

                    // 恢复上下文状态
                    ctx.restore()
                }

                // 使用全局Timer，不再单独监听尺寸变化
                // onWidthChanged和onHeightChanged已移除

                Connections {
                    target: root
                    function onSpeedChanged() {
                        speedArc.requestPaint()
                    }
                }
            }

            // 刻度线
            Repeater {
                model: 19

                Item {
                    rotation: -135 + index * 15
                    x: parent.width / 2
                    y: parent.height / 2

                    Rectangle {
                        x: -1.5
                        y: -parent.parent.height / 2 + 20
                        width: 3
                        height: index % 3 === 0 ? 12 : 6
                        color: "#ffffff"
                        opacity: 0.5
                    }

                    Text {
                        visible: index % 3 === 0
                        text: index * 10
                        x: -12
                        y: -parent.parent.height / 2 + 38
                        font.pixelSize: 12
                        color: "#ffffff"
                        rotation: -(-135 + index * 15)
                    }
                }
            }

            // 指针
            Rectangle {
                id: speedNeedle
                width: 4
                height: parent.height * 0.4
                color: "#00ff88"
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                transformOrigin: Item.Bottom

                rotation: -135 + (speed / 180) * 270

                Behavior on rotation {
                    SpringAnimation {
                        spring: 1.5
                        damping: 0.2
                    }
                }

                // 发光效果
                Rectangle {
                    anchors.fill: parent
                    color: "#00ff88"
                    radius: parent.radius
                    opacity: 0.3
                    scale: 1.5
                }
            }

            // 中心圆
            Rectangle {
                width: parent.width * 0.08
                height: parent.height * 0.08
                radius: width / 2
                color: "#00ff88"
                anchors.centerIn: parent
                border.color: "#ffffff"
                border.width: 2
            }

            // 速度数值（显示在仪表盘最外圈）
            Text {
                text: Math.round(speed).toString()
                anchors.centerIn: parent
                anchors.verticalCenterOffset: parent.height * 0.32
                font.pixelSize: Math.max(32, parent.width * 0.12)
                font.bold: true
                color: "#ffffff"
            }

            Text {
                text: "km/h"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: parent.height * 0.42
                font.pixelSize: Math.max(14, parent.width * 0.05)
                color: "#999999"
            }
        }

        // 右侧：转速表
        Item {
            width: 280  // 固定尺寸测试
            height: 280

            // 转速表背景圆
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "#1a1a1a"
                border.color: "#3a3a3a"
                border.width: 3
            }

            // 转速进度弧
            Canvas {
                id: rpmArc
                anchors.fill: parent
                renderStrategy: Canvas.Cooperative
                renderTarget: Canvas.FramebufferObject

                onPaint: {
                    var ctx = getContext("2d")

                    // 完全重置上下文
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)

                    if (width <= 0 || height <= 0) {
                        console.log("转速表Canvas尺寸无效: width=" + width + ", height=" + height)
                        return
                    }

                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = width / 2 - 25

                    if (radius <= 0) {
                        console.log("转速表半径无效: radius=" + radius)
                        return
                    }

                    var startAngle = -Math.PI * 0.75
                    var endAngle = startAngle + (root.rpm / 8000) * Math.PI * 1.5

                    console.log("转速表绘制: rpm=" + root.rpm +
                                ", width=" + width +
                                ", height=" + height +
                                ", radius=" + radius +
                                ", startAngle=" + startAngle +
                                ", endAngle=" + endAngle +
                                ", 弧度范围=" + (endAngle - startAngle))

                    // 保存上下文状态
                    ctx.save()

                    ctx.lineWidth = 12
                    ctx.lineCap = "round"

                    // 蓝色到红色渐变
                    var gradient = ctx.createLinearGradient(0, 0, width, height)
                    gradient.addColorStop(0, "#00aaff")
                    gradient.addColorStop(0.7, "#ffaa00")
                    gradient.addColorStop(1, "#ff0000")

                    ctx.strokeStyle = gradient
                    ctx.beginPath()
                    ctx.arc(centerX, centerY, radius, startAngle, endAngle, false)
                    ctx.stroke()

                    // 恢复上下文状态
                    ctx.restore()
                }

                // 使用全局Timer，不再单独监听尺寸变化
                // onWidthChanged和onHeightChanged已移除

                Connections {
                    target: root
                    function onRpmChanged() {
                        rpmArc.requestPaint()
                    }
                }
            }

            // 刻度线
            Repeater {
                model: 9

                Item {
                    rotation: -135 + index * 33.75
                    x: parent.width / 2
                    y: parent.height / 2

                    Rectangle {
                        x: -1.5
                        y: -parent.parent.height / 2 + 20
                        width: 3
                        height: 12
                        color: "#ffffff"
                        opacity: 0.5
                    }

                    Text {
                        text: index
                        x: -8
                        y: -parent.parent.height / 2 + 38
                        font.pixelSize: 12
                        color: "#ffffff"
                        rotation: -(-135 + index * 33.75)
                    }
                }
            }

            // 指针
            Rectangle {
                id: rpmNeedle
                width: 4
                height: parent.height * 0.4
                color: "#ff6600"
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                transformOrigin: Item.Bottom

                rotation: -135 + (rpm / 8000) * 270

                Behavior on rotation {
                    SpringAnimation {
                        spring: 1.5
                        damping: 0.2
                    }
                }

                // 发光效果
                Rectangle {
                    anchors.fill: parent
                    color: "#ff6600"
                    radius: parent.radius
                    opacity: 0.3
                    scale: 1.5
                }
            }

            // 中心圆
            Rectangle {
                width: parent.width * 0.08
                height: parent.height * 0.08
                radius: width / 2
                color: "#ff6600"
                anchors.centerIn: parent
                border.color: "#ffffff"
                border.width: 2
            }

            // 转速数值（显示在仪表盘最外圈）
            Text {
                text: Math.round(rpm).toString()
                anchors.centerIn: parent
                anchors.verticalCenterOffset: parent.height * 0.32
                font.pixelSize: Math.max(32, parent.width * 0.12)
                font.bold: true
                color: "#ffffff"
            }

            Text {
                text: "RPM"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: parent.height * 0.42
                font.pixelSize: Math.max(14, parent.width * 0.05)
                color: "#999999"
            }
        }
    }

    // 底部信息栏
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: parent.height * 0.06
        spacing: parent.width * 0.08

        // 油量
        Column {
            spacing: 5

            Row {
                spacing: 8

                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    color: fuel > 20 ? "#00ff88" : "#ff0000"

                    Text {
                        anchors.centerIn: parent
                        text: "⛽"
                        font.pixelSize: 14
                        color: "#000000"
                    }
                }

                Text {
                    text: "油量"
                    font.pixelSize: 14
                    color: "#999999"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                text: fuel.toFixed(1) + "%"
                font.pixelSize: 20
                font.bold: true
                color: fuel > 20 ? "#ffffff" : "#ff0000"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 油量进度条
            Rectangle {
                width: 100
                height: 8
                radius: 4
                color: "#2a2a2a"
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: parent.width * (fuel / 100)
                    height: parent.height
                    radius: parent.radius
                    color: fuel > 20 ? "#00ff88" : "#ff0000"

                    Behavior on width {
                        NumberAnimation { duration: 300 }
                    }
                }
            }
        }

        // 温度
        Column {
            spacing: 5

            Row {
                spacing: 8

                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    color: temperature < 100 ? "#00aaff" : "#ff0000"

                    Text {
                        anchors.centerIn: parent
                        text: "🌡"
                        font.pixelSize: 14
                        color: "#000000"
                    }
                }

                Text {
                    text: "温度"
                    font.pixelSize: 14
                    color: "#999999"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                text: temperature.toFixed(1) + "°C"
                font.pixelSize: 20
                font.bold: true
                color: temperature < 100 ? "#ffffff" : "#ff0000"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 温度进度条
            Rectangle {
                width: 100
                height: 8
                radius: 4
                color: "#2a2a2a"
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: parent.width * (temperature / 120)
                    height: parent.height
                    radius: parent.radius
                    color: temperature < 100 ? "#00aaff" : "#ff0000"

                    Behavior on width {
                        NumberAnimation { duration: 300 }
                    }
                }
            }
        }

        // 档位显示
        Column {
            spacing: 5

            Text {
                text: "档位"
                font.pixelSize: 14
                color: "#999999"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: 60
                height: 60
                radius: 8
                color: "#00ff88"
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "D"
                    anchors.centerIn: parent
                    font.pixelSize: 36
                    font.bold: true
                    color: "#000000"
                }
            }
        }
    }

    // 顶部警告灯
    Row {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: parent.height * 0.03
        spacing: 15

        // 引擎警告灯
        Rectangle {
            width: 32
            height: 32
            radius: 16
            color: rpm > 6500 ? "#ff0000" : "#2a2a2a"
            border.color: rpm > 6500 ? "#ff6666" : "#4a4a4a"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "⚠"
                font.pixelSize: 18
                color: rpm > 6500 ? "#ffffff" : "#666666"
            }

            // 闪烁动画
            SequentialAnimation on opacity {
                running: rpm > 6500
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 500 }
                NumberAnimation { to: 1.0; duration: 500 }
            }
        }

        // 安全带警告
        Rectangle {
            width: 32
            height: 32
            radius: 16
            color: "#2a2a2a"
            border.color: "#4a4a4a"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "🔒"
                font.pixelSize: 16
                color: "#666666"
            }
        }

        // ABS指示灯
        Rectangle {
            width: 32
            height: 32
            radius: 16
            color: "#2a2a2a"
            border.color: "#4a4a4a"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "ABS"
                font.pixelSize: 10
                font.bold: true
                color: "#666666"
            }
        }
    }
}
