function showPopup(activities) {
    var popup = document.getElementById("activity-popup");
    var popupActivities = document.getElementById("popup-activities");
    popupActivities.innerHTML = "";

    activities.forEach(activity => {
        var li = document.createElement("li");
        li.textContent = activity;
        popupActivities.appendChild(li);
    });

    popup.style.display = "block";
}

function closePopup() {
    var popup = document.getElementById("activity-popup");
    popup.style.display = "none";
}

const toggleButton = document.getElementById('toggleButton');
const rightPanel = document.getElementById('rightPanel');

toggleButton.addEventListener('click', function () {
    rightPanel.classList.toggle('open');
    toggleButton.classList.toggle('open');

    // เปลี่ยนสัญลักษณ์ปุ่ม
    if (rightPanel.classList.contains('open')) {
        toggleButton.textContent = '>';
    } else {
        toggleButton.textContent = '<';
    }
});

document.addEventListener("DOMContentLoaded", function() {
    // ฟังก์ชันเพิ่มรายการกิจกรรม
    document.getElementById("add-activity-btn").addEventListener("click", function() {
        const activityList = document.getElementById("activity-list");
        const newActivityItem = document.createElement("div");
        newActivityItem.className = "activity-item";
        newActivityItem.innerHTML = `
            <input type="text" name="activities[]" value="" />
            <button type="button" class="delete-btn" onclick="removeActivity(this)"><i class="fa-solid fa-trash-can"></i></button>
        `;
        activityList.appendChild(newActivityItem);
    });
});

// ฟังก์ชันลบรายการกิจกรรม
function removeActivity(button) {
    const activityItem = button.parentElement;
    activityItem.remove();
}

// ฟังก์ชันปิด Popup Overlay
document.getElementById("close-btn1").addEventListener("click", function() {
    document.getElementById("popup-overlay1").style.display = "none";
});

document.addEventListener("DOMContentLoaded", function() {
    // ฟังก์ชันเพิ่มรายการกิจกรรม
    document.getElementById("add-warning-btn").addEventListener("click", function() {
        const warningList = document.getElementById("warning-list");
        const newWarningItem = document.createElement("div");
        newWarningItem.className = "warning-item";
        newWarningItem.innerHTML = `
            <input type="text" name="warning[]" value="" />
            <button type="button" class="delete-btn" onclick="removeActivity(this)"><i class="fa-solid fa-trash-can"></i></button>
        `;
        warningList.appendChild(newWarningItem);
    });
});

// ฟังก์ชันลบรายการกิจกรรม
function removeActivity(button) {
    const warningItem = button.parentElement;
    warningItem.remove();
}

// ฟังก์ชันปิด Popup Overlay
document.getElementById("close-btn4").addEventListener("click", function() {
    document.getElementById("popup-overlay4").style.display = "none";
});