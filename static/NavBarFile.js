
const logIn = document.getElementById('login')
const register = document.getElementById('register')

logIn.addEventListener('click', () =>{
    window.location.href = "/login";
})

register.addEventListener('click', () =>{
    window.location.href = "/register";
})