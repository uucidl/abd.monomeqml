#include "monome_plugin_types.hpp"

#include <QtQml/qqml.h>

#define OSCPKT_OSTREAM_OUTPUT
#define _CRT_SECURE_NO_WARNINGS
#include <oscpkt/oscpkt.hh>
#include <oscpkt/udp.hh>
#undef _CRT_SECURE_NO_WARNINGS

#include <iostream>

void ControllersPlugin::registerTypes(char const *uri)
{
        qmlRegisterType<OSCServer>(uri, 1, 0, "OSCServer");
        qmlRegisterType<OSCDestination>(uri, 1, 0, "OSCDestination");
}

class OSCDestination::Impl
{
      public:
        Impl(std::string hostname, int port)
        {
                socket.connectTo(hostname, port);
        }

        void send(oscpkt::Message const &message)
        {
                if (!socket.isOk()) {
                        std::cerr << "sending socket could not be connected"
                                  << std::endl;
                        return;
                }

                oscpkt::PacketWriter writer;
                writer.init().addMessage(message);
                socket.sendPacketTo(writer.packetData(), writer.packetSize(),
                                    socket.packetOrigin());
        }

      private:
        oscpkt::UdpSocket socket;
};

OSCDestination::~OSCDestination()
{
}

QUrl OSCDestination::oscUrl() const
{
        return url;
}

void OSCDestination::setOscUrl(QUrl oscUrl)
{
        if (oscUrl.scheme() == "osc.udp") {
                url = oscUrl;
                impl = std::unique_ptr<Impl>(
                    new Impl(url.host().toStdString(), url.port()));
                emit oscUrlChanged();
        }
}

void OSCDestination::send(QString path, QVariantList payload)
{
        oscpkt::Message message(path.toStdString());
        for (auto it = payload.constBegin(); it != payload.constEnd(); ++it) {
                auto value = *it;
                auto type = static_cast<QMetaType::Type>(value.type());
                switch (type) {
                case QMetaType::Bool:
                        message.pushBool(value.toBool());
                        break;
                case QMetaType::Int:
                        message.pushInt32(value.toInt());
                        break;
                case QMetaType::Double:
                        message.pushDouble(value.toDouble());
                        break;
                case QMetaType::QString:
                        message.pushStr(value.toString().toStdString());
                        break;
                case QMetaType::Float:
                        message.pushFloat(value.toFloat());
                        break;
                default:
                        std::cerr << "ignoring unhandled type: "
                                  << value.typeName()
                                  << "in message: " << message << std::endl;
                        break;
                }
        }

        if (!impl) {
                std::cerr << "not connected to any server ("
                          << url.toString().toStdString() << ")" << std::endl;
                return;
        }

        impl->send(message);
}

int OSCServer::port() const
{
        return serverPort;
}

void OSCServer::setPort(int port)
{
        this->serverPort = port;
        serverThread =
            std::unique_ptr<OSCServerThread>(new OSCServerThread(port));
        connect(serverThread.get(), SIGNAL(messageIn(QVariant)), this,
                SLOT(gotMessageInFromNetwork(QVariant)));
}

void OSCServer::gotMessageInFromNetwork(QVariant data)
{
        emit messageIn(data);
}

OSCServerThread::OSCServerThread(int port) : port(port), mustQuit(false)
{
        setObjectName("OSCServerThread");
        start();
}

OSCServerThread::~OSCServerThread()
{
        mustQuit = true;
        wait();
}

void OSCServerThread::run()
{
        oscpkt::UdpSocket server;
        server.bindTo(this->port);
        if (!server.isOk()) {
                std::cerr << "Error opening OSC server at " << port
                          << std::endl;
                return;
        }

        std::cout << "Started OSC Server at " << port << std::endl;

        oscpkt::PacketReader reader;
        oscpkt::PacketWriter writer;
        while (server.isOk() && !mustQuit) {
                if (server.receiveNextPacket(30)) {
                        reader.init(server.packetData(), server.packetSize());
                        oscpkt::Message *msg;
                        while (reader.isOk() &&
                               (msg = reader.popMessage()) != 0) {
                                QVariantList message;
                                message.append(QString::fromStdString(
                                    msg->addressPattern()));
                                auto args = msg->arg();
                                while (!args.isOkNoMoreArgs()) {
                                        if (args.isInt32()) {
                                                int32_t i;
                                                args = args.popInt32(i);
                                                message.append(i);
                                        } else if (args.isInt64()) {
                                                int64_t i;
                                                args = args.popInt64(i);
                                                message.append(static_cast<qlonglong>(i));
                                        } else if (args.isFloat()) {
                                                float f;
                                                args = args.popFloat(f);
                                                message.append(f);
                                        } else if (args.isDouble()) {
                                                double d;
                                                args = args.popDouble(d);
                                                message.append(d);
                                        } else if (args.isStr()) {
                                                std::string s;
                                                args = args.popStr(s);
                                                message.append(
                                                    QString::fromStdString(s));
                                        }
                                }
                                emit messageIn(message);
                        }
                }
        }
}
