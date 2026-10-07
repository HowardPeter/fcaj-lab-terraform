# AWS Lab – Amazon Lightsail WordPress

Lab thực hành triển khai **Amazon Lightsail** bằng Terraform, bao gồm database, static IP và WordPress server cùng các cấu hình vận hành cơ bản.

🔗 **Lab hướng dẫn:** https://000045.awsstudygroup.com/

## 🎯 Mục tiêu

* Tạo **Lightsail Database**
* Tạo **Lightsail Static IP** và gán vào server
* Triển khai **Lightsail instance** chạy WordPress
* Cấu hình **firewall** cho server
* Enable **automatic snapshots** để backup
* Tạo **CPU burst alarm** để theo dõi tài nguyên server
* Quản lý và triển khai các tài nguyên Lightsail bằng **Terraform**

## 🏗️ Kiến trúc

```text
                 Internet
                     │
                     ▼
            ┌─────────────────┐
            │ Lightsail Static│
            │       IP        │
            └────────┬────────┘
                     │
                     ▼
            ┌─────────────────┐
            │ Lightsail       │
            │ WordPress Server│
            │  + Firewall     │
            │  + CPU Alarm    │
            │  + Auto Snapshot│
            └────────┬────────┘
                     │
                     ▼
            ┌─────────────────┐
            │ Lightsail       │
            │    Database     │
            └─────────────────┘
```

## 🛠️ AWS Services

| Service                 | Vai trò                                                           |
| ----------------------- | ----------------------------------------------------------------- |
| **Amazon Lightsail**    | Cung cấp server và database đơn giản hóa việc triển khai ứng dụng |
| **Lightsail Database**  | Cung cấp database managed cho WordPress                           |
| **Lightsail Static IP** | Cung cấp địa chỉ IP cố định cho WordPress server                  |
| **Lightsail Firewall**  | Kiểm soát các port được phép truy cập vào server                  |
| **Lightsail Snapshots** | Tự động tạo snapshot để backup server                             |
| **Lightsail Alarms**    | Theo dõi CPU burst và cảnh báo khi sử dụng tài nguyên cao         |
| **Terraform**           | Infrastructure as Code để khai báo và quản lý AWS resources       |

## 📚 Kiến thức thực hành

* Infrastructure as Code với **Terraform**
* Triển khai **Amazon Lightsail**
* Lightsail Instance và Managed Database
* Static IP và network access
* Firewall và quản lý port
* Automatic Snapshot và backup
* Monitoring và CPU burst alarm
* Quản lý lifecycle của AWS resources bằng Terraform

## 🔗 Tài liệu tham khảo

* [AWS Study Group – Amazon Lightsail Lab](https://000045.awsstudygroup.com/)
* [Amazon Lightsail Documentation](https://docs.aws.amazon.com/lightsail/)
* [Terraform AWS Provider – Lightsail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
