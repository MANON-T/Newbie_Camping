$(".navTrigger").click(function () {
  $(this).toggleClass("active");
  console.log("Clicked menu");
  $("#mainListDiv").toggleClass("show_list");
  $("#mainListDiv").fadeIn();
});

function previewImage() {
  const file = document.getElementById("imageFile").files[0];
  if (file) {
    const reader = new FileReader();
    reader.onload = function (event) {
      const img = new Image();
      img.onload = function () {
        const originalCanvas = document.getElementById("originalCanvas");
        const adjustedCanvas = document.getElementById("adjustedCanvas");

        originalCanvas.width = img.width;
        originalCanvas.height = img.height;
        adjustedCanvas.width = img.width;
        adjustedCanvas.height = img.height;

        const originalCtx = originalCanvas.getContext("2d");
        const adjustedCtx = adjustedCanvas.getContext("2d");

        originalCtx.drawImage(img, 0, 0);

        // Adjust brightness
        adjustedCtx.drawImage(img, 0, 0);
        const imageData = adjustedCtx.getImageData(
          0,
          0,
          adjustedCanvas.width,
          adjustedCanvas.height
        );
        for (let i = 0; i < imageData.data.length; i += 4) {
          imageData.data[i] = imageData.data[i] * 0.2; // Reducing Red brightness
          imageData.data[i + 1] = imageData.data[i + 1] * 0.2; // Reducing Green brightness
          imageData.data[i + 2] = imageData.data[i + 2] * 0.2; // Reducing Blue brightness
        }
        adjustedCtx.putImageData(imageData, 0, 0);
      };
      img.src = event.target.result;
    };
    reader.readAsDataURL(file);
  }
}

function downloadAdjustedImage() {
  const adjustedCanvas = document.getElementById("adjustedCanvas");
  const link = document.createElement("a");
  link.download = "Lock.png";
  link.href = adjustedCanvas.toDataURL();
  link.click();
}
