

```sh
[root@Linux2-01 azureadmin]# dmesg | grep SCSI
[    0.447201] SCSI subsystem initialized
[    2.533851] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 248)
[    9.069344] sd 3:0:1:0: [sdb] Attached SCSI disk
[    9.853065] sd 2:0:0:0: [sda] Attached SCSI disk

[   10.108646] sd 5:0:0:3: [sdd] Attached SCSI disk
[   10.152726] sd 5:0:0:1: [sde] Attached SCSI disk
[   10.180439] sd 5:0:0:2: [sdf] Attached SCSI disk
[   10.204257] sd 5:0:0:0: [sdc] Attached SCSI disk



[root@Linux2-01 azureadmin]# fdisk /dev/sdc
[root@Linux2-01 azureadmin]# mkfs -t ext4 /dev/sdc1
...
[root@Linux2-01 azureadmin]# fdisk /dev/sdf
[root@Linux2-01 azureadmin]# mkfs -t ext4 /dev/sdf1


[root@Linux2-01 azureadmin]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
fd0      2:0    1    4K  0 disk
sda      8:0    0   30G  0 disk
├─sda1   8:1    0  500M  0 part /boot
└─sda2   8:2    0 29.5G  0 part /
sdb      8:16   0   16G  0 disk
└─sdb1   8:17   0   16G  0 part /mnt/resource
sdc      8:32   0 1023G  0 disk
└─sdc1   8:33   0 1023G  0 part
sdd      8:48   0 1023G  0 disk
└─sdd1   8:49   0 1023G  0 part
sde      8:64   0 1023G  0 disk
└─sde1   8:65   0 1023G  0 part
sdf      8:80   0 1023G  0 disk
└─sdf1   8:81   0 1023G  0 part

[root@Linux2-01 azureadmin]# mdadm --create /dev/md0 --level 0 --raid-devices 4 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1
mdadm: /dev/sdc1 appears to contain an ext2fs file system
       size=1072692224K  mtime=Thu Jan  1 00:00:00 1970
mdadm: /dev/sdd1 appears to contain an ext2fs file system
       size=1072692224K  mtime=Thu Jan  1 00:00:00 1970
mdadm: /dev/sde1 appears to contain an ext2fs file system
       size=1072692224K  mtime=Thu Jan  1 00:00:00 1970
mdadm: /dev/sdf1 appears to contain an ext2fs file system
       size=1072692224K  mtime=Thu Jan  1 00:00:00 1970
Continue creating array? yes
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.


[root@Linux2-01 azureadmin]# lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
fd0       2:0    1    4K  0 disk
sda       8:0    0   30G  0 disk
├─sda1    8:1    0  500M  0 part  /boot
└─sda2    8:2    0 29.5G  0 part  /
sdb       8:16   0   16G  0 disk
└─sdb1    8:17   0   16G  0 part  /mnt/resource
sdc       8:32   0 1023G  0 disk
└─sdc1    8:33   0 1023G  0 part
  └─md0   9:0    0    4T  0 raid0
sdd       8:48   0 1023G  0 disk
└─sdd1    8:49   0 1023G  0 part
  └─md0   9:0    0    4T  0 raid0
sde       8:64   0 1023G  0 disk
└─sde1    8:65   0 1023G  0 part
  └─md0   9:0    0    4T  0 raid0
sdf       8:80   0 1023G  0 disk
└─sdf1    8:81   0 1023G  0 part
  └─md0   9:0    0    4T  0 raid0
sr0      11:0    1  628K  0 rom


[root@Linux2-01 azureadmin]# mdadm --detail /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Tue Oct 30 04:26:02 2018
        Raid Level : raid0
        Array Size : 4290240512 (4091.49 GiB 4393.21 GB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Tue Oct 30 04:26:02 2018
             State : clean
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

        Chunk Size : 512K

Consistency Policy : none

              Name : Linux2-01:0  (local to host Linux2-01)
              UUID : 704bb478:78039166:8c91947b:87bf2c78
            Events : 0

    Number   Major   Minor   RaidDevice State
       0       8       33        0      active sync   /dev/sdc1
       1       8       49        1      active sync   /dev/sdd1
       2       8       65        2      active sync   /dev/sde1
       3       8       81        3      active sync   /dev/sdf1


[root@Linux2-01 azureadmin]# mkfs.xfs /dev/md0
meta-data=/dev/md0               isize=512    agcount=32, agsize=33517440 blks
         =                       sectsz=4096  attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=1072558080, imaxpct=5
         =                       sunit=128    swidth=512 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=521728, version=2
         =                       sectsz=4096  sunit=1 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0


[root@Linux2-01 azureadmin]# mkdir /data
[root@Linux2-01 azureadmin]# /sbin/blkid
...
/dev/md0: UUID="7c7a9a0b-6a72-4063-9999-f2ace35169ef" TYPE="xfs"

[root@Linux2-01 azureadmin]# vi /etc/fstab

UUID=7c7a9a0b-6a72-4063-9999-f2ace35169ef /data                   xfs     defaults,nofail        0 2

[root@Linux2-01 azureadmin]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Wed Aug 15 19:30:54 2018
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=12907c8a-6b2f-4981-b94c-f3cd772270a7 /                       xfs     defaults        0 0
UUID=fa2f8157-21c9-43b6-85e3-ff04422dfa00 /boot                   xfs     defaults        0 0
UUID=7c7a9a0b-6a72-4063-9999-f2ace35169ef /data                   xfs     defaults,nofail     0 2



[root@Linux2-01 azureadmin]# mount
...
/dev/md0 on /data type xfs (rw,relatime,seclabel,attr2,inode64,sunit=1024,swidth=4096,noquota)

[root@Linux2-01 azureadmin]# df -h
Filesystem      Size  Used Avail Use% Mounted on
...
/dev/md0        4.0T   34M  4.0T   1% /data

[root@Linux2-01 azureadmin]# reboot


login as: azureadmin
Using keyboard-interactive authentication.
Password:
Last login: Tue Oct 30 04:11:11 2018 from 121.141.198.143
[azureadmin@linux2-01 ~]$
[azureadmin@linux2-01 ~]$
[azureadmin@linux2-01 ~]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
...
/dev/md0        4.0T   34M  4.0T   1% /data

[azureadmin@linux2-01 ~]$
```

