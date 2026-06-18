#include "recipemanager.h"
#include <QSqlQuery>

RecipeManager::RecipeManager(QObject *parent) : QSqlQueryModel(parent) {
    initDatabase();
    readRecipes();

}

RecipeManager::~RecipeManager() {
    if (m_db.isOpen()) {
        m_db.close();
    }
}

void RecipeManager::initDatabase() {
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName("recipes.db");

    if (!m_db.open()) {
        return;

    }

    QSqlQuery query;
    query.exec("CREATE TABLE IF NOT EXISTS cookbook ("
    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "title TEXT, "
    "category TEXT, "
    "description TEXT)");

}

void RecipeManager::readRecipes(const QString &searchQuery, const QString &category) {
    QSqlQuery query;
    QString queryString = "SELECT id, title, category, description FROM cookbook";


    bool hasCategory = !category.isEmpty() && category != "Всі";
    bool hasSearch = !searchQuery.isEmpty();

    if (hasCategory || hasSearch) {
        queryString += " WHERE";
        if (hasCategory) {
            queryString += " category = :category";
        }
        if (hasSearch) {
            if (hasCategory) queryString += " AND";
            queryString += " (INSTR(title, :search1) > 0 OR INSTR(title, :search2) > 0 OR INSTR(title, :search3) > 0)";
        }
    }

    queryString += " ORDER BY title ASC";
    query.prepare(queryString);

    if (hasCategory) query.bindValue(":category", category);


    if (hasSearch) {
        query.bindValue(":search1", searchQuery);
        query.bindValue(":search2", searchQuery.toLower());
        QString upper = searchQuery;
        upper[0] = upper[0].toUpper();
        query.bindValue(":search3", upper);
    }

    if (query.exec()) setQuery(std::move(query));
}


void RecipeManager::addRecipe(const QString &title, const QString &category, const QString &description) {
    QSqlQuery query;
    query.prepare("INSERT INTO cookbook (title, category, description) VALUES (?, ?, ?)");
    query.addBindValue(title);
    query.addBindValue(category);
    query.addBindValue(description);

    if (query.exec()) {
        readRecipes();
    }
}

void RecipeManager::updateRecipe(int id, const QString &title, const QString &category, const QString &description) {
    QSqlQuery query;

    query.prepare("UPDATE cookbook SET title = ?, category = ?, description = ? WHERE id = ?");
    query.addBindValue(title);
    query.addBindValue(category);
    query.addBindValue(description);
    query.addBindValue(id);

    if (query.exec()) {
        readRecipes();
    }
}


void RecipeManager::deleteRecipe(int id) {
    QSqlQuery query;
    query.prepare("DELETE FROM cookbook WHERE id = ?");
    query.addBindValue(id);

    if (query.exec()) {
        readRecipes();
    }
}

QHash<int, QByteArray> RecipeManager::roleNames() const {
    QHash<int, QByteArray> roles;

    roles[IdRole] = "id";
    roles[TitleRole] = "title";
    roles[CategoryRole] = "category";
    roles[DescRole] = "description";
    return roles;
}

QVariant RecipeManager::data(const QModelIndex &index, int role) const {
    if (!index.isValid()) return QVariant();

    int columnIndex = role - Qt::UserRole - 1;
    if (columnIndex < 0 || columnIndex >= 4) return QVariant();

    return QSqlQueryModel::data(this->index(index.row(), columnIndex), Qt::DisplayRole);
}

QVariantMap RecipeManager::getRecipeById(int id) {
    QVariantMap result;

    for (int row = 0; row < rowCount(); ++row) {
        int currentId = QSqlQueryModel::data(index(row, 0), Qt::DisplayRole).toInt();
        if (currentId == id) {

            result["id"] = currentId;
            result["title"] = QSqlQueryModel::data(index(row, 1), Qt::DisplayRole).toString();
            result["category"] = QSqlQueryModel::data(index(row, 2), Qt::DisplayRole).toString();
            result["description"] = QSqlQueryModel::data(index(row, 3), Qt::DisplayRole).toString();
            break;
        }
    }
    return result;
}
