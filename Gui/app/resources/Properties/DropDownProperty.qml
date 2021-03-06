import QtQuick 2.0
import QtQuick.Controls 2.2
import Dnai.Controls 1.0

import Dnai.Theme 1.0

BaseProperty {
    id: _panel
    property var listmodel: null
    property real contentHeight: 35
    property alias label: _label
    property alias value: _value.currentIndex
    property alias valueRef: _value
    property bool init: false
    property ItemDelegate itemDelegate: null
    property string textRole: ""

    anchors.left: parent.left
    anchors.right: parent.right
    height: _panel.contentHeight + header.height + _panel.content.anchors.topMargin * 2

    Item {
        id: _property
        height: _panel.contentHeight
        anchors.left: parent.left
        anchors.right: parent.right

        Label {
            id: _label
            text: qsTr("Value selected :")
            anchors.left: parent.left
            height: _panel.contentHeight
            verticalAlignment: Text.AlignVCenter
            color: "#ffffff"
        }
        ComboBox {
            id: _value
            model: _panel.listmodel
            anchors.right: parent.right
            anchors.left: _label.right
            anchors.leftMargin: 5
            textRole: _panel.textRole
            anchors.verticalCenter: parent.verticalCenter

            onCurrentIndexChanged: {
                if (_panel.method !== null && init)
                {
                    _panel.method(_panel.model, _panel.prop, _value.currentIndex)
                }
                init = true
            }
        }
    }

}
