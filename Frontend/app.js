const apiUrl = "https://d39kuiexab.execute-api.us-east-1.amazonaws.com/prod"; // Replace with your API Gateway URL

document
  .getElementById("register-form-element")
  .addEventListener("submit", registerUser);
document
  .getElementById("login-form-element")
  .addEventListener("submit", loginUser);

document
  .getElementById("show-register")
  .addEventListener("click", showRegisterForm);
document.getElementById("show-login").addEventListener("click", showLoginForm);

function registerUser(event) {
  event.preventDefault();

  const email = document.getElementById("register-email").value;
  const password = document.getElementById("register-password").value;

  const userData = {
    email: email,
    password: password,
  };

  fetch(`${apiUrl}/register`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(userData),
  })
    .then((response) => response.json())
    .then((data) => {
      showMessage(data.message, "success");
      showLoginForm();
    })
    .catch((error) => {
      showMessage("Registration failed. Please try again.", "error");
    });
}

function loginUser(event) {
  event.preventDefault();

  const email = document.getElementById("login-email").value;
  const password = document.getElementById("login-password").value;

  const userData = {
    email: email,
    password: password,
  };

  fetch(`${apiUrl}/login`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(userData),
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        showMessage("Login successful!", "success");
      } else {
        showMessage("Invalid credentials. Please try again.", "error");
      }
    })
    .catch((error) => {
      showMessage("Login failed. Please try again.", "error");
    });
}

function showLoginForm(event) {
  event.preventDefault();
  document.getElementById("register-form").style.display = "none";
  document.getElementById("login-form").style.display = "block";
}

function showRegisterForm(event) {
  event.preventDefault();
  document.getElementById("login-form").style.display = "none";
  document.getElementById("register-form").style.display = "block";
}

function showMessage(message, type) {
  const responseMessageElement = document.getElementById("response-message");
  responseMessageElement.textContent = message;

  if (type === "success") {
    responseMessageElement.style.color = "green";
  } else if (type === "error") {
    responseMessageElement.style.color = "red";
  }
}
