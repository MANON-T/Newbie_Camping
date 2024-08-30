
# Web Application
สำหรับนักพัฒนาที่ต้องการจะอัปเดท ปรับปุง หรือแก้ไขโค้ดของตัวเว็บ

> การตั้งค่าโปรเจค

สำหรับโปรเจคนี้จะใช้งานฐานข้อมูลจาก Firebase ที่ได้ตั้งค่าไว้แล้วในโปรเจค [Flutter Application](https://github.com/MANON-T/Newbie-Camping/tree/main/Flutter%20Application) ดังนั้นจึงข้อแนะนำให้ไปทำการตั้งค่า Firebase ให้เรียบร้อยเสียก่อน และตัวโปรเจคนี้พัฒนาด้วย Nodejs ดังนั้นจึงขอแนะนำให้ศึกษา Nodejs มาก่อนเพื่อความเข้าใจในการทำงานของโคด แต่หากตั้งค่า Firebase และมีพื้นฐานของ Nodejs แล้วสำหรับการตั้งค่าโปรเจคเพื่อใช้งานเว็บจะมีขั้นตอนดังนี้

> ดาวห์โหลดไฟล์ serviceAccountKey.json

โดยไฟล์ serviceAccountKey.json จะเป็นไฟล์ที่เราใช้ในการเข้าถึงบริการต่างๆของ Firebase โดยสามารถทำตามได้ตามวิธีด้านล่าง

 1. เข้าไปยัง Firebase Console
 2. เลือกโปรเจคที่จะใช้งาน ในที่นี้คือโปรเจคที่เราได้ตั้งค่าเอาไว้แล้วจากข้อความข้างต้น
 3. ที่แถบด้านซ้ายจะมีรูปฟันเฟืองอยู่คลิกที่ฟันเฟืองจากนั้นเลือก Project settings![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_1.png)
 4. หลังจากนั้นจะปรากฏแถบด้านบนให้เลือก คลิกเลือก Service accounts![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_2.png)
 5. เลือนลงมาจะเจอส่วนของตัวเลือกให้เลือก Nodejs จากนั้นกด Generate new private key![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_3.png)
 6. หลังจากกดจะมีหน้าป๊อปอัพเด้งขึ้นมาเลือก Generate key![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_4.png)
 7. หลังจากนั้นระบบจะทำการดาวห์โหลดไฟล์ให้อัตโนมัติและจะได้เป็นไฟล์ตามภาพ (ชื้อไฟล์ที่ได้อาจไม่เหมือนกันขึ้นอยู่กับตัวโปรเจค)![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_5.png)
 8. นำไฟล์ไปวางในโฟลเดอร์โดยจัดวางตามรูปพร้อมเปลี่ยนชื่อไฟล์เป็น serviceAccountKey.json![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/get_serviceAccountKey_6.png)

> ตั้งค่า GOOGLE MAP API KEY

สำหรับส่วนของเว็บไซต์นั้นก็จำเป็นต้องใช้ GOOGLE MAP API KEY เช่นกันเนื่องจากตัวเส็บมีการใช้งาน javaScript map API ของทาง Google เพื่อแสดงแผนที่ ส่วนนี้หากได้ทำการตั้งค่าโปรเจค Firebase มาแล้วก็สามารถใช้งาน API Key ตัวเดิมได้เลย แต่ที่ต้องเพิ่มเติมคือตัว API ตัวเดิมจะมีบริการแค่ Directions API และ Maps SDK for Android เท่านั้น ในส่วนนี้ให้เพิ่ม Maps JavaScript API เข้าไปด้วยในหน้าเลือก API ของ Google cloud platform เมื่อเพิ่ม Maps JavaScript API เสร็จแล้วให้ไปยังไฟล์ detail.ejs ที่อยู่ในโฟลเดอร์ views ในบรรทัดที่ 551-553 จะพบกับ script สำหรับใช้งานตัว Googlemap อยู่ให้นำ API ที่ได้จาก Google cloud platform มาใส่แทนคำว่า `YOU_GOOGLEMAP_API_KEY` ภายในโคดได้เลย

    <script  src="https://maps.googleapis.com/maps/api/js?key=YOU GOOGLEMAP API KEY&loading=async&libraries=maps,marker&v=beta"
		defer>
	</script>

> storageBucket

storageBucket คือส่วนที่ใช้อ้างอิงถึงลิงค์ของตัว Firebase Storage ที่เป็นที่สำหรับเก็บรูปภาพ โดยการตั้งค่า storageBucket นั้นให้ไปที่ไฟล์ firebase.js ในโฟลเดอร์ modules จากนั้นจะพบคำสั่ง `storageBucket: "Your_StorageBucket_Link"` ในบรรทัดที่ 7 โดยในส่วนนี้ให้นำลิงค์ storageBucket ของโปรเจคตัวเองมาแทนที่คำว่า Your_StorageBucket_Link โดยยังคงเครื่องหมาย "" ที่ล้อม storageBucket ของโปรเจคไว้ ซึ่งวิธีหาลิงค์ storageBucket นั้นหาได้จากการไปยังหน้า Files ของตัว Firebase Storage

![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Firebase%20Storage%20bar/File.png)

เมื่อเข้ามาแล้วจะสังเกตเห็นเห็นลิงค์ที่อยู่ด้านบนสุดของการจัดการไฟล์ กดที่เครื่องหมายคลิปเพื่อคัดลอกและนำมาวางแทนที่คำว่า `Your_StorageBucket_Link` ได้เลย

![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/get_storageBucket_link.png)
 
> การแก้ไขวันหมดอายุลิงค์ภาพ

สำหรับโปรเจคนี้จะมีการดึงรูปภาพส่วนใหญ่มาจาก Firebase Storage ซึ่งจะเป็นการสร้างลิงค์ชั่วคราวสำหรับเข้าถึงรูปภาพโดยลิงค์สามารถหมดอายุได้ดังนั้นจึงแนะนำให้ตรวจสอบและแก้ไขวันหมดอายุของลิงค์เพื่อความสมบูรณ์ของโปรเจค โดยสามารถแก้ไขได้ที่ไฟล์ myroute.js ที่โฟลเดอร์ routes ของโปรเจค![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/expires_change_1.png)
เมื่อเข้าสูไฟล์ myroute.js แล้ว ให้กด Ctrl + F เพื่อเป็นการค้นหาคำจากนั้นพิมพ์คำว่า expires ที่ช้องค้นหา ที่แถบค้นหาจะมีลูกศร ขึ้น-ลง ให้ใช้งานในการไปยังตำแหน่งของคำที่ค้นหา เมื่อพบเจอส่วนของ expires แล้วให้แก้ไขวันหมดอายุโดยยึดตามรูปแบบเดิมของโค้ดไว้![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/expires_change_2.png)

> ข้อควรระวังในการใช้งานการอัพโหลดรูปภาพใหม่ผ่านการอัปโหลดทางหน้า Gallery

ส่วนนี้เป็นส่วนสำคัญจึงอยากจะขอเตือนไว้ว่าการอัปโหลดรูปภาพใดๆ ผ่านหน้า Gallery นั้นต้องเป็นไฟล์ .png เท่านั้น![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/gallery_upload_warning.png)

> การเพิ่ม search tag ในหน้า tag&backpack

![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/Add_Tag_1.png)

การเพิ่ม search tag นั้นสามารถทำได้โดยการแก้ไขโด้ดในไฟล์ tag&backpack.ejs ในโฟลเดอร์ `views` โดยการเพิ่มรายการ tag ที่ต้องการเพิ่มเข้าไป

![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/Add_Tag_2.png)

และไฟล์ tag&backpackScript.js ในโฟลเดอร์ `public/js` โดยการเพิ่ม tag ในชื่อเดียวกันกับ tag&backpack.ejs ก่อนหน้า

![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/Add_Tag_3.png)

> การเพิ่ม sugges tag ในหน้า tag&backpack

![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/Add_suggesTag_1.png)

การเพิ่ม sugges tag จะทำแบบเดียวกับการเพิ่ม search tag ที่ไฟล์ทั้ง 2 แบบเดียวกัน

![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/Add_suggesTag_2.png)

![enter image description here](https://github.com/MANON-T/Newbie-Camping/blob/main/Tutorial%20Material/Web%20Application/Add_suggesTag_3.png)
