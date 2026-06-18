#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "recipemanager.h"

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QGuiApplication app(argc, argv);

    qmlRegisterType<RecipeManager>("RecipeManager", 1, 0, "RecipeManager");

    QQmlApplicationEngine engine;

    const QUrl url(u"qrc:/qt/qml/RecipeManager/Main.qml"_s);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
