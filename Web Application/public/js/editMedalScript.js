// เปิด popup
document.getElementById('editButton').onclick = function() {
    document.getElementById('editPopup').style.display = 'block';
};

// ปิด popup
document.getElementById('closePopup').onclick = function() {
    document.getElementById('editPopup').style.display = 'none';
};

// ปิด popup เมื่อคลิกนอก popup
window.onclick = function(event) {
    const popup = document.getElementById('editPopup');
    if (event.target === popup) {
        popup.style.display = 'none';
    }
};

// เปิด popup
document.getElementById('editButton1').onclick = function() {
    document.getElementById('editPopup1').style.display = 'block';
};

// ปิด popup
document.getElementById('closePopup1').onclick = function() {
    document.getElementById('editPopup1').style.display = 'none';
};

// ปิด popup เมื่อคลิกนอก popup
window.onclick = function(event) {
    const popup = document.getElementById('editPopup1');
    if (event.target === popup) {
        popup.style.display = 'none';
    }
};

// แสดงตัวอย่างรูปภาพเมื่อเลือกรูปภาพใหม่
document.getElementById('image').onchange = function(event) {
    const [file] = event.target.files;
    if (file) {
        const preview = document.getElementById('imagePreview');
        preview.src = URL.createObjectURL(file);
        preview.style.display = 'block';
    }
};

// แสดงตัวอย่างรูปภาพเมื่อเลือกรูปภาพใหม่
document.getElementById('image1').onchange = function(event) {
    const [file] = event.target.files;
    if (file) {
        const preview = document.getElementById('imagePreview1');
        preview.src = URL.createObjectURL(file);
        preview.style.display = 'block';
    }
};