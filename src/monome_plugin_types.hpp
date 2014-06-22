#pragma once

#include <QtCore/QList>
#include <QtCore/QObject>
#include <QtCore/QThread>
#include <QtCore/QUrl>
#include <QtCore/QVariant>
#include <QtQml/QQmlExtensionPlugin>

#include <memory>

class ControllersPlugin : public QQmlExtensionPlugin
{
        Q_OBJECT;
        Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface");

      public:
        void registerTypes(char const *uri);
};

class OSCDestination : public QObject
{
        Q_OBJECT;

        Q_PROPERTY(QUrl oscUrl READ oscUrl WRITE setOscUrl NOTIFY
                       oscUrlChanged);

        QUrl oscUrl() const;
        void setOscUrl(QUrl url);

      public:
        ~OSCDestination();
        Q_INVOKABLE void send(QString path, QVariantList payload);

signals:
        void oscUrlChanged();

      private:
        QUrl url;

        class Impl;
        std::unique_ptr<Impl> impl;
};

class OSCServerThread : public QThread
{
        Q_OBJECT;

      public:
        OSCServerThread(int port);
        ~OSCServerThread();
        void run() Q_DECL_OVERRIDE;

signals:
        void messageIn(QVariant message);

      private:
        int port;
        bool mustQuit;
};

class OSCServer : public QObject
{
        Q_OBJECT;

        Q_PROPERTY(int port READ port WRITE setPort);

        int port() const;
        void setPort(int port);

      public
slots:
        void gotMessageInFromNetwork(QVariant data);

signals:
        void messageIn(QVariant data);

      private:
        int serverPort;
        std::unique_ptr<OSCServerThread> serverThread;
};
