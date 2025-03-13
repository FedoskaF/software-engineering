workspace {
    name "Τήχνος"
    description "Τήχνος - приложение для управления проектами"

    !identifiers hierarchical

    model {

        user = person "Пользователь" {
            description "Штатный сотрудник, которому необходим список задач"
        }
        
        project_manager = person "Проджект-менеджер"  {
            description "Проджект-менеджер, который создаёт проекты и задачи к ним"
        }
        
        project_system = softwareSystem "Τήχνος" {
            group "Хранение данных" {
                db_project = container "База данных проектов" {
                    description "Хранение данных о проектах и задачах" 
                    technology "PostgreSQL"
                    tags "database"
                }
                
                db_user = container "База данных пользователей" {
                    description "Хранение данных о пользователях" 
                    technology "PostgreSQL"
                    tags "database"
                }
            }
            
            user_service = container "Система управления пользователями" {
                description "Обработка запросов, связанных с пользователями" 
                technology "Python"
            }

            project_service = container "Система управления проектами" {
                description "Обработка запросов, связанных с проектами" 
                technology "Python"
                -> db_project "Получает и сохраняет информацию о проекте"
            }
            
            tasks_service = container "Система управления задачами" {
                description "Обработка запросов, связанных с задачами выбранного проекта" 
                technology "Python"
                -> db_project "Получает и сохраняет информацию по задачам проекта"
            }
            
        }

        user -> project_system.user_service "Использует для получения списка задач доступного ему проекта"
        project_manager -> project_system.user_service "Использует для получения списка проектов и его задач"
        
        project_system.user_service -> project_system.db_user "Читает и записывает данные о пользователях"
        project_system.user_service -> project_system.project_service "Получает информацию о проектах"
        project_system.user_service -> project_system.tasks_service "Получает информацию о задачах проекта, доступного пользователю"

    }

    views {

        themes default
        styles {
            element "database" {
                shape cylinder
            }
        }
        
        systemContext project_system "Context" {
            include *
            autoLayout lr
        }
        
        container project_system "Container" {
            include *
            autoLayout lr
        }

        dynamic project_system "uc01" "Создание нового пользователя" {
            autoLayout
            user -> project_system.user_service "Создать нового пользователя (POST)"
            project_system.user_service -> project_system.db_user "Сохранить данные о пользователе"
        }
    
        dynamic project_system "uc02" "Поиск пользователя по логину" {
            autoLayout
            project_manager -> project_system.user_service "Найти пользователя (GET)"
            project_system.user_service -> project_system.db_user "Найти данные о пользователе"
        }
    
        dynamic project_system "uc03" "Поиск пользователя по имени и фамилии" {
            autoLayout
            project_manager -> project_system.user_service "Найти пользователя (GET)"
            project_system.user_service -> project_system.db_user "Найти данные о пользователе"
        }
    
        dynamic project_system "uc04" "Создание проекта" {
            autoLayout
            project_manager -> project_system.user_service "Создать новый проект (POST)"
            project_system.user_service -> project_system.project_service "Передать данные о проекте"
            project_system.project_service -> project_system.db_project "Сохранить данные о проекте"
        }
    
        dynamic project_system "uc05" "Поиск проекта по имени" {
            autoLayout
            user -> project_system.user_service "Найти проект (GET)"
            project_system.user_service -> project_system.project_service "Передать запрос на поиск проекта"
            project_system.project_service -> project_system.db_project "Получить данные о проекте"
        }
    
        dynamic project_system "uc06" "Поиск всех проектов" {
            autoLayout
            project_manager -> project_system.user_service "Получить список проектов (GET)"
            project_system.user_service -> project_system.project_service "Передать запрос на получение всех проектов"
            project_system.project_service -> project_system.db_project "Собрать данные обо всех проектах"
        }
    
        dynamic project_system "uc07" "Создание задачи в проекте" {
            autoLayout
            project_manager -> project_system.user_service "Создать задачу (POST)"
            project_system.user_service -> project_system.tasks_service "Передать данные о задаче"
            project_system.tasks_service -> project_system.db_project "Сохранить данные о задаче"
        }
    
        dynamic project_system "uc08" "Получение всех задач в проекте" {
            autoLayout
            user -> project_system.user_service "Получить список задач (GET)"
            project_system.user_service -> project_system.tasks_service "Передать запрос на получение списка задач"
            project_system.tasks_service -> project_system.db_project "Получить данные обо всех задачах проекта"
        }
    
        dynamic project_system "uc09" "Получение задачи по коду" {
            autoLayout
            user -> project_system.user_service "Получить задачу (GET)"
            project_system.user_service -> project_system.tasks_service "Передать запрос на получение задачи"
            project_system.tasks_service -> project_system.db_project "Получить данные о задаче по её коду"
        }

    }
    
}
