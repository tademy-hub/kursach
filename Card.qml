import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: card

    property string title: ""
    property string category: ""
    property string imageSource: ""

    signal clicked()
    signal deleteClicked()

    color: "white"
    radius: 12
    border.color: "gray"
    border.width: 1
    clip: true

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: card.clicked()

    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: "lightgray"

            Image {
                anchors.fill: parent
                source: card.imageSource
                fillMode: Image.PreserveAspectCrop
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4

                Text {
                    width: parent.width
                    text: card.title
                    font.bold: true
                    font.pixelSize: 16
                    color: "darkblue"
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }


                Text {
                    width: parent.width
                    text: card.category
                    font.pixelSize: 10
                    font.bold: true
                    color: "lightgreen"
                }
            }

            Rectangle {

                id: deleteBtn
                width: 30
                height: 30
                radius: 8
                color: deleteMouse.containsMouse ? "lightgray" : "transparent"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 8
                z: 10

                Image {
                    source: "icons/delete.png"
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    fillMode: Image.PreserveAspectFit
                    opacity: deleteMouse.containsMouse ? 1.0 : 0.5
                }

                MouseArea {

                    id: deleteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        card.deleteClicked();
                    }
                }
            }
        }
    }
}
