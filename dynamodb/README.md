# AWS Lab – Amazon DynamoDB

Lab thực hành làm quen với **Amazon DynamoDB**, dịch vụ cơ sở dữ liệu NoSQL được quản lý hoàn toàn: tạo bảng, ghi/đọc/cập nhật/truy vấn dữ liệu, tạo **Global Secondary Index (GSI)**, và thao tác với DynamoDB qua **AWS Management Console**, **AWS CloudShell (AWS CLI)** và **AWS SDK for Python (Boto3)**.

🔗 **Lab hướng dẫn:** https://000060.awsstudygroup.com/

## 🎯 Mục tiêu

* Tìm hiểu các thành phần cốt lõi của DynamoDB: **Table**, **Item**, **Attribute**
* Hiểu **Primary Key** (Partition Key / Sort Key) và **Secondary Indexes**
* Nắm quy tắc đặt tên, kiểu dữ liệu, **Read Consistency** và **Read/Write Capacity Mode**
* Tạo **Access Key** cho IAM user để dùng với AWS CLI / SDK
* Tạo bảng `Music` (Partition Key `Artist`, Sort Key `SongTitle`) bằng Console và CloudShell
* Ghi, đọc, cập nhật và truy vấn dữ liệu trong bảng `Music`
* Tạo và truy vấn **Global Secondary Index** `AlbumTitle-index`
* Dùng **Boto3** để tạo bảng `Movies`, thực hiện CRUD, nạp dữ liệu mẫu (`moviedata.json`), **Query** và **Scan**
* Xóa các tài nguyên AWS sau khi hoàn thành lab

> Người dùng thao tác với **Amazon DynamoDB** qua ba cách: **AWS Management Console**, **AWS CloudShell** (AWS CLI) và ứng dụng **Python (Boto3)** trên máy local, xác thực bằng **Access Key** của IAM user. Lab gồm hai bảng: `Music` (có GSI `AlbumTitle-index`) và `Movies` (chứa dữ liệu phim mẫu).

## 🛠️ AWS Services

| Service                       | Vai trò                                                   |
| ----------------------------- | --------------------------------------------------------- |
| **Amazon DynamoDB**           | Cơ sở dữ liệu NoSQL lưu các bảng `Music` và `Movies`      |
| **DynamoDB GSI**              | Truy vấn bảng `Music` theo `AlbumTitle`                   |
| **AWS IAM**                   | Cấp Access Key cho AWS CLI / SDK                          |
| **AWS CloudShell**            | Chạy lệnh AWS CLI trực tiếp trên trình duyệt              |
| **AWS CLI**                   | Tạo bảng, ghi/đọc/truy vấn dữ liệu bằng dòng lệnh         |
| **AWS SDK for Python (Boto3)** | Thao tác với DynamoDB từ ứng dụng Python                 |

## 📚 Kiến thức thực hành

* **Table, Item, Attribute**
* **Partition Key và Sort Key (Composite Primary Key)**
* **Global Secondary Index (GSI) và Local Secondary Index (LSI)**
* **Quy tắc đặt tên và kiểu dữ liệu (Scalar, Document, Set)**
* **Eventually Consistent và Strongly Consistent Reads**
* **On-Demand và Provisioned Capacity Mode (RCU / WCU)**
* **PutItem, GetItem, UpdateItem, DeleteItem**
* **Query và Scan**
* **Projection trong GSI**
* **Nạp dữ liệu hàng loạt bằng Boto3**

## 🔗 Tài liệu tham khảo

* [AWS Study Group – Amazon DynamoDB Lab](https://000060.awsstudygroup.com/)
* [Amazon DynamoDB Documentation](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)
* [Boto3 – DynamoDB](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html)
