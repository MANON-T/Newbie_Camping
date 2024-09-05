function previewImage(event) {
    const previewContainer = document.getElementById('preview-container');
    const previewImage = document.getElementById('image-preview');
    const file = event.target.files[0];

    if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            previewImage.src = e.target.result;
            previewImage.style.display = 'block';
        };
        reader.readAsDataURL(file);
    } else {
        previewImage.src = '';
        previewImage.style.display = 'none';
    }
}

function previewImage1(event) {
    const previewContainer = document.getElementById('preview-container1');
    const previewImage = document.getElementById('image-preview1');
    const file = event.target.files[0];

    if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            previewImage.src = e.target.result;
            previewImage.style.display = 'block';
        };
        reader.readAsDataURL(file);
    } else {
        previewImage.src = '';
        previewImage.style.display = 'none';
    }
}

function previewImage2(event) {
    const previewContainer = document.getElementById('preview-container2');
    const previewImage = document.getElementById('image-preview2');
    const file = event.target.files[0];

    if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            previewImage.src = e.target.result;
            previewImage.style.display = 'block';
        };
        reader.readAsDataURL(file);
    } else {
        previewImage.src = '';
        previewImage.style.display = 'none';
    }
}

function toggleInputs(serviceType) {
    const toggle = document.getElementById(`${serviceType}-toggle`);
    const sizeInputs = document.getElementById(`${serviceType}-sizes`);

    if (toggle.checked) {
        // Show the input fields if toggle is ON
        sizeInputs.style.display = 'block';
    } else {
        // Hide the input fields and reset values to 0 if toggle is OFF
        sizeInputs.style.display = 'none';
        const inputs = sizeInputs.querySelectorAll('input[type="number"]');
        inputs.forEach(input => input.value = 0);
    }
}

function updatePowerValue() {
    const toggle = document.getElementById('power-toggle');
    const powerValue = document.getElementById('power-value');

    // Set the hidden input value based on toggle state
    powerValue.value = toggle.checked ? 'true' : 'false';
}

function updateCleanRestroomsValue() {
    const toggle = document.getElementById('clean-restrooms-toggle');
    const CleanRestroomsValue = document.getElementById('clean-restrooms-value');

    // Set the hidden input value based on toggle state
    CleanRestroomsValue.value = toggle.checked ? 'true' : 'false';
}

function updateGenderSeparatedRestroomsValue() {
    const toggle = document.getElementById('gender-separated-restrooms-toggle');
    const CleanGenderSeparatedRestroomsValue = document.getElementById('gender-separated-restrooms-value');

    // Set the hidden input value based on toggle state
    CleanGenderSeparatedRestroomsValue.value = toggle.checked ? 'true' : 'false';
}

// add_formScript.js

let currentStep = 1;
const totalSteps = 9; // Adjust based on number of steps

function showStep(step) {
    document.querySelectorAll('.form-step').forEach((el, index) => {
        el.style.display = (index + 1 === step) ? 'block' : 'none';
    });
    document.getElementById('back-button').style.display = (step === 1) ? 'none' : 'inline-block';
    document.getElementById('next-button').textContent = (step === totalSteps) ? 'Submit' : 'Next';
    document.getElementById('progress-bar').style.width = `${(step / totalSteps) * 100}%`;
    document.getElementById('step-indicator').textContent = `Step ${step} of ${totalSteps}`;
}

function nextStep() {
    if (currentStep < totalSteps) {
        currentStep++;
        showStep(currentStep);
    } else {
        // Submit the form on the last step
        document.querySelector('form').submit();
    }
}

function prevStep() {
    if (currentStep > 1) {
        currentStep--;
        showStep(currentStep);
    }
}

// Initialize form
showStep(currentStep);

document.getElementById('addInputBtn').addEventListener('click', function(event) {
    event.preventDefault();

    // Create the input group container
    const inputGroup = document.createElement('div');
    inputGroup.className = 'input-group';

    // Create the input field
    const inputField = document.createElement('input');
    inputField.type = 'text';
    inputField.name = 'dynamicInputs[]'; // Set the name attribute as an array

    // Create the delete button (trash icon)
    const deleteBtn = document.createElement('button');
    deleteBtn.type = 'button';
    deleteBtn.innerHTML = '<i class="fa-solid fa-trash-can"></i>';
    deleteBtn.addEventListener('click', function() {
        inputGroup.remove();
    });

    // Append the input field and delete button to the input group
    inputGroup.appendChild(inputField);
    inputGroup.appendChild(deleteBtn);

    // Append the input group to the form container
    document.getElementById('formContainer').appendChild(inputGroup);
});

document.getElementById('addInputBtn1').addEventListener('click', function(event) {
    event.preventDefault();

    // Create the input group container
    const inputGroup = document.createElement('div');
    inputGroup.className = 'input-group';

    // Create the input field
    const inputField = document.createElement('input');
    inputField.type = 'text';
    inputField.name = 'dynamicInputs1[]'; // Set the name attribute as an array

    // Create the delete button (trash icon)
    const deleteBtn = document.createElement('button');
    deleteBtn.type = 'button';
    deleteBtn.innerHTML = '<i class="fa-solid fa-trash-can"></i>';
    deleteBtn.addEventListener('click', function() {
        inputGroup.remove();
    });

    // Append the input field and delete button to the input group
    inputGroup.appendChild(inputField);
    inputGroup.appendChild(deleteBtn);

    // Append the input group to the form container
    document.getElementById('formContainer1').appendChild(inputGroup);
});