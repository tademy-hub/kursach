cmake_minimum_required(VERSION 3.16)

project(RecipeManager VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17) # Додано стандарт C++
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Додано компонент Sql сюди
find_package(Qt6 REQUIRED COMPONENTS Quick Sql)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appRecipeManager
    main.cpp
)

# Виправлено структуру QML модуля
qt_add_qml_module(appRecipeManager
    URI RecipeManager
    VERSION 1.0
    QML_FILES
        Main.qml
        Card.qml
    SOURCES
        recipemanager.h
        recipemanager.cpp
        QML_FILES MainScreen.qml
        QML_FILES DetailScreen.qml
        QML_FILES AddScreen.qml
    RESOURCES
            icons/delete.png
            icons/plus.png
            icons/plus_ingr.png
            icons/back.png
            icons/edit.png
            icons/close.png
            icons/camera.png
            icons/remove_item.png
            icons/save.png
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appRecipeManager PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appRecipeManager
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# Лінкуємо додаток із Quick та Sql
target_link_libraries(appRecipeManager
    PRIVATE
        Qt6::Quick
        Qt6::Sql
)

include(GNUInstallDirs)
install(TARGETS appRecipeManager
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
