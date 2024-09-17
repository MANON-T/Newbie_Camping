const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");
const { db, Firestorage } = require("../models/firebase");
const admin = require("firebase-admin");
const { GeoPoint } = require("firebase-admin/firestore");

const upload = multer({
  storage: multer.memoryStorage(),
});

router.get("/", (req, res) => {
  res.render("index");
});

router.get("/campsite", async (req, res) => {
  try {
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.get();

    // ดึงข้อมูลและสร้าง signed URLs
    const campsitePromises = snapshot.docs.map(async (doc) => {
      const campsite = doc.data();
      if (campsite.imageURL) {
        // สร้าง signed URL สำหรับแต่ละภาพ
        const file = Firestorage.file(campsite.imageURL);
        const [url] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2025", // กำหนดวันที่หมดอายุของ URL
        });
        campsite.imageURL = url; // อัปเดต imageURL เป็น signed URL
      }
      return campsite;
    });

    // รอให้ทุก signed URL ถูกสร้างขึ้น
    const campsite = await Promise.all(campsitePromises);

    res.render("campsite", { campsite });
  } catch (error) {
    console.error("Error retrieving documents: ", error);
    res.status(500).send("Error retrieving documents");
  }
});

router.post("/setSession", async (req, res) => {
  const campsiteName = req.body.campsiteName;
  console.log("Campsite Name:", campsiteName);

  try {
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();

    if (snapshot.empty) {
      console.log("No matching documents.");
      return res.status(404).send("No matching campsite found");
    } else {
      console.log("Found documents");
    }

    const campsiteDetails = snapshot.docs.map((doc) => doc.data());

    // Store campsiteDetails in session
    req.session.campsiteDetails = campsiteDetails;
    req.session.campsiteName = campsiteName;

    res.redirect("/detail");
  } catch (error) {
    console.error("Error retrieving documents: ", error);
    res.status(500).send("Error retrieving documents");
  }
});

router.get("/detail", async (req, res) => {
  const campsiteName = req.session.campsiteName;

  try {
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();

    if (snapshot.empty) {
      console.log("No matching documents.");
      return res.status(404).send("No matching campsite found");
    } else {
      console.log("Found documents");
    }

    const campsitePromises = snapshot.docs.map(async (doc) => {
      const campsite = doc.data();
      if (campsite.imageURL) {
        // สร้าง signed URL สำหรับแต่ละภาพ
        const file = Firestorage.file(campsite.imageURL);
        const [url] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2025", // กำหนดวันที่หมดอายุของ URL
        });
        campsite.imageURL = url; // อัปเดต imageURL เป็น signed URL
      }
      return campsite;
    });

    const campsite = await Promise.all(campsitePromises);

    res.render("detail", { campsite: campsite });
  } catch (error) {
    console.error("Error retrieving documents: ", error);
    res.status(500).send("Error retrieving documents");
  }
});

router.get("/gallery", async (req, res) => {
  const campsiteName = req.session.campsiteName;

  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();

  const campsitePromises = snapshot.docs.map(async (doc) => {
    const campsite = doc.data();
    if (campsite.campimage && Array.isArray(campsite.campimage)) {
      // สร้าง signed URL สำหรับแต่ละภาพ
      const campimagePromises = campsite.campimage.map(async (imagePath) => {
        const file = Firestorage.file(imagePath);
        const [url] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2025", // กำหนดวันที่หมดอายุของ URL
        });
        return url;
      });
      campsite.campimage = await Promise.all(campimagePromises);
    }
    return campsite;
  });

  const campsite = await Promise.all(campsitePromises);

  res.render("gallery", { campsite: campsite });
});

router.get("/tag&backpack", (req, res) => {
  const campsiteDetails = req.session.campsiteDetails;

  if (!campsiteDetails) {
    return res.status(404).send("No campsite details found in session");
  }

  res.render("tag&backpack", { campsite: campsiteDetails });
});

router.post("/updateimage/:name", upload.single("image"), async (req, res) => {
  try {
    const campsiteName = req.params.name;
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
    const campsiteId = snapshot.docs[0].id;
    const file = req.file;
    console.log(campsiteName);
    console.log(campsiteId);

    if (!file) {
      return res.status(400).send("No file uploaded.");
    }

    // ตั้งชื่อไฟล์ใน Firebase Storage
    const fileName = `${campsiteName}/${campsiteId}-${Date.now()}${path.extname(
      file.originalname
    )}`;

    // อัปโหลดไฟล์ไปยัง Firebase Storage
    const fileUpload = Firestorage.file(fileName);
    await fileUpload.save(file.buffer, {
      metadata: {
        contentType: file.mimetype,
      },
    });

    // สร้าง URL ของไฟล์ (optional: หากต้องการใช้ public URL ให้ใช้ bucket.file(fileName).publicUrl())
    const imageURL = fileName; // เก็บ path ของไฟล์ใหม่

    // อัปเดตฟิลด์ imageURL ใน Firestore
    const campsiteRef = db.collection("campsite").doc(campsiteId);
    await campsiteRef.update({ imageURL: imageURL });

    res.status(200).send("Image updated successfully.");
  } catch (error) {
    console.error("Error updating image: ", error);
    res.status(500).send("Error updating image.");
  }
});

router.post("/updateEntryfee/:name", async (req, res) => {
  try {
    const campsiteName = req.params.name;
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();

    if (snapshot.empty) {
      return res.status(404).send("Campsite not found");
    }

    const campsiteId = snapshot.docs[0].id;

    // แปลงค่าจาก string เป็น number ก่อนอัปเดต
    const adult_entry_fee = Number(req.body.adult_entry_fee);
    const child_entry_fee = Number(req.body.child_entry_fee);
    const parking_fee = Number(req.body.parking_fee);
    const camping_fee = Number(req.body.camping_fee);

    // ตรวจสอบว่าค่าที่แปลงแล้วเป็นตัวเลข
    if (
      isNaN(adult_entry_fee) ||
      isNaN(child_entry_fee) ||
      isNaN(parking_fee) ||
      isNaN(camping_fee)
    ) {
      return res.status(400).send("Invalid input. Fees must be numbers.");
    }

    const campsiteRef = db.collection("campsite").doc(campsiteId);
    await campsiteRef.update({
      adult_entry_fee: adult_entry_fee,
      child_entry_fee: child_entry_fee,
      parking_fee: parking_fee,
      camping_fee: camping_fee,
    });

    res.redirect("/detail");
  } catch (error) {
    console.error("Error updating:", error);
    res.status(500).send("Error updating fees");
  }
});

router.post("/updateAccommodation", async (req, res) => {
  try {
    const campsiteName = req.session.campsiteName;
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();

    if (snapshot.empty) {
      return res.status(404).send("Campsite not found");
    }
    const { toggleValue, smallSize, mediumSize, largeSize } = req.body;
    const campsiteId = snapshot.docs[0].id;
    const priceValue = [
      Number(smallSize),
      Number(mediumSize),
      Number(largeSize),
    ];

    const campsiteRef = db.collection("campsite").doc(campsiteId);
    await campsiteRef.update({
      accommodation_available: toggleValue,
      House: priceValue,
    });

    // res.redirect('/detail');
    res.status(200).json({ message: "Update successful" });
  } catch (error) {
    // console.error('Error updating:', error);
    // res.status(500).send('Error updating fees');
    console.error("Error updating:", error);
    res.status(500).json({ error: "Error updating fees" });
  }
});

router.post("/updateTent", async (req, res) => {
  try {
    const campsiteName = req.session.campsiteName;
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();

    if (snapshot.empty) {
      return res.status(404).send("Campsite not found");
    }
    const { toggleValue, smallSize, mediumSize, largeSize } = req.body;
    const campsiteId = snapshot.docs[0].id;
    const priceValue = [
      Number(smallSize),
      Number(mediumSize),
      Number(largeSize),
    ];

    const campsiteRef = db.collection("campsite").doc(campsiteId);
    await campsiteRef.update({
      tent_service: toggleValue,
      Tent_rental: priceValue,
    });

    // res.redirect('/detail');
    res.status(200).json({ message: "Update successful" });
  } catch (error) {
    // console.error('Error updating:', error);
    // res.status(500).send('Error updating fees');
    console.error("Error updating:", error);
    res.status(500).json({ error: "Error updating fees" });
  }
});

router.post("/updatePowerAccess", async (req, res) => {
  try {
    const campsiteName = req.session.campsiteName;
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();

    if (snapshot.empty) {
      return res.status(404).send("Campsite not found");
    }
    const { toggleValue } = req.body;
    const campsiteId = snapshot.docs[0].id;
    const campsiteRef = db.collection("campsite").doc(campsiteId);
    await campsiteRef.update({
      power_access: toggleValue,
    });

    res.status(200).json({ message: "Update successful" });
  } catch (error) {
    // console.error('Error updating:', error);
    // res.status(500).send('Error updating fees');
    console.error("Error updating:", error);
    res.status(500).json({ error: "Error updating fees" });
  }
});

router.post("/updateCleanRestrooms", async (req, res) => {
  try {
    const campsiteName = req.session.campsiteName;
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();

    if (snapshot.empty) {
      return res.status(404).send("Campsite not found");
    }
    const { toggleValue } = req.body;
    const campsiteId = snapshot.docs[0].id;
    const campsiteRef = db.collection("campsite").doc(campsiteId);
    await campsiteRef.update({
      clean_restrooms: toggleValue,
    });

    res.status(200).json({ message: "Update successful" });
  } catch (error) {
    // console.error('Error updating:', error);
    // res.status(500).send('Error updating fees');
    console.error("Error updating:", error);
    res.status(500).json({ error: "Error updating fees" });
  }
});

router.post("/updateGenderSeparatedRestrooms", async (req, res) => {
  try {
    const campsiteName = req.session.campsiteName;
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();

    if (snapshot.empty) {
      return res.status(404).send("Campsite not found");
    }
    const { toggleValue } = req.body;
    const campsiteId = snapshot.docs[0].id;
    const campsiteRef = db.collection("campsite").doc(campsiteId);
    await campsiteRef.update({
      gender_separated_restrooms: toggleValue,
    });

    res.status(200).json({ message: "Update successful" });
  } catch (error) {
    // console.error('Error updating:', error);
    // res.status(500).send('Error updating fees');
    console.error("Error updating:", error);
    res.status(500).json({ error: "Error updating fees" });
  }
});

router.post("/updateActivity/:campsiteName", async (req, res) => {
  const campsiteName = req.params.campsiteName;
  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
  const updatedActivities = req.body.activities; // ข้อมูลที่ถูกส่งมาจะอยู่ใน req.body.activities

  // ตรวจสอบข้อมูล activities
  if (!Array.isArray(updatedActivities)) {
    // ถ้าไม่มีข้อมูล activities ส่งมา หรือไม่อยู่ในรูปแบบ array
    return res.status(400).send("Invalid data format");
  }

  const campsiteId = snapshot.docs[0].id;

  // ทำการอัพเดทข้อมูลลง Firebase Firestore
  const campsiteRef = db.collection("campsite").doc(campsiteId);
  await campsiteRef
    .update({
      activities: updatedActivities,
    })
    .then(() => {
      console.log("Activities updated successfully");
      res.redirect("/detail"); // หรือเปลี่ยนเป็นเส้นทางที่ต้องการ
    })
    .catch((error) => {
      console.error("Error updating activities:", error);
      res.status(500).send("Error updating activities");
    });
});

router.post("/updateSignal/:campsiteName", async (req, res) => {
  const campsiteName = req.params.campsiteName;
  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
  const TRUE_S = req.body.TRUE;
  const DTAC_S = req.body.DTAC;
  const AIS_S = req.body.AIS;

  const data = [TRUE_S + "TRUE", DTAC_S + "DTAC", AIS_S + "AIS"];

  const campsiteId = snapshot.docs[0].id;

  // ทำการอัพเดทข้อมูลลง Firebase Firestore
  const campsiteRef = db.collection("campsite").doc(campsiteId);
  await campsiteRef
    .update({
      phone_signal: data,
    })
    .then(() => {
      console.log("PhoneSignal updated successfully");
      res.redirect("/detail"); // หรือเปลี่ยนเป็นเส้นทางที่ต้องการ
    })
    .catch((error) => {
      console.error("Error updating PhoneSignal:", error);
      res.status(500).send("Error updating PhoneSignal");
    });
});

router.post("/updateMaker/:campsiteName", async (req, res) => {
  const campsiteName = req.params.campsiteName;
  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
  const lat = req.body.lat;
  const lng = req.body.lng;

  const campsiteId = snapshot.docs[0].id;

  const Maker = new GeoPoint(parseFloat(lat), parseFloat(lng));

  console.log(Maker);

  // ทำการอัพเดทข้อมูลลง Firebase Firestore
  const campsiteRef = db.collection("campsite").doc(campsiteId);
  await campsiteRef
    .update({
      location_coordinates: Maker,
    })
    .then(() => {
      console.log("Maker updated successfully");
      res.redirect("/detail"); // หรือเปลี่ยนเป็นเส้นทางที่ต้องการ
    })
    .catch((error) => {
      console.error("Error updating Maker:", error);
      res.status(500).send("Error updating Maker");
    });
});

router.post("/updateWarning/:campsiteName", async (req, res) => {
  const campsiteName = req.params.campsiteName;
  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
  const updatedWarning = req.body.warning; // ข้อมูลที่ถูกส่งมาจะอยู่ใน req.body.Warning

  console.log(updatedWarning);

  // ตรวจสอบข้อมูล Warning
  if (!Array.isArray(updatedWarning)) {
    // ถ้าไม่มีข้อมูล Warning ส่งมา หรือไม่อยู่ในรูปแบบ array
    return res.status(400).send("Invalid data format");
  }

  const campsiteId = snapshot.docs[0].id;

  // ทำการอัพเดทข้อมูลลง Firebase Firestore
  const campsiteRef = db.collection("campsite").doc(campsiteId);
  await campsiteRef
    .update({
      warning: updatedWarning,
    })
    .then(() => {
      console.log("Warning updated successfully");
      res.redirect("/detail"); // หรือเปลี่ยนเป็นเส้นทางที่ต้องการ
    })
    .catch((error) => {
      console.error("Error updating Warning:", error);
      res.status(500).send("Error updating Warning");
    });
});

router.post("/updateTag", async (req, res) => {
  const campsiteName = req.session.campsiteName;
  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
  const { tags } = req.body;

  if (snapshot.empty) {
    return res
      .status(404)
      .json({ success: false, message: "Campsite not found" });
  }

  const campsiteId = snapshot.docs[0].id;
  const campsiteRef = db.collection("campsite").doc(campsiteId);

  try {
    await campsiteRef.update({ tag: tags });
    res.json({ success: true, redirect: "/campsite" }); // ส่ง path ที่ต้องการ redirect กลับไป
  } catch (error) {
    console.error("Error updating tags:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post("/updateSuggesTag", async (req, res) => {
  const campsiteName = req.session.campsiteName;
  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
  const { tags } = req.body;

  if (snapshot.empty) {
    return res
      .status(404)
      .json({ success: false, message: "Campsite not found" });
  }

  const campsiteId = snapshot.docs[0].id;
  const campsiteRef = db.collection("campsite").doc(campsiteId);

  try {
    await campsiteRef.update({ sugges_tag: tags });
    res.json({ success: true, redirect: "/campsite" }); // ส่ง path ที่ต้องการ redirect กลับไป
  } catch (error) {
    console.error("Error updating tags:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post("/updatens/:campsiteName", async (req, res) => {
  const campsiteName = req.params.campsiteName;
  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
  const MedalRef = db.collection("medal");
  const snapshot1 = await MedalRef.where("name", "==", campsiteName).get();

  const name = req.body.name;
  const old_name = req.body.old_name;
  const score = Number(req.body.score);

  console.log(name, score);
  console.log("Old Name:", old_name);

  // ทำการบันทึก tags ลงในฐานข้อมูล
  const campsiteId = snapshot.docs[0].id;
  const campsiteData = snapshot.docs[0].data();
  const medalId = snapshot1.docs[0].id;

  // คัดลอกเนื้อหาจากโฟลเดอร์ old_name ไปยังโฟลเดอร์ใหม่
  const [files] = await Firestorage.getFiles({ prefix: `${old_name}` });
  for (const file of files) {
    const newFileName = file.name.replace(`${old_name}`, `${name}`);
    await Firestorage.file(file.name).copy(Firestorage.file(newFileName));
  }

  // ลบโฟลเดอร์เก่า
  await Promise.all(files.map((file) => file.delete()));

  // อัปเดต Firestore
  const medalRef = db.collection("medal").doc(medalId);
  await medalRef.update({ name: name });

  if (Array.isArray(campsiteData.campimage)) {
    const updatedImages = campsiteData.campimage.map((imagePath) => {
      return imagePath.replace(old_name, name); // เปลี่ยน old_name เป็น name ในพาทของรูปภาพ
    });

    const updatedImagePath = campsiteData.imageURL.replace(old_name, name); // แทนที่ old_name ด้วย name ในฟิลด์ที่เป็น string

    // อัปเดตฟิลด์ campimage ใน Firestore
    const campsiteRef = db.collection("campsite").doc(campsiteId);
    await campsiteRef
      .update({
        campimage: updatedImages,
        imageURL: updatedImagePath,
        name: name,
        camp_score: score,
      })
      .then(() => {
        res.redirect("/campsite");
      })
      .catch((error) => {
        console.error("Error updating tags:", error);
      });
  }
});

router.post(
  "/updategallery/:name",
  upload.single("image"),
  async (req, res) => {
    try {
      const campsiteName = req.params.name;
      const CampsiteRef = db.collection("campsite");
      const snapshot = await CampsiteRef.where(
        "name",
        "==",
        campsiteName
      ).get();
      const campsiteId = snapshot.docs[0].id;
      const file = req.file;
      console.log(campsiteName);
      console.log(campsiteId);
      console.log(file);

      if (!file) {
        return res.status(400).send("No file uploaded.");
      }

      // ตั้งชื่อไฟล์ใน Firebase Storage
      const fileName = `${campsiteName}/${campsiteId}-${Date.now()}${path.extname(
        file.originalname
      )}`;

      // อัปโหลดไฟล์ไปยัง Firebase Storage
      const fileUpload = Firestorage.file(fileName);
      await fileUpload.save(file.buffer, {
        metadata: {
          contentType: file.mimetype,
        },
      });

      // สร้าง URL ของไฟล์ (optional: หากต้องการใช้ public URL ให้ใช้ bucket.file(fileName).publicUrl())
      const imageURL = fileName; // เก็บ path ของไฟล์ใหม่

      // อัปเดตฟิลด์ imageURL ใน Firestore
      const campsiteRef = db.collection("campsite").doc(campsiteId);
      await campsiteRef.update({
        campimage: admin.firestore.FieldValue.arrayUnion(imageURL),
      });

      res.status(200).send("Image updated successfully.");
    } catch (error) {
      console.error("Error updating image: ", error);
      res.status(500).send("Error updating image.");
    }
  }
);

router.post("/deleteimage", async (req, res) => {
  try {
    const campsiteName = req.session.campsiteName;
    const CampsiteRef = db.collection("campsite");
    const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
    const campsiteId = snapshot.docs[0].id;
    const { campimage } = req.body;
    console.log(campsiteName);
    console.log(campsiteId);

    const match = campimage.match(/\/([^\/]+)\.png/);
    const path = match ? match[1] : null;
    console.log(campsiteName + "/" + path + ".png");
    const campimageURL = campsiteName + "/" + path + ".png";

    const fileDeleat = Firestorage.file(campimageURL).delete();

    // อัปเดตฟิลด์ imageURL ใน Firestore
    const campsiteRef = db.collection("campsite").doc(campsiteId);
    await campsiteRef.update({
      campimage: admin.firestore.FieldValue.arrayRemove(campimageURL),
    });

    res.json({ success: true });
  } catch (error) {
    console.error("Error updating image: ", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post("/updateNewbieBag/:campsiteName", async (req, res) => {
  const campsiteName = req.params.campsiteName;
  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
  const updatedNewbie = req.body.newbie; // ข้อมูลที่ถูกส่งมาจะอยู่ใน req.body.activities

  // ตรวจสอบข้อมูล activities
  if (!Array.isArray(updatedNewbie)) {
    // ถ้าไม่มีข้อมูล activities ส่งมา หรือไม่อยู่ในรูปแบบ array
    return res.status(400).send("Invalid data format");
  }

  const campsiteId = snapshot.docs[0].id;

  // ทำการอัพเดทข้อมูลลง Firebase Firestore
  const campsiteRef = db.collection("campsite").doc(campsiteId);
  await campsiteRef
    .update({
      newbie_backpack: updatedNewbie,
    })
    .then(() => {
      console.log("Newbie Bagpack updated successfully");
      res.redirect("/campsite"); // หรือเปลี่ยนเป็นเส้นทางที่ต้องการ
    })
    .catch((error) => {
      console.error("Error updating Newbie Bagpack:", error);
      res.status(500).send("Error updating Newbie Bagpack");
    });
});

router.post("/updateCommon1/:campsiteName", async (req, res) => {
  const campsiteName = req.params.campsiteName;
  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
  const updatedCommon1 = req.body.common1; // ข้อมูลที่ถูกส่งมาจะอยู่ใน req.body.activities

  // ตรวจสอบข้อมูล activities
  if (!Array.isArray(updatedCommon1)) {
    // ถ้าไม่มีข้อมูล activities ส่งมา หรือไม่อยู่ในรูปแบบ array
    return res.status(400).send("Invalid data format");
  }

  const campsiteId = snapshot.docs[0].id;

  // ทำการอัพเดทข้อมูลลง Firebase Firestore
  const campsiteRef = db.collection("campsite").doc(campsiteId);
  await campsiteRef
    .update({
      common_backpack1: updatedCommon1,
    })
    .then(() => {
      console.log("Common Backpack Type 1 updated successfully");
      res.redirect("/campsite"); // หรือเปลี่ยนเป็นเส้นทางที่ต้องการ
    })
    .catch((error) => {
      console.error("Error updating Common Backpack Type 1:", error);
      res.status(500).send("Error updating Common Backpack Type 1");
    });
});

router.post("/updateCommon2/:campsiteName", async (req, res) => {
  const campsiteName = req.params.campsiteName;
  const CampsiteRef = db.collection("campsite");
  const snapshot = await CampsiteRef.where("name", "==", campsiteName).get();
  const updatedCommon2 = req.body.common2; // ข้อมูลที่ถูกส่งมาจะอยู่ใน req.body.activities

  // ตรวจสอบข้อมูล activities
  if (!Array.isArray(updatedCommon2)) {
    // ถ้าไม่มีข้อมูล activities ส่งมา หรือไม่อยู่ในรูปแบบ array
    return res.status(400).send("Invalid data format");
  }

  const campsiteId = snapshot.docs[0].id;

  // ทำการอัพเดทข้อมูลลง Firebase Firestore
  const campsiteRef = db.collection("campsite").doc(campsiteId);
  await campsiteRef
    .update({
      common_backpack2: updatedCommon2,
    })
    .then(() => {
      console.log("Common Backpack Type 2 updated successfully");
      res.redirect("/campsite"); // หรือเปลี่ยนเป็นเส้นทางที่ต้องการ
    })
    .catch((error) => {
      console.error("Error updating Common Backpack Type 2:", error);
      res.status(500).send("Error updating Common Backpack Type 2");
    });
});

router.get("/add_form", (req, res) => {
  res.render("add_form");
});

router.post("/addCampsite", upload.array("image", 3), async (req, res) => {
  const score = req.body.score;
  const name = req.body.name;
  const adultFee = req.body["adult_fee"] || 0;
  const childFee = req.body["child_fee"] || 0;
  const parkingFee = req.body["parking_fee"] || 0;
  const campingFee = req.body["camping_fee"] || 0;
  const accommodationAvailable = req.body["accommodation-toggle"]
    ? true
    : false;
  const smallSize = req.body["small-size"] || 0;
  const mediumSize = req.body["medium-size"] || 0;
  const largeSize = req.body["large-size"] || 0;
  const tentAvailable = req.body["tent-toggle"] ? true : false;
  const tentSmallSize = req.body["tent-small-size"] || 0;
  const tentMediumSize = req.body["tent-medium-size"] || 0;
  const tentLargeSize = req.body["tent-large-size"] || 0;
  const powerAccess = req.body["power"] === "true";
  const activity = req.body["dynamicInputs"] || []; // รับค่าจากฟอร์ม
  const warning = req.body["dynamicInputs1"] || []; // รับค่าจากฟอร์ม
  const clean_restrooms = req.body["clean_restrooms"] === "true";
  const gender_separated_restrooms =
    req.body["gender_separated_restrooms"] === "true";
  const truesignal = req.body["TRUE"];
  const dtacsignal = req.body["DTAC"];
  const aissignal = req.body["AIS"];
  const latitude = Number(req.body["lat"]);
  const longitude = Number(req.body["lng"]);
  const campimage = [];
  const tag = [];
  const sugges_tag = [];
  const common_backpack1 = [];
  const common_backpack2 = [];
  const newbie_backpack = [];
  const users = [];

  const House = [Number(smallSize), Number(mediumSize), Number(largeSize)];
  const Tent_rental = [
    Number(tentSmallSize),
    Number(tentMediumSize),
    Number(tentLargeSize),
  ];
  const location = new GeoPoint(parseFloat(latitude), parseFloat(longitude));
  const phone_signal = [
    truesignal + "TRUE",
    dtacsignal + "DTAC",
    aissignal + "AIS",
  ];

  const files = req.files;
  const imageUrls = [];

  if (!files) {
    return res.status(400).send("No file uploaded.");
  }

  if (!files || files.length === 0) {
    return res.status(400).send("No files uploaded.");
  }

  // Loop through each file and upload to Firebase Storage
  for (let i = 0; i < files.length; i++) {
    let fileName;

    if (i === 0) {
      // If it's the first image, give it a special name
      fileName = `${name}/cover-${Date.now()}-${files[i].originalname}`;
    } else {
      // For other images, use the standard naming convention
      fileName = `ตราปั๋ม/${name}/${Date.now()}-${files[i].originalname}`;
    }

    const fileUpload = Firestorage.file(fileName);

    await fileUpload.save(files[i].buffer, {
      metadata: {
        contentType: files[i].mimetype,
      },
    });

    // Collect the image URLs or paths
    imageUrls.push(fileName);
  }

  const campRef = db.collection("campsite").doc();
  await campRef.set({
    House: House,
    Tent_rental: Tent_rental,
    accommodation_available: accommodationAvailable,
    activities: activity,
    adult_entry_fee: Number(adultFee),
    camp_score: Number(score),
    campimage: campimage,
    camping_fee: Number(campingFee),
    child_entry_fee: Number(childFee),
    clean_restrooms: clean_restrooms,
    common_backpack1: common_backpack1,
    common_backpack2: common_backpack2,
    gender_separated_restrooms: gender_separated_restrooms,
    imageURL: imageUrls[0],
    location_coordinates: location,
    name: name,
    newbie_backpack: newbie_backpack,
    parking_fee: Number(parkingFee),
    phone_signal: phone_signal,
    power_access: powerAccess,
    sugges_tag: sugges_tag,
    tag: tag,
    tent_service: tentAvailable,
    warning: warning,
  });

  const madpRef = db.collection("medal").doc();
  await madpRef.set({
    lock: imageUrls[1],
    name: name,
    unlock: imageUrls[2],
    user: users,
  });

  // Respond back to the client
  res.redirect("/campsite");
});

router.get("/article", async (req, res) => {
  try {
    const TipRef = db.collection("tip");
    const snapshot = await TipRef.get();

    // ดึงข้อมูลและสร้าง signed URLs
    const tipPromises = snapshot.docs.map(async (doc) => {
      const tip = doc.data();
      if (tip.imageURL) {
        // สร้าง signed URL สำหรับแต่ละภาพ
        const file = Firestorage.file(tip.imageURL);
        const [url] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2025", // กำหนดวันที่หมดอายุของ URL
        });
        tip.imageURL = url; // อัปเดต imageURL เป็น signed URL
      }
      return tip;
    });

    // รอให้ทุก signed URL ถูกสร้างขึ้น
    const tip = await Promise.all(tipPromises);

    res.render("article", { tip });
  } catch (error) {
    console.error("Error retrieving documents: ", error);
    res.status(500).send("Error retrieving documents");
  }
});

router.post("/tipDetail", async (req, res) => {
  const tipTopic = req.body.tipTopic;
  console.log("Topic Name:", tipTopic);

  try {
    const TipRef = db.collection("tip");
    const snapshot = await TipRef.where("topic", "==", tipTopic).get();

    if (snapshot.empty) {
      console.log("No matching documents.");
      return res.status(404).send("No matching campsite found");
    } else {
      console.log("Found documents");
    }

    const tipPromises = snapshot.docs.map(async (doc) => {
      const tip = doc.data();
      if (tip.imageURL) {
        // สร้าง signed URL สำหรับแต่ละภาพ
        const file = Firestorage.file(tip.imageURL);
        const [url] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2025", // กำหนดวันที่หมดอายุของ URL
        });
        tip.imageURL = url; // อัปเดต imageURL เป็น signed URL
      }

      // แปลง timestamp เป็นรูปแบบที่ต้องการ
      if (tip.timestamp) {
        const date = tip.timestamp.toDate(); // แปลง Firestore.Timestamp เป็น Date object
        tip.formattedDate = date.toLocaleString("th-TH", {
          year: "numeric",
          month: "long",
          day: "numeric",
          hour: "2-digit",
          minute: "2-digit",
        });
      }

      return tip;
    });

    const tip = await Promise.all(tipPromises);

    res.render("topicDetail", { tip: tip });
  } catch (error) {
    console.error("Error retrieving documents: ", error);
    res.status(500).send("Error retrieving documents");
  }
});

router.post(
  "/updatearticle/:topic",
  upload.single("image"),
  async (req, res) => {
    const oldTopic = req.params.topic;
    const newTopic = req.body.newTopic;
    const newDescription = req.body.newDescription;
    const imageFile = req.file; // รองรับการอัปโหลดไฟล์ด้วย multer

    try {
      const tipRef = db.collection("tip").where("topic", "==", oldTopic);
      const snapshot = await tipRef.get();

      if (snapshot.empty) {
        return res.status(404).send("ไม่พบเอกสารที่ตรงกัน");
      }

      const doc = snapshot.docs[0];
      const tip = doc.data();

      // อัปโหลดไฟล์รูปภาพใหม่ไปยัง Firebase Storage
      let imageURL = tip.imageURL;
      if (imageFile) {
        const filePath = `เกล็ดความรู้/${imageFile.originalname}`;
        const fileUpload = Firestorage.file(filePath);
        await fileUpload.save(imageFile.buffer, {
          metadata: {
            contentType: filePath.mimetype,
          },
        });
        imageURL = filePath; // อัปเดต imageURL เป็นเส้นทางใหม่
      }

      // อัปเดตเอกสารใน Firestore
      await doc.ref.update({
        topic: newTopic,
        description: newDescription,
        imageURL: imageURL,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.redirect("/article"); // หลังอัปเดตเสร็จกลับไปที่หน้า campsite หรือหน้าที่ต้องการ
    } catch (error) {
      console.error("Error updating document:", error);
      res.status(500).send("Error updating document");
    }
  }
);

router.get("/add_article", (req, res) => {
  res.render("add_article");
});

router.post("/addTip", upload.single("image"), async (req, res) => {
  const topic = req.body.topic;
  const description = req.body.description;
  const file = req.file;

  const fileName = `เกล็ดความรู้/cover-${Date.now()}-${file.originalname}`;
  const imageURL = fileName;

  const fileUpload = Firestorage.file(fileName);

  await fileUpload.save(file.buffer, {
    metadata: {
      contentType: file.mimetype,
    },
  });

  const tipRef = db.collection("tip").doc();
  await tipRef.set({
    description: description,
    imageURL: imageURL,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    topic: topic,
  });

  // Respond back to the client
  res.redirect("/article");
});

router.get("/medal_manage", async (req, res) => {
  try {
    const medalRef = db.collection("medal");
    const snapshot = await medalRef.get();

    // ดึงข้อมูลและสร้าง signed URLs
    const medPromises = snapshot.docs.map(async (doc) => {
      const medal = doc.data();
      if (medal.unlock) {
        // สร้าง signed URL สำหรับแต่ละภาพ
        const file = Firestorage.file(medal.unlock);
        const [url] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2025", // กำหนดวันที่หมดอายุของ URL
        });
        medal.unlock = url; // อัปเดต imageURL เป็น signed URL
      }
      return medal;
    });

    // รอให้ทุก signed URL ถูกสร้างขึ้น
    const medal = await Promise.all(medPromises);
    res.render("medal_manage", { medal });
  } catch (error) {
    console.error("Error retrieving documents: ", error);
    res.status(500).send("Error retrieving documents");
  }
});

router.post("/editMedal", async (req, res) => {
  const name = req.body.name;
  console.log(name);

  try {
    const MedalRef = db.collection("medal");
    const snapshot = await MedalRef.where("name", "==", name).get();

    if (snapshot.empty) {
      console.log("No matching documents.");
      return res.status(404).send("No matching campsite found");
    } else {
      console.log("Found documents");
    }

    const medalPromises = snapshot.docs.map(async (doc) => {
      const medal = doc.data();
      if (medal.lock) {
        // สร้าง signed URL สำหรับแต่ละภาพ
        const file1 = Firestorage.file(medal.lock);
        const [url1] = await file1.getSignedUrl({
          action: "read",
          expires: "03-01-2025", // กำหนดวันที่หมดอายุของ URL
        });
        const file2 = Firestorage.file(medal.unlock);
        const [url2] = await file2.getSignedUrl({
          action: "read",
          expires: "03-01-2025", // กำหนดวันที่หมดอายุของ URL
        });
        medal.lock = url1; // อัปเดต imageURL เป็น signed URL
        medal.unlock = url2;
      }
      return medal;
    });

    const medal = await Promise.all(medalPromises);

    res.render("editMedal", { medal: medal });
  } catch (error) {
    console.error("Error retrieving documents: ", error);
    res.status(500).send("Error retrieving documents");
  }
});

router.post(
  "/updatemedal/:status/:name",
  upload.single("image"),
  async (req, res) => {
    const name = req.params.name;
    const status = req.params.status;
    const imageFile = req.file; // รองรับการอัปโหลดไฟล์ด้วย multer
    console.log(status);

    try {
      const medalRef = db.collection("medal").where("name", "==", name);
      const snapshot = await medalRef.get();

      if (snapshot.empty) {
        return res.status(404).send("ไม่พบเอกสารที่ตรงกัน");
      }

      const doc = snapshot.docs[0];
      const medal = doc.data();

      // อัปโหลดไฟล์รูปภาพใหม่ไปยัง Firebase Storage
      let imageURL;
      status === "lock" ? (imageURL = medal.lock) : (imageURL = medal.unlock);
      if (imageFile) {
        if (status === "lock") {
          const filePath = `ตราปั๋ม/${name}/lock${path.extname(
            imageFile.originalname
          )}`;
          const fileUpload = Firestorage.file(filePath);
          await fileUpload.save(imageFile.buffer, {
            metadata: {
              contentType: filePath.mimetype,
            },
          });
          imageURL = filePath; // อัปเดต imageURL เป็นเส้นทางใหม่
        } else {
          const filePath = `ตราปั๋ม/${name}/unlock${path.extname(
            imageFile.originalname
          )}`;
          const fileUpload = Firestorage.file(filePath);
          await fileUpload.save(imageFile.buffer, {
            metadata: {
              contentType: filePath.mimetype,
            },
          });
          imageURL = filePath; // อัปเดต imageURL เป็นเส้นทางใหม่
        }
      }

      console.log(imageURL);

      status === "lock"
        ? // อัปเดตเอกสารใน Firestore
          await doc.ref.update({
            lock: imageURL,
          })
        : await doc.ref.update({
            unlock: imageURL,
          });
      res.redirect("/medal_manage"); // หลังอัปเดตเสร็จกลับไปที่หน้า campsite หรือหน้าที่ต้องการ
    } catch (error) {
      console.error("Error updating document:", error);
      res.status(500).send("Error updating document");
    }
  }
);

router.get("/tool", (req, res) => {
  res.render("tool");
});

router.get("/tooltype", (req, res) => {
  const tooltype = req.query.tooltype;
  try {
    if (tooltype === "Calculator") {
      res.render("calculateScore");
    } else {
      res.render("getLockImg");
    }
  } catch (error) {
    console.error("Error getting", error);
  }
});

module.exports = router;
