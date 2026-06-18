import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Page {
    id: addPage

    property bool editMode: false
    property int recipeId: -1
    property string initTitle: ""
    property string initCategory: ""
    property string initRawData: ""
    property string chosenImagePath: ""
    property var combos: []


    property var unitsRef: ["г", "кг", "шт", "мл", "л", "ч.л.", "ст.л."]

    signal operationCompleted()

    function getManager() {
        return typeof recipeManager !== "undefined" ? recipeManager : window.recipeManager;
    }

    ListModel {

        id: ingredientsModel
    }

    Component.onCompleted: {

        combos = [];
        if (editMode) {
            titleInput.text = initTitle;

            for (var k = 0; k < categoryInput.model.length; k++) {
                if (categoryInput.model[k] === initCategory) {
                    categoryInput.currentIndex = k;
                    break;
                }
            }

            var jsonPart = initRawData.split("IMG:")[0];
            if (initRawData.includes("IMG:")) {
                chosenImagePath = initRawData.split("IMG:")[1];
            }

            try {

                if (jsonPart.trim() !== "") {
                    var recipeJson = JSON.parse(jsonPart);
                    descInput.text = recipeJson.steps || "";
                    ingredientsModel.clear();


                    if (recipeJson.ingredients) {
                        for (var i = 0; i < recipeJson.ingredients.length; i++) {

                            var unitStr = recipeJson.ingredients[i].unit;
                            var unitIdx = unitsRef.indexOf(unitStr);
                            if (unitIdx === -1) unitIdx = 2;
                            ingredientsModel.append({
                            "name": recipeJson.ingredients[i].name,
                            "amount": recipeJson.ingredients[i].amount.toString(),
                            "unitIndex": unitIdx

                            });
                         }
                    }

                } else {
                    descInput.text = "";
                    ingredientsModel.clear();
                    ingredientsModel.append({"name": "", "amount": "1", "unitIndex": 2});

                }

            } catch(e)  {
                descInput.text = jsonPart;
                ingredientsModel.clear();
                ingredientsModel.append({"name": "", "amount": "1", "unitIndex": 2});
            }

        } else {

            ingredientsModel.clear();
            ingredientsModel.append({"name": "", "amount": "1", "unitIndex": 2});
        }
    }


    header: ToolBar {
        implicitHeight: 60
        background: Rectangle { color: "lightgreen" }

        RowLayout {

            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            Rectangle {
                id: cancelBtn
                width: 120
                height: 40
                radius: 10
                color: cancelMouse.containsMouse ? "lightgray" : "white"

                RowLayout {

                    anchors.centerIn: parent
                    spacing: 10

                    Image {
                        source: "icons/close.png"
                        width: 16
                        height: 16

                        fillMode: Image.PreserveAspectFit
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                    }
                    Text {
                        text: "Скасувати"
                        font.bold: true
                        color: cancelMouse.containsMouse ? "#C0392B" : "#E74C3C"
                        font.pixelSize: 16
                    }
                }

                MouseArea {
                    id: cancelMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: stackView.pop()

                }
            }

            Label {
                text: editMode ? "Редагування рецепта" : "Створення шедевра"
                font.pixelSize: 16
                color: "white"
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                Layout.rightMargin: 120

            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Оберіть фото страви"

        nameFilters: ["Зображення (*.png *.jpg *.jpeg)"]
        onAccepted: chosenImagePath = fileDialog.selectedFile
    }


    background: Rectangle {
        color: "white"
      }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        topPadding: 20

        ColumnLayout {
            width: Math.min(parent.width - 40, 800)
            anchors.horizontalCenter: parent.horizontalCenter
            Layout.bottomMargin: 25
            spacing: 20

            TextField {
                id: titleInput
                Layout.fillWidth: true
                placeholderText: "Назва страви"
                font.pixelSize: 16
                leftPadding: 10
                rightPadding: 10
                verticalAlignment: TextInput.AlignVCenter


                background: Rectangle {

                    implicitHeight: 40
                    radius: 8
                    border.color: titleInput.activeFocus ? "lightgreen" : "gray"
                    border.width: titleInput.activeFocus ? 2 : 1
                }
            }

            ComboBox {
                id: categoryInput
                Layout.fillWidth: true

                model: ["Супи", "Основні", "Салати", "Десерти", "Випічка"]
                font.pixelSize: 16

                contentItem: Text {
                    text: categoryInput.currentText
                    font: categoryInput.font
                    color: "#34495E"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }


                delegate: ItemDelegate {
                    width: categoryInput.width
                    text: modelData
                    font.pixelSize: 16
                }
                background: Rectangle {

                    implicitHeight: 40
                    radius: 8
                    border.color: categoryInput.activeFocus ? "lightgreen" : "lightgray"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                Rectangle {
                    width: 150
                    height: 40
                    radius: 10
                    color: photoMouse.containsMouse ? "white" : "lightgray"
                    border.color: "gray"
                    border.width: 1


                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            source: "icons/camera.png"
                            width: 16
                            height: 16
                            fillMode: Image.PreserveAspectFit
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16

                        }
                        Text {
                            text: "Змінити фото"
                            font.pixelSize: 12
                            color: "darkblue"
                            font.bold: true

                        }
                    }

                    MouseArea {
                        id: photoMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: fileDialog.open()

                    }
                }

                Label {

                    text: chosenImagePath !== "" ? "Фото завантажено" : "Немає фото"
                    color: chosenImagePath !== "" ? "lightgreen" : "gray"
                    font.pixelSize: 16
                    Layout.alignment: Qt.AlignVCenter
                 }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "lightgray"
                Layout.topMargin: 5
                Layout.bottomMargin: 5

            }

            Label {
                text: "Інгредієнти рецепта (на 1 порцію):"
                font.bold: true
                font.pixelSize: 16
                color: "darkblue"
            }

            Repeater {

                id: ingredientsRepeater
                model: ingredientsModel

                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    TextField {
                        placeholderText: "Назва інгредієнта"
                        Layout.fillWidth: true
                        text: model.name
                        font.pixelSize: 16
                        leftPadding: 10
                        verticalAlignment: TextInput.AlignVCenter

                        background: Rectangle {
                            implicitHeight: 40
                            radius: 8
                            border.color: parent.activeFocus ? "lightgreen" : "lightgray"
                        }

                        onTextChanged: model.name = text
                    }

                    TextField {
                        placeholderText: "Кількість"
                        Layout.preferredWidth: 80
                        text: model.amount
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter


                        validator: DoubleValidator { bottom: 0 }
                        background: Rectangle {
                            implicitHeight: 40
                            radius: 8
                            border.color: parent.activeFocus ? "lightgreen" : "lightgray"
                        }
                        onTextChanged: model.amount = text
                    }


                    ComboBox {
                        id: unitCombo
                        Layout.preferredWidth: 100
                        model: ["г", "кг", "шт", "мл", "л", "ч.л.", "ст.л."]
                        font.pixelSize: 14
                        currentIndex: ingredientsModel.get(index) ? ingredientsModel.get(index).unitIndex : 2

                        contentItem: Text {

                            text: unitCombo.currentText
                            font: unitCombo.font
                            color: "darkblue"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            leftPadding: 10
                        }

                        background: Rectangle {
                            implicitHeight: 40
                            radius: 8
                            border.color: "lightgray"
                        }

                        Component.onCompleted: {
                            var currentRefs = addPage.combos;
                            currentRefs[index] = unitCombo;
                            addPage.combos = currentRefs;
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: rowDeleteMouse.containsMouse ? "white" : "lightgray"
                        border.color: rowDeleteMouse.containsMouse ? "#E74C3C" : "transparent"


                        Image {
                            source: "icons/remove_item.png"
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {

                            id: rowDeleteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ingredientsModel.remove(index);
                                var currentRefs = addPage.combos;
                                currentRefs.splice(index, 1);
                                addPage.combos = currentRefs;
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: addIngMouse.containsMouse ? "lightgray" : "white"
                border.color: "lightgreen"
                border.width: 1


                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Image {
                        source: "icons/plus.png"
                        width: 16
                        height: 16
                        fillMode: Image.PreserveAspectFit
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                    }
                    Text {
                        text: "Додати інгредієнт"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: 16
                    }
                }

                MouseArea {
                    id: addIngMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ingredientsModel.append({"name": "", "amount": "1", "unitIndex": 2})
                }

            }

            Label {

                text: "Інструкція приготування:"
                font.bold: true
                font.pixelSize: 16
                color: "darkblue"
                Layout.topMargin: 10
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: "white"
                border.color: "gray"
                radius: 8

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 8
                    TextArea {

                        id: descInput
                        placeholderText: "Крок 1. Змішайте інгредієнти"
                        wrapMode: Text.Wrap
                        font.pixelSize: 16
                        selectByMouse: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 8

                color: saveMouse.containsMouse ? "lightgreen" : "green"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Image {
                        source: "icons/save.png"
                        width: 16
                        height: 16
                        fillMode: Image.PreserveAspectFit
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                    }
                    Text {

                        text: editMode ? "Зберегти зміни" : "Створити рецепт"
                        font.bold: true
                        color: "white"
                        font.pixelSize: 16
                    }
                }

                MouseArea {
                    id: saveMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (titleInput.text !== "") {
                            var ingredientsArray = [];

                            for (var i = 0; i < ingredientsModel.count; i++) {
                                var item = ingredientsModel.get(i);
                                if (item.name !== "") {
                                    var combo = addPage.combos[i];
                                    var currentIdx = combo ? combo.currentIndex : 2;
                                    ingredientsArray.push({
                                        "name": item.name,
                                        "amount": parseFloat(item.amount) || 0,
                                        "unit": unitsRef[currentIdx]
                                    });
                                }
                            }

                            var recipeData = {
                                "ingredients": ingredientsArray,
                                "steps": descInput.text
                            };

                            var jsonString = JSON.stringify(recipeData);
                            var finalDesc = jsonString + "IMG:" + (chosenImagePath !== "" ? chosenImagePath : "");

                            var activeManager = getManager();
                            if (activeManager) {
                                if (editMode) {
                                    activeManager.updateRecipe(recipeId, titleInput.text, categoryInput.currentText, finalDesc);
                                } else {
                                    activeManager.addRecipe(titleInput.text, categoryInput.currentText, finalDesc);
                                }
                            }

                            addPage.operationCompleted();
                        }
                    }
                }
            }
        }
    }
}
