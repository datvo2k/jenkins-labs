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

## Chạy Jenkins trên K8S (cách sử dụng bài viết này tiếp cận)


```
Tìm ingress trong minikube
export INGRESS_HOST=minikube.$(minikube ip).nip.io; echo $INGRESS_HOST
```

```
Thực thi jenkins
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
chart=jenkinsci/jenkins
helm install jenkins -n jenkins -f jenkins-values.yaml $chart

Cài đặt netdata
helm repo add netdata https://netdata.github.io/helmchart/
helm install netdata netdata/netdata -n netdata -f netdata-values.yaml
helm upgrade netdata netdata/netdata -n netdata -f netdata-values.yaml
```

