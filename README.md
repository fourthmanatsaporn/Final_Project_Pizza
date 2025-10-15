Flutter E-Commerce App โปรเจกต์นี้เป็นแอปพลิเคชัน E-Commerce ตัวอย่าง สร้างด้วย Flutter และใช้ PocketBase เป็นฐานข้อมูล

ฟีเจอร์หลัก:

หน้าแรก (home.dart): แสดงรายการสินค้าเบื้องต้น

หน้าจัดการสินค้า (product_list_page.dart):

แสดงรายการสินค้าทั้งหมด

สามารถ แก้ไข (Update) และ ลบ (Delete) สินค้าได้

รายการสินค้าอัปเดตอัตโนมัติแบบ Real-time เมื่อข้อมูลในฐานข้อมูลเปลี่ยนแปลง

สคริปต์เตรียมข้อมูล (pocketbase_seed.dart):

ใช้สำหรับสร้างข้อมูลสินค้าตัวอย่าง 100 รายการ เพื่อใช้ทดสอบระบบ

วิธีรันโปรเจกต์:

1.git clone https://github.com/fourthmanatsaporn/Final_Project_Pizza.git

2.cd Work9-10 แล้ว code . จากนั้น flutter pub get

รัน Backend: สั่งรัน PocketBase (./pocketbase serve)

สร้าง Collection: ในหน้า Admin ของ PocketBase สร้าง Collection ชื่อ product พร้อม Fields: name, description, price, imageUrl, isVegetarian, rating

เพิ่มข้อมูล: รันสคริปต์ dart run pocketbase_seed.dart เพื่อสร้างข้อมูลสินค้า

รันแอป: สั่งรันโปรเจกต์ Flutter (flutter run)b กด 2 เพื่อรันผ่าน chrome
