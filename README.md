# yusorokin_infra

yusorokin Infra repository


## Homework 3
### Самостоятельное задание
Подключение к целевому хосту через бастион-хост одной командой:
```sh
$ ssh -A -J <user>@<bastion_IP> <someinternalhost_IP>
```

**Дополнительное задание**

Подключение к целевому хосту с использованием алиаса:
```sh
$ cat <<TXT > ~/.ssh/config
> Host someinternalhost
>   HostName <someinternalhost_IP>
>   ForwardAgent yes
>   ProxyJump <user>@<bastion_IP>
> TXT
$ ssh someinternalhost
```
```sh
bastion_IP = 104.155.80.250
someinternalhost_IP = 10.142.0.2
```

## Homework 4
```sh
testapp_IP = 35.189.238.37
testapp_port = 9292
```

### Дополнительное задание

**Startup-scipt из файла:**

```sh
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=./startup_script.sh
```

**Startup-scipt по ссылке:**

```sh
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url=https://gist.github.com/yusorokin/e529f16590f13b28106aaa1ea29d3ee4/raw/48acffb1c4e75df64a86c4e430974ca4fe01a95f/startup_script.sh
```

**Создание правила firewall через gcloud:**

```sh
gcloud compute firewall-rules create default-puma-server \
    --action allow \
    --target-tags puma-server \
    --source-ranges 0.0.0.0/0 \
    --rules tcp:9292
```

## Homework 5

### Основное задание
* Создан шаблон базового образа packer-base;
* Создан сам базовый образ;
* Развернут инстанс из этого образа;
* Задеплоено приложение на созданном инстансе;
* Шаблон дополнен параметрами и файлом параметров.

### Задание со *
* Создан шаблон baked образа immutable.json на основе базового образа, созданного в основном задании;
* В шаблоне использован измененный скрипт deploy.sh и новый скрипт systemd_service.sh, который создает файл сервиса puma и запускает его через systemd;
* Создан скрипт для поднятия инстанса ВМ create-redditvm.sh из созданного образа семейства reddit-full.


## Homework 6

### Задание со *
Нашел как минимум два способа добавления ключей в проект:
1. Команда:
    ```sh
    resource "google_compute_project_metadata_item" "default" {
      project = "${var.project}"
      key = "ssh-keys"
      value = "appuser1:${file(var.public_key_path)}"
    }
    ```
2. Команда:
    ```sh
    resource "google_compute_project_metadata" "default" {
      project = "${var.project}"
      metadata {
        ssh-keys = "appuser1:${file(var.public_key_path)}"
      }
    }
    ```

Добавил три ключа командой
```sh
resource "google_compute_project_metadata_item" "default" {
  project = "${var.project}"
  key = "ssh-keys"
  value = "appuser1:${file(var.public_key_path)}appuser2:${file(var.public_key_path)}appuser3:${file(var.public_key_path)}"
}
```

Добавил ключ пользователя appuser_web через веб-интерфейс. Затем применил `terraform apply`.

Какие проблемы выявил:
* *Очевидная:* Ключ appuser_web удалился;
* *Менее очевидная:* Перебрал несколько вариантов добавления нескольких ключей и получил следующие проблемы:
* * Добавляются лишние переносы строк (`\n`) после каждого ключа и еще один для последнего ключа при следующем формате:
    ```sh
    value = <<EOF
      appuser1:${file(var.public_key_path)}
      appuser2:${file(var.public_key_path)}
      appuser3:${file(var.public_key_path)}
    EOF
    ```
    Скрин https://drive.google.com/open?id=1Wj2vz1MoV2MCg4qOQWO49cNGvwl3HVhF
* * Добавляется лишь один лишний перенос строки после последнего ключа, и выглядит нечитабельно:
    ```sh
    value = "appuser1:${file(var.public_key_path)}appuser2:${file(var.public_key_path)}appuser3:${file(var.public_key_path)}"
    ```
    Скрин https://drive.google.com/open?id=1mlX2D0ERR0NKqBDCAqGqPiyVkOmsMppk
  Возможно ничего страшного в этом и нет, но выглядит странно.

### Задание с **

### Создание балансировщика веб-сервера

Для создания балансировщика потребовалось:
* Включить инстанс веб-сервера в группу инстансов google_compute_instance_group;
* Настроить для группы инстансов перенаправление трафика на порт 9292;
* Создать google_compute_health_check по порту tcp-9292 определения работающего инстанса;
* Создать google_compute_backend_service, который перенаправляет трафик на инстанс группы google_compute_instance_group в зависимости от состояния google_compute_health_check;
* Обозначить в google_compute_backend_service именованый порт port_name = "puma-9292" для перенаправления HTTP-трафика на tcp-9292, который описан в google_compute_instance_group;
* Создать правило google_compute_url_map для перенаправления всего трафика на google_compute_backend_service;
* Создать google_compute_target_http_proxy, который перенаправляет трафик исходя из правил, заданных в google_compute_url_map;
* Создать глобальное правило перенаправления трафика (google_compute_global_forwarding_rule) по HTTP, которому и присваивается внешний ip-адрес и которое перенаправляет трафик на google_compute_target_http_proxy.

Для шаблона инастанса была создана переменная count, в которой определяется количество создаваемых инстансов.

## Homework 7

### Задание со * (1)
* Настроил remote-backend в файле backends.tf, выполнил `terraform init`;
* Перенес конфигурационные файлы из terraform/prod в другую директорию, поправил пути к модулям, запустил terraform init, запустил terraform state pull. В результате загрузился удаленный стейт-файл и вывелся в stdout;
* Запустил во временной папке terraform destroy, не подтверждая действие; внес небольшие изменения в конфигурацию в исходной папке, запустил terraform apply, на что получил сообщение о блокировке стейт-файла:
  ```
  Error: Error locking state: Error acquiring the state lock: writing "gs://backend-prod-infra-777/terraform/state/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet
  ```

### Задание со * (2)
* Добавил ресурс `null_resource` для подключаемых по условию провиженеров;
* Настроил переменную для подключения провиженера, в ресурсе обозначил count, равный этой переменной;
* Настроил провиженеры:
* * Для **app**:
* * * Копирование файла сервиса puma;
* * * Запись значения `DATABASE_URL` в переменные окружения (`~/.profile`);
* * * Запуск скрипта деплоя приложения;
* * Для **db**:
* * * Команда для изменения настроек монго `bindIp: 127.0.0.1` на `bindIp: 0.0.0.0` для разрешения внешних подключений;
* * * Команда для перезапуска сервиса монго.
