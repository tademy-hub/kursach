import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: detailRoot

    property int recipeId: -1
    property string recipeTitle: ""
    property string recipeCategory: ""
    property var ingredientsList: []
    property string recipeSteps: ""

    signal backClicked()
    signal editClicked()

    function refreshData() {

        if (recipeId !== -1) {
            var data = recipeManager.getRecipeById(recipeId);
            if (data) {
                recipeTitle = data.title;
                recipeCategory = data.category;
                var cleanDesc = data.description.split("IMG:")[0];
                try {
                    var json = JSON.parse(cleanDesc);
                    ingredientsList = json.ingredients;
                    recipeSteps = json.steps;
                } catch(e) {
                    recipeSteps = cleanDesc;
                    ingredientsList = [];
                }
            }
        }
    }

    onRecipeIdChanged: refreshData()

    background: Rectangle { color: "white" }

    header: ToolBar {
        implicitHeight: 60
        background: Rectangle { color: "lightgreen" }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 10

            Rectangle {

                width: 100
                height: 40
                radius: 8
                color: backMouse.containsMouse ? "lightgray" : "white"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Image {

                        source: "icons/back.png"
                        width: 16
                        height: 16
                        fillMode: Image.PreserveAspectFit
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                    }
                    Text {
                        text: "Назад"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: 16
                    }
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: detailRoot.backClicked()
                }
            }

            Label {
                text: recipeTitle
                font.pixelSize: 18
                color: "white"
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            Rectangle {

                width: 120
                height: 40
                radius: 8
                color: editMouse.containsMouse ? "lightgray" : "white"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Image {
                        source: "icons/edit.png"
                        width: 16
                        height: 16
                        fillMode: Image.PreserveAspectFit
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                    }
                    Text {
                        text: "Редагувати"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: 16
                    }
                }

                MouseArea {
                    id: editMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: detailRoot.editClicked()
                }
            }
        }
    }

    ScrollView {

        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        topPadding: 25
        bottomPadding: 40

        ColumnLayout {
            width: Math.min(parent.width - 40, 850)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 350
                radius: 16
                clip: true

                Image {

                    anchors.fill: parent
                    source: recipeId !== -1 ? recipeManager.getRecipeById(recipeId).description.split("IMG:")[1] || "" : ""
                    fillMode: Image.PreserveAspectCrop
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 16
                    width: categoryLabel.width + 20
                    height: 30
                    radius: 16
                    color: "white"
                    opacity: 0.9

                    Label {
                        id: categoryLabel
                        anchors.centerIn: parent
                        text: recipeCategory
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: 12
                    }
                }
            }

            Rectangle {

                Layout.fillWidth: true
                implicitHeight: 60
                radius: 10
                color: "white"
                border.color: "gray"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16

                    Label {
                        text: "Кількість порцій:"
                        font.bold: true
                        color: "darkblue"
                        font.pixelSize: 16
                    }

                    Item { Layout.fillWidth: true }

                    SpinBox {
                        id: portionSpin
                        from: 1; to: 20; value: 1
                        editable: true
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: "Необхідні інгредієнти:"
                    font.bold: true
                    font.pixelSize: 16
                    color: "darkblue"
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: ingredientsColumn.height + 30
                    radius: 10
                    color: "white"
                    border.color: "lightgray"


                    Column {
                        id: ingredientsColumn
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 16
                        spacing: 8

                        Repeater {
                            model: ingredientsList

                            delegate: RowLayout {
                                width: parent.width
                                spacing: 10

                                Rectangle {
                                    width: 6; height: 6; radius: 3; color: "lightgreen"
                                }

                                Label {
                                    text: modelData.name
                                    font.pixelSize: 16
                                    color: "darkblue"
                                    Layout.fillWidth: true
                                }

                                Label {
                                    text: (modelData.amount * portionSpin.value) + " " + modelData.unit
                                    font.bold: true
                                    font.pixelSize: 16
                                    color: "lightgreen"
                                }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {

                    text: "Покрокова інструкція:"
                    font.bold: true
                    font.pixelSize: 16
                    color: "darkblue"
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: instructionText.implicitHeight + 40
                    radius: 10
                    color: "white"
                    border.color: "lightgray"

                    Text {
                        id: instructionText
                        anchors.fill: parent
                        anchors.margins: 20
                        text: recipeSteps
                        font.pixelSize: 16
                        lineHeight: 2
                        color: "darkblue"
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}
