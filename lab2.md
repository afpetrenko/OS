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

## Задание 3 (Добавление новых дисков и перенос раздела)

Отключаем один жесткий диск (эмуляция отказа), смотрим состояние дисков
```
cat /proc/mdstat
```
Видим RAID активен на одном диске sda
```
lsblk
```
Информация также выведена только об одном диске sda
![300](https://github.com/afpetrenko/OS/blob/master/lab2/300.png)

На ходу подключаем новый диск, проверяем.
Диск sdb появился в выводе.
![301](https://github.com/afpetrenko/OS/blob/master/lab2/301.png)

При помощи
```
sfdisk -d /dev/sda | sfdisk /dev/sdb
```
Переносим файловую таблицу на новый диск
Выполняем команду
```
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
```
Видим что новый диск sdb разметился как и старый sda на две части: sdb1, sdb2.
![302](https://github.com/afpetrenko/OS/blob/master/lab2/302.png)

Выполняем команду
```
dd if=/dev/sda1 of=/dev/sdb1
```
Копируем данные /boot на новый диск
![303](https://github.com/afpetrenko/OS/blob/master/lab2/303.png))

```
mount | grep boot
```
Видим что /boot смонтирован на sda1
```
umount /boot
```
Отмонтировали /boot
```
mount -a
```
Монтирование точек согласно /etc/fstab
Перемонтировали /boot на sdb1
![304](https://github.com/afpetrenko/OS/blob/master/lab2/304.png)

Ставим grub
![305](https://github.com/afpetrenko/OS/blob/master/lab2/301.png)

Создаем RAID массив с включением одного нового диска
```
mdadm --create --verbose /dev/md63 --level=1 --raid-devices /dev/sdb2
```
Выполняем
```
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
```
На sdb2 появился md63
![307](https://github.com/afpetrenko/OS/blob/master/lab2/307.png)

Выводим информацию о физических томах
```
pvs
```
Создаем новый физический том, включаем в него созданный RAID массив
```
pvcreate /dev/md63
```
![309](https://github.com/afpetrenko/OS/blob/master/lab2/309.png)

Выполняем lsblk и pvs.
В FSTYPE md63 теперь указано LVM2_member и /dev/md63 добавился к выводу pvs.
Увеличим размер volume group system
```
vgextend system /dev/md63
```
![312](https://github.com/afpetrenko/OS/blob/master/lab2/312.png)

Выполняем
```
vgdisplay system -v
pvs
vgs
lvs -a -o+devices
```
Видим, теперь LV var, log, root находятся на /dev/md0
![313](https://github.com/afpetrenko/OS/blob/master/lab2/313.png)
![314](https://github.com/afpetrenko/OS/blob/master/lab2/314.png)

Переносим данных со старого диска на новый для всех logical volume
```
pvmove -i 10 -n /dev/system/root /dev/md0 /dev/md63
```
![315](https://github.com/afpetrenko/OS/blob/master/lab2/315.png)

Выполняем 
```
vgdisplay system -v
pvs
vgs
lvs -a -o+devices
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
```
![316](https://github.com/afpetrenko/OS/blob/master/lab2/316.png)
![317](https://github.com/afpetrenko/OS/blob/master/lab2/317.png)

Меняем VG, удалив из него диск старого RAID
```
vgreduce system /dev/md0
```
![318](https://github.com/afpetrenko/OS/blob/master/lab2/318.png)

Выполняем
```
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
pvs
vgs
```
В выводе pvs исчез VG, Attr.
В выводе vgs уменьшились значения PV, VSize, VFree.
![319](https://github.com/afpetrenko/OS/blob/master/lab2/319.png)

Перемонтировали /boot добавили новые диски sdb, sdc, sdd
```
fdisk -l
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
```
![321](https://github.com/afpetrenko/OS/blob/master/lab2/321.png)

Копируем таблицу разделов
```
sfdisk -d /dev/sda | sfdisk /dev/sdb
```
![322](https://github.com/afpetrenko/OS/blob/master/lab2/322.png)

Копируем загрузочный раздел /boot с ssd4 на ssd5
```
dd if=/dev/sda1 of=/dev/sdb1
```
![323](https://github.com/afpetrenko/OS/blob/master/lab2/323.png)

Ставим grub
Меняем размер диска ssd5
![324](https://github.com/afpetrenko/OS/blob/master/lab2/324.png)
![325](https://github.com/afpetrenko/OS/blob/master/lab2/325.png)
![326](https://github.com/afpetrenko/OS/blob/master/lab2/326.png)
![327](https://github.com/afpetrenko/OS/blob/master/lab2/327.png)

Перечитаем таблице разделов
```
partx -u /dev/sdb
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
```
![328](https://github.com/afpetrenko/OS/blob/master/lab2/328.png)

Добавим новый диск к текущему RAID массиву
```
mdadm --manage /dev/md63 --add /dev/sdb2
```
![329](https://github.com/afpetrenko/OS/blob/master/lab2/329.png)

Расширим кол-во дисков в нашем массиве до 2-х штук
![330](https://github.com/afpetrenko/OS/blob/master/lab2/330.png)

Увеличение размера раздела на диске ssd4
```
fdisk /dev/sda
```
![331](https://github.com/afpetrenko/OS/blob/master/lab2/331.png)

Перечитаем таблицу разделов
```
partx -u /dev/sda
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
```
![332](https://github.com/afpetrenko/OS/blob/master/lab2/332.png)

Расширим RAID
```
mdadm --grow /dev/md63 --size=max
```
Размер md127 в выводе lsblk стал 7.5G
![333](https://github.com/afpetrenko/OS/blob/master/lab2/332.png)

Вывод pvs
```
pvs
```
Расширяем размер PV
```
pvresize /dev/md63
```
![334](https://github.com/afpetrenko/OS/blob/master/lab2/334.png)

Добавим появившееся место VG var, root
```
lvs
lvextend -l +50%FREE /dev/system/root
lvextend -l +100%FREE /dev/system/var
lvs
```
![335](https://github.com/afpetrenko/OS/blob/master/lab2/335.png)

Посмотрим имена новых HDD дисков
```
fdisk -l
```
![336](https://github.com/afpetrenko/OS/blob/master/lab2/336.png)

Создаем RAID массив
```
mdadm --create /dev/md127 --level=1 --raid-devices=2 /dev/sdc /dev/sdd
```
![337](https://github.com/afpetrenko/OS/blob/master/lab2/337.png)

Создаем новый PV на рейде из больших дисков
Создаем в этом PV группу с названием data
Создаем логический том размером всего свободного пространства и назовем его val_log
```
pvcreate data /dev/md127
vgcreate data /dev/md127
lvcreate -l 100%FREE -n var_log data
```
![338](https://github.com/afpetrenko/OS/blob/master/lab2/338.png)

Отформатируем созданные раздел в ext4
```
mkfs.ext4 /dev/mapper/data-var_log
```
![339](https://github.com/afpetrenko/OS/blob/master/lab2/339.png)

Перенос данных логов со старого раздела на новый
Примонтируем временно новое хранилище логов
```
mount /dev/mapper/data-var_log /mnt
```
![340](https://github.com/afpetrenko/OS/blob/master/lab2/340.png)

Синхронизируем разделы
```
apt install rsync
rsync -avzr /var/log/ /mnt/
```
![341](https://github.com/afpetrenko/OS/blob/master/lab2/341.png)
![342](https://github.com/afpetrenko/OS/blob/master/lab2/342.png)

Выясним какие процессы работают сейчас с /var/log
```
apt install lsof
lsof | grep '/var/log'
```
![343](https://github.com/afpetrenko/OS/blob/master/lab2/343.png)

Остановим эти процессы
Выполним финальную синхронизацию разделов
```
systemctl stop rsyslog.service syslog.socket
rsync -avzr /var/log/ /mnt/
```
![344](https://github.com/afpetrenko/OS/blob/master/lab2/344.png)

Поменяем местами разделы
```
umount /mnt
umount /var/log
mount /dev/mapper/data-var_log /var/log
```
![345](https://github.com/afpetrenko/OS/blob/master/lab2/345.png)

Правим /etc/fstab fstab
![346](https://github.com/afpetrenko/OS/blob/master/lab2/346.png)

Перезагружаем машину и проверяем
```
pvs
lvs
vgs
lsblk
cat /proc/mdstat
```
![347](https://github.com/afpetrenko/OS/blob/master/lab2/347.png)
![348](https://github.com/afpetrenko/OS/blob/master/lab2/348.png)









 

