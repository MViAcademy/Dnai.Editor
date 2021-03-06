#ifndef DNAI_CORE_PROJECTHANDLER_H
#define DNAI_CORE_PROJECTHANDLER_H

#include <queue>

#include <QObject>

#include "dnai/project.h"
#include "entitymanager.h"

namespace dnai
{
    namespace gcore
    {
        class ProjectHandler : public QObject
        {
            Q_OBJECT

        public:
            ProjectHandler(EntityManager &manager);
            virtual ~ProjectHandler() = default;

        public:
            void setup();

        public:
            Q_INVOKABLE void create(dnai::Project *tocreate, bool save = true);

        private:
            void onCreated(QString const &name, ::core::EntityID rootEntity);
            void onCreateError(QString const &name, QString const &error);

        private:
            EntityManager &manager;
            std::queue<Project *> pendingProjects;
        };
    }
}

#endif // DNAI_CORE_PROJECTHANDLER_H
