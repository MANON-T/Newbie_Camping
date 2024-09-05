function calculateScore() {
  // ค่าเข้าผู้ใหญ่
  const entryAdult = parseInt(document.getElementById("entryAdult").value) || 0;
  let entryAdultScore = 0;
  if (entryAdult <= 50) {
    entryAdultScore = 10;
  } else if (entryAdult <= 100) {
    entryAdultScore = 7;
  } else {
    entryAdultScore = 3;
  }

  // ค่าเข้าเด็ก
  const entryChild = parseInt(document.getElementById("entryChild").value) || 0;
  let entryChildScore = 0;
  if (entryChild <= 20) {
    entryChildScore = 5;
  } else if (entryChild <= 50) {
    entryChildScore = 3;
  } else {
    entryChildScore = 1;
  }

  // ค่าจอดรถ
  const parkingFee = parseInt(document.getElementById("parkingFee").value) || 0;
  let parkingFeeScore = 0;
  if (parkingFee <= 20) {
    parkingFeeScore = 5;
  } else {
    parkingFeeScore = 2;
  }

  // ค่ากางเต้น
  const tentFee = parseInt(document.getElementById("tentFee").value) || 0;
  let tentFeeScore = 0;
  if (tentFee <= 50) {
    tentFeeScore = 5;
  } else {
    tentFeeScore = 2;
  }

  // มีบ้านพัก
  const cabins = document.querySelector('input[name="cabins"]:checked').value;
  let cabinsScore = cabins === "yes" ? 10 : 0;

  // มีเต้นบริการ
  const rentalTents = document.querySelector(
    'input[name="rentalTents"]:checked'
  ).value;
  let rentalTentsScore = rentalTents === "yes" ? 5 : 0;

  // มีกิจกรรม
  const activities = parseInt(document.getElementById("activities").value) || 0;
  let activitiesScore = activities >= 10 ? 10 : activities;

  // ห้องน้ำสะอาด
  const cleanRestroom = document.querySelector(
    'input[name="cleanRestroom"]:checked'
  ).value;
  let cleanRestroomScore = cleanRestroom === "yes" ? 15 : 0;

  // ห้องน้ำแยกชายหญิง
  const separateRestroom = document.querySelector(
    'input[name="separateRestroom"]:checked'
  ).value;
  let separateRestroomScore = separateRestroom === "yes" ? 15 : 0;

  // สัญญาณโทรศัพท์ TRUE, DTAC, AIS
  const signalTrue = document.getElementById("signalTrue").value;
  const signalDtac = document.getElementById("signalDtac").value;
  const signalAis = document.getElementById("signalAis").value;
  let signalScore = 0;

  const signalPoints = { good: 5, average: 3, bad: 1 };
  signalScore += signalPoints[signalTrue];
  signalScore += signalPoints[signalDtac];
  signalScore += signalPoints[signalAis];
  signalScore = signalScore / 3; // เฉลี่ยคะแนน

  // ราคาบ้านพัก (สูงสุด 10 คะแนน)
  const cabinPriceSmall =
    parseInt(document.getElementById("cabinPriceSmall").value) || 0;
  const cabinPriceMedium =
    parseInt(document.getElementById("cabinPriceMedium").value) || 0;
  const cabinPriceLarge =
    parseInt(document.getElementById("cabinPriceLarge").value) || 0;

  let cabinPriceScore = 0;
  cabinPriceScore += calculatePriceScore(cabinPriceSmall, 500, 1000); // ราคาเล็ก
  cabinPriceScore += calculatePriceScore(cabinPriceMedium, 1000, 2000); // ราคากลาง
  cabinPriceScore += calculatePriceScore(cabinPriceLarge, 2000, 3000); // ราคาใหญ่
  cabinPriceScore = cabinPriceScore / 3; // เฉลี่ยจากทั้ง 3 ขนาด
  cabinPriceScore = cabinPriceScore > 10 ? 10 : cabinPriceScore; // จำกัดคะแนนไม่เกิน 10

  // ราคาเต้น (สูงสุด 10 คะแนน)
  const tentPriceSmall =
    parseInt(document.getElementById("tentPriceSmall").value) || 0;
  const tentPriceMedium =
    parseInt(document.getElementById("tentPriceMedium").value) || 0;
  const tentPriceLarge =
    parseInt(document.getElementById("tentPriceLarge").value) || 0;

  let tentPriceScore = 0;
  tentPriceScore += calculatePriceScore(tentPriceSmall, 100, 500); // ราคาเล็ก
  tentPriceScore += calculatePriceScore(tentPriceMedium, 500, 1000); // ราคากลาง
  tentPriceScore += calculatePriceScore(tentPriceLarge, 1000, 2000); // ราคาใหญ่
  tentPriceScore = tentPriceScore / 3; // เฉลี่ยจากทั้ง 3 ขนาด
  tentPriceScore = tentPriceScore > 10 ? 10 : tentPriceScore; // จำกัดคะแนนไม่เกิน 10

  // คำนวณคะแนนรวม
  const totalScore =
    entryAdultScore +
    entryChildScore +
    parkingFeeScore +
    tentFeeScore +
    cabinsScore +
    rentalTentsScore +
    activitiesScore +
    cleanRestroomScore +
    separateRestroomScore +
    signalScore +
    cabinPriceScore +
    tentPriceScore;

  // แสดงผลลัพธ์
  document.getElementById("result").innerHTML = `คะแนนรวม: ${totalScore}/100`;

  // เปิด modal
  openModal();
}

// ฟังก์ชันคำนวณคะแนนจากราคา
function calculatePriceScore(price, minPrice, maxPrice) {
  if (price < minPrice) return 10;
  if (price <= maxPrice) return 7;
  return 3;
}

// ฟังก์ชันเปิด modal
function openModal() {
    const modal = document.getElementById('resultModal');
    modal.style.display = 'flex';
}

// ฟังก์ชันปิด modal
function closeModal() {
    const modal = document.getElementById('resultModal');
    modal.style.display = 'none';
}
