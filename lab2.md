# Отчет по лабораторной работе №2

## Используемые утилиты
1) просмотр информации о дисках
* lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
* fdisk -l
2) просмотр информации и работа с LVM
* pvs
* pvextend
* pvcreate
* pvresize
* vgs
* vgreduce
* lvs
* lvextend
3) просмотр информации и работа с RAID
* сat /proc/mdstat
* mdadm
4) точки монтирования
* mount
* umount
* cat /etc/fstab
* cat /etc/mtab
5) переразметка диска
* fdisk /dev/XXX
6) копирование разделов
* dd if=/dev/xxx of=/dev/yyy
7) работа с таблицей разделов
* partx
* sfdisk
* mkfs.ext4
8) работа с загрузчиком
* grub-install /dev/XXX
* update-grub
9) misc
* lsof
* apt
* rsync

## Лабораторная работа состоит из 3-х частей:

* настройка работоспособной системы с использованием lvm, raid
* эмуляция отказа одного из дисков
* замена дисков на лету, с добавлением новых дисков и переносом разделов.

## Задание 1 (Установка ОС и настройка LVM, RAID)

Создаем виртуальную машину на debian, с двумя твердотельными жесткими дисками ssd1, ssd2. Указываем возможность горячей замены жестких дисков в параметрах ВМ.
![1](https://github.com/afpetrenko/OS/blob/master/lab2/1.png)

