import QtQuick 2.9
import QtQuick.Controls 2.2
import DNAI.Views 1.0

import DNAI 1.0
import DNAI.Enums 1.0
import Dnai.FontAwesome 1.0
import Dnai.Settings 1.0

import DNAI.Core 1.0

import "../Forms"
import "../Nodes"
import "../Style"

GenericNode {
    id: _node
    content: contentNode
    header: headerNode
    width: headerNode.width + headerNode.borderWidth * 4
    height: headerNode.height + contentNode.height + headerNode.borderWidth * 6
    property var model: null
    property var instruction_model: null
    property int paddingColumn: 10
    property var function_entity: null

    state: "Open"

    onXChanged: {
        if (instruction_model)
            instruction_model.setX(x)
    }

    onYChanged: {
        if (instruction_model)
            instruction_model.setY(y)
    }

    RoundedRectangle {
        id: headerNode

        x: borderWidth * 2
        y: borderWidth * 2

        implicitWidth: if (_name.width > _description.width
                               && _name.width * 1.5 > 100)
                           _name.width * 1.5
                       else if (_description.width * 1.5 > 200)
                           _description.width * 1.5
                       else
                           200
        implicitHeight: _name.height * 1.3 + _description.height * 1.3

        bottomLeft: false
        bottomRight: false
        topRight: false
        borderWidth: 1
        radius: 10
        borderColor: "#7C7C7C"
        fillColor: "#aa101010"
        antialiasing: true

        MLabel {
            id: _name
            text:  _node.model.name
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            visible: _node.state === "Open"
        }
        MLabel {
            id: _description
            text:  _node.model.description
            font.italic: true
            anchors.top: parent.top
            anchors.topMargin: _name.height * 1.3
            anchors.horizontalCenter: parent.horizontalCenter
            visible: _node.state === "Open"
        }
        TextAwesomeSolid {
            id: _icon
            font.pointSize: 15
            anchors.fill: parent
            visible: _node.state !== "Open"
        }
    }
    RoundedRectangle {
        id: contentNode

        x: borderWidth * 2
        y: borderWidth * 2

        width: headerNode.width
        height: childrenRect.height + 2 * _node.paddingColumn

        anchors.top: headerNode.bottom
        anchors.topMargin: headerNode.borderWidth + 1

        visible: _node.state === "Open"

        radius: headerNode.radius
        borderWidth: headerNode.borderWidth
        borderColor: headerNode.borderColor
        fillColor: "#aa000000"
        antialiasing: headerNode.antialiasing
        topLeft: false
        topRight: false
        bottomLeft: false

        //Flow in list
        Column {
            id: _flowIn
            spacing: 10
            width: 10
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: _node.paddingColumn
            Repeater {
                model: _node.model.flowIn
                delegate: Flow {
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        onContainsMouseChanged: {
                            isHover = containsMouse
                        }
                        onPressed: {
                            mouse.accepted = false
                        }
                    }
                    radius: 6
                    width: 12
                    height: 12
                    borderWidth: 3
                    antialiasing: true
                    typeFlow: FlowType.Enter
                    curveColor: AppSettings.theme["flow"]["outer"]
                    borderColor: isHover ? AppSettings.theme["flow"]["inner"] : AppSettings.theme["flow"]["outer"]
                    fillColor: isLink || isHover ? AppSettings.theme["flow"]["outer"] : AppSettings.theme["flow"]["inner"]
                    onLinked: {
                        if (instructionModel)
                            Controller.Function.instruction.linkExecution(_node.function_entity.id, instructionModel.uid, outindex, _node.instruction_model.uid);
                        else
                            Controller.Function.setEntryPoint(_node.function_entity.id, _node.instruction_model.uid);
                    }
                    onUnlinked: {
                        if (instructionModel)
                            Controller.Function.instruction.unlinkExecution(_node.function_entity.id, instructionModel.uid, outindex);
                        else
                            console.log("Unset entry point");
                    }
                }
            }
        }

        //Input list
        Column {
            spacing: 10
            width: 10
            anchors.left: parent.left
            anchors.top: _flowIn.bottom
            anchors.margins: _node.paddingColumn

            Repeater {
                model: _node.model.inputs
                delegate: Input {
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        onContainsMouseChanged: {
                            isHover = containsMouse
                        }
                        onPressed: {
                            mouse.accepted = false
                        }
                    }
                    id: _inputDel
                    property string name: ""
                    property string varType: ""
                    width: 10
                    height: 10
                    radius: 5
                    borderWidth: 3
                    curveColor: AppSettings.theme["types"][varType]["outer"]
                    borderColor: isHover ? AppSettings.theme["types"][varType]["inner"] : AppSettings.theme["types"][varType]["outer"]
                    fillColor: isLink || isHover ? AppSettings.theme["types"][varType]["outer"] : AppSettings.theme["types"][varType]["inner"]
                    onLinked: {
                        Controller.Function.instruction.linkData(_node.function_entity.id, instructionModel.uid, name, _node.instruction_model.uid, _inputDel.name);
                    }
                    onUnlinked: {
                        Controller.Function.instruction.unlinkData(_node.function_entity.id, _node.instruction_model.uid, _inputDel.name);
                    }
                    Component.onCompleted: {
                        name = _node.model.inputNames[index]
                        var typeEntity = Controller.getEntityByFullName(_node.instruction_model.linked[index])
                        if (typeEntity.guiProperties !== null)
                        {
                            if (typeof(typeEntity.guiProperties.varType) === "undefined")
                                varType = "Generic"
                            else
                                varType = Controller.getType(Controller.getTypeIndex(typeEntity.guiProperties.varType)).name
                        }
                        else
                        {
                            varType = _node.instruction_model.linked[index];
                        }

                    }

                    Text {
                        id: _inputName

                        anchors.left: parent.right
                        anchors.leftMargin: 5
                        height: parent.height

                        text: parent.name
                        font.pointSize: 8

                        color: "white"
                    }

                    EditableText {
                        id: _inputValue

                        //visible: parent.type >= 1 && parent.type <= 5

                        anchors.left: _inputName.right
                        anchors.leftMargin: 5
                        width: 50
                        height: parent.height

                        text: ""
                        placeholderText: ""
                        font.pointSize: 7
                        enableBar: false

                        onAccepted: {
                            if (_inputValue.text)
                                Controller.Function.instruction.setInputValue(_node.function_entity.id, _node.instruction_model.uid, _inputDel.name, _inputValue.text);
                        }
                    }
                }
            }
        }

        //Flow out List
        Column {
            id: _flowOut
            spacing: 10
            width: 10
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: _node.paddingColumn
            Repeater {
                model: _node.model.flowOut
                delegate: Flow {
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        onContainsMouseChanged: {
                            isHover = containsMouse
                        }
                        onPressed: {
                            mouse.accepted = false
                        }
                    }
                    radius: 6
                    width: 17
                    height: 17
                    borderWidth: 3
                    antialiasing: true
                    typeFlow: FlowType.Exit
                    curveColor: AppSettings.theme["flow"]["outer"]
                    borderColor: isHover ? AppSettings.theme["flow"]["inner"] : AppSettings.theme["flow"]["outer"]
                    fillColor: isLink || isHover ? AppSettings.theme["flow"]["outer"] : AppSettings.theme["flow"]["inner"]
                    onLinked: {
                        Controller.Function.instruction.linkExecution(_node.function_entity.id, _node.instruction_model.uid, outindex, instructionModel.uid);
                    }
                    onUnlinked: {
                        Controller.Function.instruction.unlinkExecution(_node.function_entity.id, _node.instruction_model.uid, outindex);
                    }
                }
            }
        }

        //Output List
        Column {
            spacing: 10
            width: 10
            anchors.right: parent.right
            anchors.top: _flowOut.bottom
            anchors.margins: _node.paddingColumn
            Repeater {
                model: _node.model.outputs
                delegate: Output {
                    id: _outputDel
                    property string name: ""
                    property string varType: ""
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        onContainsMouseChanged: {
                            isHover = containsMouse
                        }
                        onPressed: {
                            mouse.accepted = false
                        }
                    }

                    width: 10
                    height: 10
                    radius: 5
                    borderWidth: 3
                    curveColor: AppSettings.theme["types"][varType]["outer"]
                    borderColor: isHover ? AppSettings.theme["types"][varType]["inner"] : AppSettings.theme["types"][varType]["outer"]
                    fillColor: isLink || isHover ? AppSettings.theme["types"][varType]["outer"] : AppSettings.theme["types"][varType]["inner"]
                    onLinked: {
                        Controller.Function.instruction.linkData(_node.function_entity.id, _node.instruction_model.uid, _outputDel.name, instructionModel.uid, name);
                    }
                    onUnlinked: {
                        console.log("Unlink Output")
                        console.log(name)
                        console.log(instructionModel)
                        console.log(_outputDel.name)
                        console.log(_node.instruction_model)
                        Controller.Function.instruction.unlinkData(_node.function_entity.id, instruction_model.id, name);
                    }
                    Component.onCompleted: {
                        name = _node.model.outputNames[index]
                        var typeEntity = Controller.getEntityByFullName(_node.instruction_model.linked[_node.model.construction.length + index - 1])
                        if (typeEntity.guiProperties !== null)
                        {
                            if (typeof(typeEntity.guiProperties.varType) === "undefined")
                                varType = "Generic"
                            else
                                varType = Controller.getType(Controller.getTypeIndex(typeEntity.guiProperties.varType)).name
                        }
                        else
                        {
                            varType = _node.instruction_model.linked[_node.model.construction.length + index - 1];
                        }

                    }

                    Text {
                        id: _outputName

                        anchors.right: parent.left
                        anchors.rightMargin: 5
                        height: parent.height

                        text: parent.name
                        font.pointSize: 8

                        color: "white"
                    }
                }
            }
        }

    }
}
