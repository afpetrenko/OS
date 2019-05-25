# Отчет по лабораторной работе №2

### Используемые утилиты
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

### Лабораторная работа состоит из 3-х частей:

* настройка работоспособной системы с использованием lvm, raid
* эмуляция отказа одного из дисков
* замена дисков на лету, с добавлением новых дисков и переносом разделов.

## Задание 1 (Установка ОС и настройка LVM, RAID)

Создаем виртуальную машину на debian, с двумя твердотельными жесткими дисками ssd1, ssd2. Указываем возможность горячей замены жестких дисков в параметрах ВМ.
![1](https://github.com/afpetrenko/OS/blob/master/lab2/1.png)

Дойдя до выбор жестких дисков выбираем:
* Partitioning method: manual
После чего видим такую картину
![2](https://github.com/afpetrenko/OS/blob/master/lab2/2.png)

* Настраиваем отдельный раздел под /boot: выбираем первый диск, создаем новую таблицу разделов
 * Partition size: 512mb
 * Mount point: /boot
 * Тоже самое повторяем для второго диска, только mount point: none
* Настраиваем RAID 1
 * Выбираем свободное место на первом диске и настраиваем в качестве типа physical volume for RAID
 * Выбираем "Done setting up the partition"
 * Тоже самое делаем со вторым диском
В итоге получаем:
    * Create MD device
![3](https://github.com/afpetrenko/OS/blob/master/lab2/3.png)

* Выбираем пункт "Configure software RAID"
 * Software RAID device type: Выбираем зеркальный массив
 * Active devices for the RAID XXXX array: Выбираем оба диска
 * Spare devices: 0 по умолчанию
 * Active devices for the RAID XX array: выбираем оба раздела
 * Finish
 
Настраиваем LVM configuration, выбрав Display configuration details видим
![4](https://github.com/afpetrenko/OS/blob/master/lab2/4.png)

Завершив LVM настройку видим:
![6](https://github.com/afpetrenko/OS/blob/master/lab2/6.png)

Размечаем каждый раздел по очереди.

После завершения установки, запускаем нашу виртуальную машину.
Выполняем копирование содержимого раздела /boot с диска sda на диск sdb.
```
dd if=/dev/sda1 of=/dev/sdb1
```
![7](https://github.com/afpetrenko/OS/blob/master/lab2/7.png)

Выводим информацию о дисках
```
fdisk -l
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
```
Вывела нам sda(1-2) - ssd1
sdb(1-2) - ssd2

Устанавливаем grub
```
grub-install /dev/xxx
```
![8](https://github.com/afpetrenko/OS/blob/master/lab2/8.png)

Команда
```
cat /proc/mdstat
```
Выдала нам что активен зеркальный RAID на дисках sda sdb (ssd1, ssd2 соответсвенно)
![9](https://github.com/afpetrenko/OS/blob/master/lab2/9.png)

Команды pvs, vgs, lvs
Выдали нам информацию о атибутах состояния физических, групп томов и логических томов.
![10](https://github.com/afpetrenko/OS/blob/master/lab2/10.png)

Команда mount
Выдала что в качестве корневой папки sda выступает /boot и ее параметры. Информацию о примонтированных устройствах.
![11](https://github.com/afpetrenko/OS/blob/master/lab2/11.png)

### Вывод
Создали и настроили виртуальную машину на Debian с программным зеркальным RAID.
Воспользовались некоторым командами для просмотра информации по дискам.

## Задание 2 (Эмуляция отказа одного из дисков)

Удаляем жесткий диск в свойствах виртуальной машины, и с помощью команды
```
cat /proc/mdstat
```
Видим что активен RAID 1 но уже только с одним диском sdb
![21](https://github.com/afpetrenko/OS/blob/master/lab2/21.png)

С помощью
```
lsblk
```
Видим что появился новый sda диск
![22](https://github.com/afpetrenko/OS/blob/master/lab2/22.png)

Копируем таблицу разделов с старого диска на новый
```
sfdisk -f /dev/sdb | sfdisk /dev/sda
```
![24](https://github.com/afpetrenko/OS/blob/master/lab2/24.png)

Проверяем результат с помощью
```
lsblk
```
Видим что новый диск sda размечен как и sdb
И добавляем новый диск в RAID
```
mdadm --manage /dev/md0 --add /dev/sda2
```
![25](https://github.com/afpetrenko/OS/blob/master/lab2/25.png)

Выводим инфорамцию о активном RAID sda sdb
```
cat /proc/mdstat
```
![26](https://github.com/afpetrenko/OS/blob/master/lab2/26.png)

Выполняем синхронизацию кадров
```
dd if=/dev/sdb1 of=/dev/sda1
```
![27](https://github.com/afpetrenko/OS/blob/master/lab2/27.png)

Еще раз проверяем инфорамцию о дисках и RAID. Устанавливаем grub на новый диск.
```
grub-install /dev/sda
```
![28](https://github.com/afpetrenko/OS/blob/master/lab2/28.png)

### Вывод
Собственноручно провели горячую замену жесткого диска, и установили новый диск в зеркальный RAID массив в паре с старым диском. Изучили новые команды.






 

