# jenkins-labs

## Môi trường thử nghiệm
- Windows 11
- VMWare Workstation Pro 17
- Vagrant với plugin [vmware_desktop](https://github.com/hashicorp/vagrant-vmware-desktop)

## Cài đặt
Để tạo máy ảo
```
cd .\vmware\
vagrant validate

# Nếu Vagrantfile không lỗi thì run
vagrant up
```

## Giải thích
### File `debian/optimizer.sh`
File cần phải được chạy dưới user `root` thì mới được quyền thực thi.   

## Chạy Jenkins trên Docker
Vào folder docker/jenkins và chạy lệnh
```
docker build . -t jenkins-docker
docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins-docker

```

