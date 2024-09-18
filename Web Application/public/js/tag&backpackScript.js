// สำหรับ container แรก
function addResult() {
  const selection = document.getElementById("selection");

  if (selection && selection.options.length > 0) {
    const selectedValue = selection.value;
    displayResult(selectedValue);
  } else {
    alert("ไม่มีตัวเลือกให้เลือกแล้ว");
  }
}

function displayResult(value) {
  const resultsContainers = document.querySelectorAll(".resultsContainer");
  const lastContainer = resultsContainers[resultsContainers.length - 1];

  const resultItem = document.createElement("div");
  resultItem.className = "result-item";
  resultItem.textContent = value;

  resultItem.onclick = function () {
    lastContainer.removeChild(resultItem);
    refreshOptions();
  };

  lastContainer.appendChild(resultItem);
  refreshOptions();
}

function refreshOptions() {
  const selectedTags = Array.from(
    document.querySelectorAll(".result-item")
  ).map((item) => item.textContent);
  const options = [
    "สำหรับมือใหม่",
    "ค่าจอดรถฟรี",
    "ค่าเข้าเด็กฟรี",
    "ค่าเข้าผู้ใหญ่ฟรี",
    "มีกิจกรรม",
    "มีเต็นท์บริการ",
    "มีที่พัก",
    "มีปลั๊กไฟพ่วง",
    "ห้องน้ำสะอาด",
    "มีสัญญาณค่าย True",
    "มีสัญญาณค่าย Ais",
    "มีสัญญาณค่าย Dtac",
    "ห้องน้ำแยกชายหญิง"
  ];

  const selectionElement = document.getElementById("selection");
  selectionElement.innerHTML = "";

  options.forEach((option) => {
    if (!selectedTags.includes(option)) {
      const optionElement = document.createElement("option");
      optionElement.value = option;
      optionElement.textContent = option;
      selectionElement.appendChild(optionElement);
    }
  });

  const addButton = document.querySelector('button[onclick="addResult()"]');
  if (selectionElement.options.length === 0) {
    addButton.disabled = true;
  } else {
    addButton.disabled = false;
  }
}

function saveTags() {
  const tags = Array.from(document.querySelectorAll(".result-item")).map(
    (item) => item.textContent
  );

  fetch("/updateTag", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ tags }),
  })
    .then((response) => {
      if (response.ok) {
        return response.json();
      } else {
        throw new Error("Failed to update tags");
      }
    })
    .then((data) => {
      if (data.success) {
        if (data.redirect) {
          const userConfirmed = window.confirm(
            "After save we will return to campsite page for set new information."
          );
          if (userConfirmed) {
            window.location.href = data.redirect; // Redirect ไปยังหน้า /campsite
          }
        } else {
          alert("Tags updated successfully!");
        }
      } else {
        throw new Error("Failed to update tags");
      }
    })
    .catch((error) => {
      console.error("Error:", error);
      alert("Failed to update tags");
    });
}

// สำหรับ container ที่สอง
function addResult2() {
  const selection2 = document.getElementById("selection2");

  if (selection2.options.length > 0) {
    const selectedValue = selection2.value;
    displayResult2(selectedValue);
  } else {
    alert("ไม่มีตัวเลือกให้เลือกแล้ว");
  }
}

function displayResult2(value) {
  const resultsContainers2 = document.querySelectorAll(".resultsContainer2");
  const lastContainer2 = resultsContainers2[resultsContainers2.length - 1];

  const resultItem2 = document.createElement("div");
  resultItem2.className = "result-item2";
  resultItem2.textContent = value;

  resultItem2.onclick = function () {
    lastContainer2.removeChild(resultItem2);
    refreshOptions2();
  };

  lastContainer2.appendChild(resultItem2);
  refreshOptions2();
}

function refreshOptions2() {
  const selectedTags2 = Array.from(
    document.querySelectorAll(".result-item2")
  ).map((item) => item.textContent);
  const options2 = [
    "#Viewpoints",
    "#MorningMist",
    "#OutdoorCamping",
    "#FarmLife",
    "#HomestayExperience",
    "#RomanticGetaway",
    "#GardensAndFlowers",
    "#PhuThapBuek",
    "#KhaoKho",
  ];

  const selectionElement2 = document.getElementById("selection2");
  selectionElement2.innerHTML = "";

  options2.forEach((option) => {
    if (!selectedTags2.includes(option)) {
      const optionElement2 = document.createElement("option");
      optionElement2.value = option;
      optionElement2.textContent = option;
      selectionElement2.appendChild(optionElement2);
    }
  });

  const addButton2 = document.querySelector('button[onclick="addResult2()"]');
  if (selectionElement2.options.length === 0) {
    addButton2.disabled = true;
  } else {
    addButton2.disabled = false;
  }
}
function saveTags2() {
  const tags = Array.from(document.querySelectorAll(".result-item2")).map(
    (item) => item.textContent
  );

  fetch("/updateSuggesTag", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ tags }),
  })
    .then((response) => {
      if (response.ok) {
        return response.json();
      } else {
        throw new Error("Failed to update tags");
      }
    })
    .then((data) => {
      if (data.success) {
        if (data.redirect) {
          const userConfirmed = window.confirm(
            "After save we will return to campsite page for set new information."
          );
          if (userConfirmed) {
            window.location.href = data.redirect; // Redirect ไปยังหน้า /campsite
          }
        } else {
          alert("Tags updated successfully!");
        }
      } else {
        throw new Error("Failed to update tags");
      }
    })
    .catch((error) => {
      console.error("Error:", error);
      alert("Failed to update tags");
    });
}

window.onload = function () {
  const resultsContainers = document.querySelectorAll(".resultsContainer");
  const resultsContainers2 = document.querySelectorAll(".resultsContainer2");

  resultsContainers.forEach((resultsContainer) => {
    const preExistingResults = resultsContainer
      .getAttribute("data-pre-existing-results")
      .split(",");

    preExistingResults.forEach((result) => {
      const trimmedResult = result.trim();
      if (trimmedResult) {
        const resultItem = document.createElement("div");
        resultItem.className = "result-item";
        resultItem.textContent = trimmedResult;

        resultItem.onclick = function () {
          resultsContainer.removeChild(resultItem);
          refreshOptions();
        };

        resultsContainer.appendChild(resultItem);
      }
    });
  });

  resultsContainers2.forEach((resultsContainer) => {
    const preExistingResults = resultsContainer
      .getAttribute("data-pre-existing-results")
      .split(",");

    preExistingResults.forEach((result) => {
      const trimmedResult = result.trim();
      if (trimmedResult) {
        const resultItem = document.createElement("div");
        resultItem.className = "result-item2";
        resultItem.textContent = trimmedResult;

        resultItem.onclick = function () {
          resultsContainer.removeChild(resultItem);
          refreshOptions();
        };

        resultsContainer.appendChild(resultItem);
      }
    });
  });
  refreshOptions();
  refreshOptions2();
};

document.addEventListener("DOMContentLoaded", function () {
  // ฟังก์ชันเพิ่มรายการกิจกรรม
  document
    .getElementById("add-newbie-btn")
    .addEventListener("click", function () {
      const newbieList = document.getElementById("newbie-list");
      const newNewbieItem = document.createElement("div");
      newNewbieItem.className = "newbie-item";
      newNewbieItem.innerHTML = `
            <input type="text" name="newbie[]" value="" />
            <button type="button" class="delete-btn" onclick="removeNewbie(this)"><i class="fa-solid fa-trash-can"></i></button>
        `;
      newbieList.appendChild(newNewbieItem);
    });
});

// ฟังก์ชันลบรายการกิจกรรม
function removeNewbie(button) {
  const newbieItem = button.parentElement;
  newbieItem.remove();
}

// ฟังก์ชันปิด Popup Overlay
document.getElementById("close-btn").addEventListener("click", function () {
  document.getElementById("popup-overlay").style.display = "none";
});

document.addEventListener("DOMContentLoaded", function () {
  // ฟังก์ชันเพิ่มรายการกิจกรรม
  document
    .getElementById("add-common1-btn")
    .addEventListener("click", function () {
      const common1List = document.getElementById("common1-list");
      const newCommon1Item = document.createElement("div");
      newCommon1Item.className = "common1-item";
      newCommon1Item.innerHTML = `
            <input type="text" name="common1[]" value="" />
            <button type="button" class="delete-btn" onclick="removeCommon1(this)"><i class="fa-solid fa-trash-can"></i></button>
        `;
      common1List.appendChild(newCommon1Item);
    });
});

// ฟังก์ชันลบรายการกิจกรรม
function removeCommon1(button) {
  const common1Item = button.parentElement;
  common1Item.remove();
}

// ฟังก์ชันปิด Popup Overlay
document.getElementById("close-btn1").addEventListener("click", function () {
  document.getElementById("popup-overlay1").style.display = "none";
});

document.addEventListener("DOMContentLoaded", function () {
  // ฟังก์ชันเพิ่มรายการกิจกรรม
  document
    .getElementById("add-common2-btn")
    .addEventListener("click", function () {
      const common2List = document.getElementById("common2-list");
      const newCommon2Item = document.createElement("div");
      newCommon2Item.className = "common2-item";
      newCommon2Item.innerHTML = `
            <input type="text" name="common2[]" value="" />
            <button type="button" class="delete-btn" onclick="removeCommon2(this)"><i class="fa-solid fa-trash-can"></i></button>
        `;
      common2List.appendChild(newCommon2Item);
    });
});

// ฟังก์ชันลบรายการกิจกรรม
function removeCommon2(button) {
  const common2Item = button.parentElement;
  common2Item.remove();
}

// ฟังก์ชันปิด Popup Overlay
document.getElementById("close-btn2").addEventListener("click", function () {
  document.getElementById("popup-overlay2").style.display = "none";
});
