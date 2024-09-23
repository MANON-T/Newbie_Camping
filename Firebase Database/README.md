# Firebase Database
นี้คือโฟลเดอร์สำหรับเก็บไฟล์ฐานข้อมูล ทำตามขันตอนด้านล่างเพื่อ Import/Export ข้อมูลจาก Firebase ของคุณ

> ขั้นตอนการ Import

**ข้อควรระวัง**

การ Import นี้ จะเป็นการ Import แบบเขียนทับ หมายความว่า ไม่ว่าข้อมูลใดๆก็ตามที่อยู่ใน Firebase Database จะถูกลบทิ้งทั้งหมดแล้วเขียนทับด้วยข้อมูลจากไฟล์ Database.json ดังนั้นแนะนำให้ใช้คำสั่ง Import ก่อนที่จะเพิ่มข้อมูลอะไรลงไป

นี้คือขั้นตอนทั้งหมดในการ Import ข้อมูลในไฟล์ Database.json ไปยัง Firebase ของคุณ

 1. ดาวน์โหลด Node.js
 ขั้นตอนนี้สามารถหาวิธีดาวน์โหลดได้ตามคลิปใน Youtube เลย เราจะใช้ Node.js เพื่อ run คำสั่งในการ Import ข้อมูล
 
 2. ดาวน์โหลดไฟล์ Service Account 
 
 ![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_1.png)
![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_2.png)
![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_3.png)
![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_4.png)

หลังจากทำตามขั้นตอนดังกล่าวจะได้ไฟล์มาหนึ่งไฟล์(ชื่อไฟล์อาจแตกต่างกันไม่ต้องสนใจ)
![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_5.png)

ทำการเปลี่ยนชื่อไฟล์เป็นชื่อที่สั้นเพื่อให้ง่ายในการพิมพ์ชื่อไฟล์ใน cmd ในที่นี้จะตั้งชื่อว่า import.json
![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Firebase%20Database/service_Account_1.png)
 
 3. การ Import

หลังจากเปลี่ยนชื่อให้ทำการย้ายไฟล์ import.json ไปอยู่ในโฟลเดอร์เดียวกันกับ Database.json

![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Firebase%20Database/import_1.png)

ภายในโฟลเดอร์ที่มีทั้ง 2 ไฟล์อยู่ให้กดที่แถบของพาร์ทข้องบนจากนั้นพิมพ์ cmd เพื่อเปิด Command Prompt ขึ้นมา โดยตัว Command Prompt นี้จะอ้างอิงไปที่ตำแหน่งของโฟลเดอร์โดยอัตโนมัติ

![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Firebase%20Database/import_2.png)

จากนั้นให้ใช้คำสั่ง `npx -p node-firestore-import-export firestore-import -a import.json -b Database.json`

![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Firebase%20Database/import_3.png)

ส่วนที่ไฮไลท์คือส่วนที่สามารถเปลี่ยนชื่อได้ ซึ่งก็คือชื่อไฟล์ Service Account ที่ได้ทำการเปลี่ยนชื่อไป ในที่นี้ผู้เขียนตั้งชื่อไฟล์ว่า import.json หากได้ตั้งชื้อไฟล์เป็นชื่ออื่นก็สามารถใส่ชื่อไฟล์นั้นลงไปแทนได้ หลังจากนั้นกด Enter

**ข้อควรระวัง**

การ Import นี้ จะเป็นการ Import แบบเขียนทับ หมายความว่า ไม่ว่าข้อมูลใดๆก็ตามที่อยู่ใน Firebase Database จะถูกลบทิ้งทั้งหมดแล้วเขียนทับด้วยข้อมูลจากไฟล์ Database.json ดังนั้นแนะนำให้ใช้คำสั่ง Import ก่อนที่จะเพิ่มข้อมูลอะไรลงไป

หลังจากกด Enter จะมีข้อความแจ้งเตือนปรากฏที่ Command Prompt เป็นการยืนยันการ Import ให้พิมพ์ y เพื่อยืนยัน หากต้องการยกเลิกให้พิมพ์ n จากนั้นรอดำเนินการจนเสร็จ 
![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Firebase%20Database/import_4.png)
หากดำเนินการสร็จสิ้นให้เข้าไปตรวจสอบข้อมูลในเว็บไซต์ Firebase ว่ามีข้อมูลเข้ามาหรือไม่

> ขั้นตอนการ Export
> 
นี้คือขั้นตอนทั้งหมดในการ Export ข้อมูลใน Firebase โดยขั้นตอนจะมีความคล้ายคลึงกับการ Import ในขั้นตอนที่ 1 และ 2 แต่ในขั้นตอนที่ 3 จะมีความแตกต่างในบางส่วน หากคุณได้ติดตั้ง Node.js และดาวน์โหลดไฟล์ Service Account มาแล้ว นี้คือขั้นตอนการ Export ข้อมูลใน Firebase ของคุณ

ในขั้นตอนการ Export นั้นเราจะใช้คำสั้ง `npx -p node-firestore-import-export firestore-export -a export.json -b Database.json`

![enter image description here](https://github.com/MANON-T/Newbie_Camping/blob/main/Tutorial%20Material/Firebase%20Database/export_1.png)

 - **สีแดง** : ชื่อไฟล์ Service Account ที่ดาวน์โหลดมา ในที่นี้ผู้ขียนตั้งชื่อไฟล์ว่า export.json
 - **สีเขียว** : คือการตั้งชื่อไฟล์ที่จะทำการเก็บข้อมูลของ Firebase ไว้ เปรียบเสมือนให้สร้างไฟล์ชื่อนั้นและนำข้อมูลใน Firebase เก็บลงไป ในที่นี้ผู้ขียนตั้งชื่อไฟล์ว่า backup.json

หลังจากนั้นกด Enter แล้วรอคำสั้งดำเนินการจนเสร็จ เมื่อดำเนินการเสร็จจะปรากฎไฟล์ backup.json ขึ้นมาในโฟล์เดอร์ ซึ่งมีคุณสมบัติเหมือนกับไฟล์ Database.json ที่ผู้เขียนได้ลงไว้ให้ทุกประการ จะนำไปแชร์ หรือส่งให้สมาชิกในกลุ่มทำการ Import ข้อมูลลง Firebase ของตัวเองก็ทำได้เช้นกันตามขั้นตอนการ Import ด้ายบน
