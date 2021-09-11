# HomeServer

## Initial setup

### 1. install OS

Install Ubuntu 20.04 LTS

### 2. generate ssh key

Generate ssh key at another pc.

`$ ssh-keygen -t rsa -b 4096`

### 3. add public key

Add public key to HomeServer host.

`$ ssh-copy-id -i ~/.ssh/{PUBLIC_KEY} {USER}@{IP_ADDRESS}`

### 4. configure sshd

`$ sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.d/sshd.conf`

Edit `/etc/ssh/sshd_config.d/sshd.conf`

- `Port {PORT}`
- `PermitRootLogin: prohibit-password`
- `PubkeyAuthentication yes`
- `PasswordAuthentication no`

and restart sshd.

`$ sudo systemctl restart sshd.service`

### 5. configure firewalld

- `$ sudo ufw default deny incoming`
- `$ sudo ufw default allow outgoing`
- `$ sudo ufw allow from 192.168.0.0/16 to any port {SSH-PORT} proto tcp`
- `$ sudo ufw enable`

### 6. add static ip address

Make and configure `/etc/netplan/99_config.yaml`.

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: false
      dhcp6: false
      addresses: [IP_ADDRESS/24]
      gateway4: DEFAULT_GATEWAY_ADDRESS
      nameservers:
        addresses: [NAMESERVER_ADDRESS]
```

#### References

- [Network - Configuration | Ubuntu](https://ubuntu.com/server/docs/network-configuration)
- [Netplan - Reference | Backend-agnostic network configuration in YAML](https://netplan.io/reference/)

## Setup host

### 1. Install Ansible

Install Ansible to control pc.

1. `$ sudo yum install epel-release`
2. `$ sudo yum install ansible`

And install ansible plugins.

`$ ansible-galaxy collection install ansible.posix`

### 2. Make secret.yml

Make `secret.yml`

`$ cp secret.yml.template secret.yml`

Add values to `secret.yml`.

### 3. Deploy

`$ ./deploy.sh`

## Add storage

Check added storage.

    $ lsblk
    NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    loop0                       7:0    0    55M  1 loop /snap/core18/1880
    loop1                       7:1    0  71.3M  1 loop /snap/lxd/16099
    loop2                       7:2    0  55.4M  1 loop /snap/core18/1944
    loop3                       7:3    0  67.8M  1 loop /snap/lxd/18150
    loop4                       7:4    0  29.9M  1 loop /snap/snapd/8542
    loop5                       7:5    0  31.1M  1 loop /snap/snapd/10492
    sda                         8:0    0 111.8G  0 disk 
    ├─sda1                      8:1    0   512M  0 part /boot/efi
    ├─sda2                      8:2    0     1G  0 part /boot
    └─sda3                      8:3    0 110.3G  0 part 
      └─ubuntu--vg-ubuntu--lv 253:0    0 110.3G  0 lvm  /
    sdb                         8:16   0 931.5G  0 disk 

Create partition.

    $ sudo fdisk /dev/sdb
    Command (m for help): i # Check no partitions are not exist.
    Command (m for help): n
    Partition type
     p   primary (0 primary, 0 extended, 4 free)
     e   extended (container for logical partitions)
    Select (default p): p
    Partition number (1-4, default 1): 1
    First sector (2048-1953525167, default 2048): 2048
    Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-1953525167, default 1953525167): 1953525167
    
    Created a new partition 1 of type 'Linux' and of size 931.5 GiB.
    
    Command (m for help): p
    Disk /dev/sdb: 931.53 GiB, 1000204886016 bytes, 1953525168 sectors
    Disk model: Samsung SSD 860 
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x0e95907a
    
    Device     Boot Start        End    Sectors   Size Id Type
    /dev/sdb1        2048 1953525167 1953523120 931.5G 83 Linux
    
    Command (m for help): w
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.

Format storage.

    $ sudo mkfs -t ext4 /dev/sdb1
    mke2fs 1.45.5 (07-Jan-2020)
    Discarding device blocks: done
    Creating filesystem with 244190390 4k blocks and 61054976 inodes
    Filesystem UUID: 32c47853-314f-4b8a-ae93-3d9b5dd5aa77
    Superblock backups stored on blocks: 
            32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
            4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
            102400000, 214990848
    
    Allocating group tables: done
    Writing inode tables: done
    Creating journal (262144 blocks): done
    Writing superblocks and filesystem accounting information: done

Make directory for mount.

    $ sudo mkdir /mnt/storage

Check UUID.

    $ sudo blkid /dev/sdb1
    /dev/sdb1: UUID="32c47853-314f-4b8a-ae93-3d9b5dd5aa77" TYPE="ext4" PARTUUID="0e95907a-01"

Add following lines to /etc/fstab to mount automatically.

    # /mnt/storage was on /dev/sdb1 during curtin installation
    /dev/disk/by-uuid/32c47853-314f-4b8a-ae93-3d9b5dd5aa77 /mnt/storage ext4 defaults 0 0
