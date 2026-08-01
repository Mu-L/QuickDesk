#pragma once

#include <QObject>
#include <QVariantMap>

namespace quickdesk {

class ScreenGeometryProvider : public QObject {
    Q_OBJECT

public:
    explicit ScreenGeometryProvider(QObject* parent = nullptr);

    static ScreenGeometryProvider& instance();

    Q_INVOKABLE QVariantMap availableGeometryForWindow(QObject* windowObject) const;
    Q_INVOKABLE QVariantMap frameMarginsForWindow(QObject* windowObject) const;
};

}
