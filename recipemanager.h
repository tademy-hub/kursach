#ifndef RECIPEMANAGER_H
#define RECIPEMANAGER_H

#include <QSqlQueryModel>
#include <QSqlDatabase>
#include <QVariantMap>

class RecipeManager : public QSqlQueryModel
{
    Q_OBJECT

public:

    enum RecipeRoles {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        CategoryRole,
        DescRole
    };

    explicit RecipeManager(QObject *parent = nullptr);
    ~RecipeManager();


    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE void readRecipes(const QString &searchQuery = "", const QString &category = "Всі");
    Q_INVOKABLE void addRecipe(const QString &title, const QString &category, const QString &description);
    Q_INVOKABLE void deleteRecipe(int id);
    Q_INVOKABLE void updateRecipe(int id, const QString &title, const QString &category, const QString &description);
    Q_INVOKABLE QVariantMap getRecipeById(int id);

private:

    QSqlDatabase m_db;
    void initDatabase();
};


#endif
