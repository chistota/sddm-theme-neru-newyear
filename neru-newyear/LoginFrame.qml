import QtQuick 2.7
import QtGraphicalEffects 1.0
import SddmComponents 2.0
import QtQuick.Controls 2.0

Item {
    id: frame
    property int sessionIndex: find_list(sessionModel, config.default_session)
    property string userName: userModel.lastUser
    property alias input: userNameInput
    property alias passwdInput: passwdInput
    property alias button: loginButton
    function find_list(haystack, needle) {
        var i;
        for (i = 0; i < sessionModel.rowCount(); i++) {
            var file = sessionModel.data(sessionModel.index(i,0), 258)
            var name = file.substring(file.lastIndexOf('/')+1, file.lastIndexOf('.'))
            if(name.toLowerCase() == needle.toLowerCase()) {
                return i
            }
        }
        return 0
    }

    Connections {
        target: sddm
        onLoginSucceeded: {
            spinner.running = false
            Qt.quit()
        }
        onLoginFailed: {
            loginButton.text = textConstants.loginFailed
            passwdInput.text = ""
            loginButtonBack.color = "#f44336" //цвет кнопки ошиочного ввода пароля
            
            spinner.running = false
            loginFailed.running = true

        }
    }
    Timer {
        id: loginFailed;
        interval: 5000;
        running: false;
        repeat: false;
        onTriggered: {
            loginButton.text = qsTr("ВХОД")
            loginButtonBack.color = config.accent2
        }
    }
    Item {
        anchors.fill: parent

        Item {
            id: layered
            opacity: 0.9 //прозрачность центральной области
            layer.enabled: true
            anchors {
                centerIn: parent
                fill: parent
            }

            Rectangle {
                id: rec1
                width: parent.width / 3
                height: parent.height - 3
                anchors.centerIn: parent
                color: "#f0f0f0" //цвет центральной области фона светло серый
                radius: 10
                
            }
//Тень центральной части фона
            DropShadow {
                id: drop
                anchors.fill: rec1
                source: rec1
                horizontalOffset: 0
                verticalOffset: 0
                radius: 0
                samples: 0
                //color: "#55000000" //темно бордовый прозрачный
                color: "#fff"
                //transparentBorder: true
            }
        }
    }

    Item {
        id: loginItem
        anchors.centerIn: parent
        width: parent.width / 3 - 200
        height: parent.height


        state: config.user_name

        states: [
            State {
                name: "fill"
                PropertyChanges { target: userNameText; opacity: 0}
                PropertyChanges { target: userNameInput; opacity: 1}
                PropertyChanges { target: userIconRec; source: config.logo }
            },
            State {
                name: "select"
                PropertyChanges { target: userNameText; opacity: 1}
                PropertyChanges { target: userNameInput; opacity: 0}
                PropertyChanges { target: userIconRec; source: userFrame.currentIconPath }
            }
        ]
//индикация загрузки
        BusyIndicator {
            id: spinner
            running: false
            visible: running
            anchors {
                top: parent.top
                topMargin: 30 //расстояние сверху
                horizontalCenter: parent.horizontalCenter
            }
            width: 190
            height: 190
            contentItem: Rectangle {
                id: spinning_item
                implicitWidth: spinner.width
                implicitHeight: spinner.height
                radius: width*0.5
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00ffffff" }
                    GradientStop { position: 0.3; color: "#00ffffff" }
                    GradientStop { position: 0.4; color: "#808080" }
                    GradientStop { position: 1.0; color: "#808080" }
                }

                RotationAnimator {
                    target: spinning_item
                    running: spinner.visible && spinner.running
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    duration: 1250
                }
            }
        }
//аватар пользователя
        UserAvatar {
            id: userIconRec
            anchors {
                top: parent.top
                topMargin: 40 //расстояние сверху
                horizontalCenter: parent.horizontalCenter
            }
            width: 170
            height: 170
            
            source: userFrame.currentIconPath
            onClicked: {
                if (config.user_name == "select") {
                    root.state = "stateUser"
                    userFrame.focus = true
                }
            }
        }

        MaterialTextbox {
            id: userNameInput
            anchors {
                top: userIconRec.bottom
                topMargin: 10 //расстояние между логином и паролем
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width
            placeholderText: qsTr("Имя пользователя")

            KeyNavigation.backtab: {
                if (sessionButton.visible) {
                    return sessionButton
                }
                else if (userButton.visible) {
                    return userButton
                }
                else {
                    return shutdownButton
                }
            }
            KeyNavigation.tab: passwdInput

            onFocusChanged: {
                if (!focus) {
                    var url = config.session_api.replace("%s", text)
                    var xhr = new XMLHttpRequest();
                    xhr.onreadystatechange = function() {
                        if (xhr.readyState == 4 && xhr.status == 200) {
                            var session = xhr.responseText
                            if (session == 'N'){
                                sessionIndex = find_list(sessionModel, config.default_session)
                            } else if (session != null) {
                                sessionIndex = find_list(sessionModel, session)
                            }
                        }
                    }
                    xhr.open('GET', url, true)
                    xhr.send('')
                }
            }
        }


        Text {
            id: userNameText
            anchors {
                top: userNameInput.top
                bottom: userNameInput.bottom
                horizontalCenter: parent.horizontalCenter
            }
            text: userName
            color: "#3496d2"
            font.pointSize: 15
        }

        MaterialTextbox{
            id: passwdInput
            anchors {
                top: userNameInput.bottom
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width
            placeholderText: qsTr("Пароль")
            echoMode: TextInput.Password
            onAccepted: {
                spinner.running = true
                userName = userNameText.text
                if (config.user_name == "fill") {
                    userName = userNameInput.text
                }
                sddm.login(userName, passwdInput.text, sessionIndex)
            }
            KeyNavigation.backtab: {
                if (userNameInput.visible) {
                    return userNameInput
                }
                else if (sessionButton.visible) {
                    return sessionButton
                }
                else if (userButton.visible) {
                    return userButton
                }
                else {
                    return shutdownButton
                }
            }

            KeyNavigation.tab: loginButton
        }


        Button {
            id: loginButton
            width: parent.width
            text: qsTr("ВХОД")
            font.pointSize: 15
            highlighted: true
            background: Rectangle {
                id: loginButtonBack
                color: "#3496d2" //цвет кнопки
                implicitHeight: 40
            }

            anchors {
                top: passwdInput.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
                leftMargin: 8
                rightMargin: 8 + 36
            }
            onClicked: {
                spinner.running = true
                userName = userNameText.text
                if (config.user_name == "fill") {
                    userName = userNameInput.text
                }
                sddm.login(userName, passwdInput.text, sessionIndex)
            }

            onFocusChanged: {
                // Changing the radius here may make sddm 0.15 segfault
                if (focus) {
                    loginButtonShadow.verticalOffset = 2
                    loginButtonBack.color = config.accent2_hover
                    
                } else {
                    loginButtonShadow.verticalOffset = 1
                    loginButtonBack.color = config.accent2
                   
                }
            }

            KeyNavigation.tab: userNameInput
            KeyNavigation.backtab: passwdInput
        }
        //Тень под кнопкой
        DropShadow {
            id: loginButtonShadow
            anchors.fill: loginButton
            horizontalOffset: 0
            verticalOffset: 0
            radius: 0
            samples: 0
            color: "#fff"
            source: loginButton
        }
    }
}
