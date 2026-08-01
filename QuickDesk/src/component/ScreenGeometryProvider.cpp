#include "ScreenGeometryProvider.h"

#include <QGuiApplication>
#include <QQuickWindow>
#include <QRect>
#include <QScreen>
#include <QString>

namespace quickdesk {

ScreenGeometryProvider::ScreenGeometryProvider(QObject* parent)
    : QObject(parent)
{
}

ScreenGeometryProvider& ScreenGeometryProvider::instance()
{
    static ScreenGeometryProvider provider;
    return provider;
}

QVariantMap ScreenGeometryProvider::availableGeometryForWindow(QObject* windowObject) const
{
    QScreen* screen = nullptr;

    if (auto* window = qobject_cast<QQuickWindow*>(windowObject)) {
        screen = window->screen();
    }

    if (!screen) {
        screen = QGuiApplication::primaryScreen();
    }

    QVariantMap result;
    if (!screen) {
        result["valid"] = false;
        result["x"] = 0;
        result["y"] = 0;
        result["width"] = 0;
        result["height"] = 0;
        result["screenName"] = QString();
        return result;
    }

    const QRect available = screen->availableGeometry();
    const QRect geometry = screen->geometry();

    result["valid"] = true;
    result["x"] = available.x();
    result["y"] = available.y();
    result["width"] = available.width();
    result["height"] = available.height();
    result["screenName"] = screen->name();
    result["screenX"] = geometry.x();
    result["screenY"] = geometry.y();
    result["screenWidth"] = geometry.width();
    result["screenHeight"] = geometry.height();
    result["devicePixelRatio"] = screen->devicePixelRatio();
    return result;
}

QVariantMap ScreenGeometryProvider::frameMarginsForWindow(QObject* windowObject) const
{
    QVariantMap result;
    result["valid"] = false;
    result["left"] = 0;
    result["top"] = 0;
    result["right"] = 0;
    result["bottom"] = 0;
    result["totalWidth"] = 0;
    result["totalHeight"] = 0;

    auto* window = qobject_cast<QQuickWindow*>(windowObject);
    if (!window) {
        return result;
    }

    const QRect geometry = window->geometry();
    const QRect frameGeometry = window->frameGeometry();
    if (!geometry.isValid() || !frameGeometry.isValid()) {
        return result;
    }

    const int left = geometry.left() - frameGeometry.left();
    const int top = geometry.top() - frameGeometry.top();
    const int right = (frameGeometry.x() + frameGeometry.width()) - (geometry.x() + geometry.width());
    const int bottom = (frameGeometry.y() + frameGeometry.height()) - (geometry.y() + geometry.height());

    result["valid"] = true;
    result["left"] = left;
    result["top"] = top;
    result["right"] = right;
    result["bottom"] = bottom;
    result["totalWidth"] = left + right;
    result["totalHeight"] = top + bottom;
    result["geometry"] = QString("%1,%2 %3x%4")
                             .arg(geometry.x())
                             .arg(geometry.y())
                             .arg(geometry.width())
                             .arg(geometry.height());
    result["frameGeometry"] = QString("%1,%2 %3x%4")
                                  .arg(frameGeometry.x())
                                  .arg(frameGeometry.y())
                                  .arg(frameGeometry.width())
                                  .arg(frameGeometry.height());
    return result;
}

}
