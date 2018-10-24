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
