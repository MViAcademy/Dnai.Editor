import QtQuick 2.4
import DNAI 1.0

import "../Controls"

Item {
    id: root
    property bool opened
    property string imgSrc
    property string fullname
    property alias mouseArea: mouseArea
    property alias menu: menu
    property alias profileBtn: profileBtn
    property alias uploadBtn: uploadBtn
    property alias logoutBtn: logoutBtn

    width: height + _text.width

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
    }
    Text {
        id: _text
        text: (fullname != "") ? fullname : qsTr("Sign In")
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        color: DulySettings.style.text.color
        font.pixelSize: DulySettings.style.font.pixelSize
        font.family: DulySettings.style.font.family
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
    }

    Image {
        id: avatar
        anchors.right: parent.right
        anchors.rightMargin: 0
        source: (imgSrc != "") ? imgSrc : ""
        fillMode: Image.PreserveAspectFit
        width: parent.height
        height: parent.height
        sourceSize.width: parent.height
        sourceSize.height: parent.height
    }

    DMenu {
        id: menu
        y: parent.height
        DMenuItem {
            id: profileBtn
            font.pixelSize: DulySettings.style.font.pixelSize
            font.family: DulySettings.style.font.family
            text: qsTr("Profile")
        }
        DMenuItem {
            id: uploadBtn
            font.pixelSize: DulySettings.style.font.pixelSize
            font.family: DulySettings.style.font.family
            text: qsTr("Upload")
        }

        Rectangle {
            border.width: 1
            anchors.fill: parent
            height: 1
        }

        DMenuItem {
            id: logoutBtn
            font.pixelSize: DulySettings.style.font.pixelSize
            font.family: DulySettings.style.font.family
            text: qsTr("Logout")
        }
    }
}