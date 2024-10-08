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

// แสดงตัวอย่างรูปภาพเมื่อเลือกรูปภาพใหม่
document.getElementById('image').onchange = function(event) {
    const [file] = event.target.files;
    if (file) {
        const preview = document.getElementById('imagePreview');
        preview.src = URL.createObjectURL(file);
        preview.style.display = 'block';
    }
};