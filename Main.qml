import QtQuick
import QtQuick.Controls
import RecipeManager 1.0

ApplicationWindow {
    id: window
    width: 700
    height: 750
    visible: true
    minimumWidth: 650
    minimumHeight: 750
    title: "Кулінарна книга"

    background: Rectangle { color: "white" }

    RecipeManager {
        id: recipeManager
    }

    StackView {

        id: stackView
        anchors.fill: parent
        initialItem: mainScreenComponent
    }

    function currentCategory() {
        return stackView.initialItem.selectedCategory || "Всі";
    }

    Component {
        id: mainScreenComponent
        MainScreen {

            id: mainScreen
            onAddRecipeClicked: stackView.push(addScreenComponent, {"editMode": false})
            onRecipeSelected: (recipeId) => {
                stackView.push(detailScreenComponent, {
                    "recipeId": recipeId
                });
            }
        }
    }

    Component {

        id: detailScreenComponent
        DetailScreen {
            id: detailView
            onBackClicked: {
                recipeManager.readRecipes("", currentCategory());
                stackView.pop();
            }
            onEditClicked: {
                var recipe = recipeManager.getRecipeById(detailView.recipeId);
                stackView.push(addScreenComponent, {
                    "editMode": true,
                    "recipeId": detailView.recipeId,
                    "initTitle": recipe.title,
                    "initCategory": recipe.category,
                    "initRawData": recipe.description
                });
            }
        }
    }

    Component {

        id: addScreenComponent
        AddScreen {
            onOperationCompleted: {
                recipeManager.readRecipes("", currentCategory());
                stackView.pop();
                var detail = stackView.currentItem;
                if (detail && typeof detail.refreshData === "function") {
                    detail.refreshData();
                }
            }
        }
    }
}
