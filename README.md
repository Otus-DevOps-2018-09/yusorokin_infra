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
* Создан шаблон baked образа immutable.json на основе базового образа, созданного в основоном задании;
* В шаблоне использован измененный скрипт deploy.sh и новый скрипт systemd_service.sh, который создает файл сервиса puma и запускает его через systemd;
* Создан скрипт для поднятия инстанса ВМ create-redditvm.sh из созданного образа семейства reddit-full.
