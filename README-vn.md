# jenkins-labs

## Môi trường thử nghiệm:
- Windows 11
- VMWare Workstation Pro 17
- Vagrant với plugin [vmware_desktop](https://github.com/hashicorp/vagrant-vmware-desktop)

## Cài đặt:
Để tạo máy ảo
```
cd .\vmware\
vagrant validate

# Nếu Vagrantfile không lỗi thì run
vagrant up
```

## Giải thích:
### File `debian/optimizer.sh`
File cần phải được chạy dưới user `root` thì mới được quyền thực thi.   


