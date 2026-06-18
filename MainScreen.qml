import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: mainPage
    property string selectedCategory: "Всі"

    signal addRecipeClicked()
    signal recipeSelected(int recipeId)

    function getManager() {
        return typeof recipeManager !== "undefined" ? recipeManager : window.recipeManager;
    }

    function getRecipeData(desc, type) {
        var parts = String(desc).split("IMG:")
        return type === "img" ? (parts[1] || "") : parts[0]
    }

    header: ToolBar {
        implicitHeight: 65
        background: Rectangle { color: "lightgreen" }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            Label {
                text: "Кулінарна книга"
                font.pixelSize: 24
                color: "white"
                font.bold: true
            }
        }
    }

    background: Rectangle { color: "white" }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: "Знайти страву за назвою"
            font.pixelSize: 16
            leftPadding: 5
            verticalAlignment: TextInput.AlignVCenter
            background: Rectangle {
                implicitHeight: 40
                color: "white"
                radius: 10
                border.color: searchField.activeFocus ? "green" : "lightgreen"
                border.width: 2
            }
            onTextEdited: getManager().readRecipes(text, selectedCategory)
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Row {
                spacing: 8
                Repeater {
                    model: ["Всі", "Супи", "Основні", "Салати", "Десерти", "Випічка"]

                    Rectangle {
                        implicitWidth: 100
                        implicitHeight: 30
                        radius: 16

                        color: selectedCategory === modelData ? "lightgreen" : "white"

                        Label {
                            text: modelData
                            color: selectedCategory === modelData ? "white" : "gray"
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                selectedCategory = modelData;
                                getManager().readRecipes(searchField.text, selectedCategory);
                            }
                        }
                    }
                }
            }
        }

        GridView {
            id: recipesGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: getManager()
            clip: true
            cellWidth: 250
            cellHeight: 200

            delegate: Item {
                width: 240
                height: 200

                Card {
                    anchors.fill: parent
                    title: model.title
                    category: model.category
                    imageSource: mainPage.getRecipeData(model.description, "img")

                    onClicked: mainPage.recipeSelected(model.id)
                    onDeleteClicked: getManager().deleteRecipe(model.id)
                }
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 25
        width: 60
        height: 60
        radius: 25
        color: plusMouse.containsMouse ? "green" : "lightgreen"

        Image {
            source: "icons/plus.png"
            anchors.centerIn: parent
            width: 25
            height: 25
            fillMode: Image.PreserveAspectFit
        }

        MouseArea {

            id: plusMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mainPage.addRecipeClicked()
        }
    }
}
