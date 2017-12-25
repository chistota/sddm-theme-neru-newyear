//Меню после нажатия кнопки выключения
import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    signal needClose()
    signal needShutdown()
    signal needRestart()
    signal needSuspend()

    property alias shutdown: shutdownButton

    Row {
        spacing: 70 //расстояние между значками

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        Item {
            width: 100
            height: 150

            ImgButton {
                id: shutdownButton
                width: 75
                height: 75
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                normalImg: "icons/powerframe/shutdown_normal.svg"
                hoverImg: "icons/powerframe/shutdown_hover.svg"
                pressImg: "icons/powerframe/shutdown_press.svg"
                onClicked: needShutdown()
                KeyNavigation.right: restartButton
                KeyNavigation.left: suspendButton
                Keys.onEscapePressed: needClose()
            }

            Text {
                text: qsTr("Выключение")
                font.pointSize: 15
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }
        }

        Item {
            width: 100
            height: 150

            ImgButton {
                id: restartButton
                width: 75
                height: 75
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                normalImg: "icons/powerframe/restart_normal.svg"
                hoverImg: "icons/powerframe/restart_hover.svg"
                pressImg: "icons/powerframe/restart_press.svg"
                onClicked: needRestart()
                KeyNavigation.right: suspendButton
                KeyNavigation.left: shutdownButton
                Keys.onEscapePressed: needClose()
            }

            Text {
                text: qsTr("Перезагрузка")
                font.pointSize: 15
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }
        }

        Item {
            width: 100
            height: 150

            ImgButton {
                id: suspendButton
                width: 75
                height: 75
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                normalImg: "icons/powerframe/suspend_normal.svg"
                hoverImg: "icons/powerframe/suspend_hover.svg"
                pressImg: "icons/powerframe/suspend_press.svg"
                onClicked: needSuspend()
                KeyNavigation.right: shutdownButton
                KeyNavigation.left: restartButton
                Keys.onEscapePressed: needClose()
            }

            Text {
                text: qsTr("Сон")
                font.pointSize: 15
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }
        }
    }

    MouseArea {
        z: -1
        anchors.fill: parent
        onClicked: needClose()
    }

    Keys.onEscapePressed: needClose()
}
