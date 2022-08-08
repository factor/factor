function toggleSidebar() {
    var l = document.getElementById("left");
    var m = document.getElementById("menu");
    if (l.style.display === "") {
        l.style.display = "inline";
        m.src = "data:image/svg+xml;utf8,%3Csvg version=%271.1%27 xmlns=%27http://www.w3.org/2000/svg%27 xmlns:xlink=%27http://www.w3.org/1999/xlink%27 width=%2724%27 height=%2716%27 viewBox=%270 0 460.775 460.775%27%3E%3Cpath d=%27M285.08,230.397L456.218,59.27c6.076-6.077,6.076-15.911,0-21.986L423.511,4.565c-2.913-2.911-6.866-4.55-10.992-4.55 c-4.127,0-8.08,1.639-10.993,4.55l-171.138,171.14L59.25,4.565c-2.913-2.911-6.866-4.55-10.993-4.55 c-4.126,0-8.08,1.639-10.992,4.55L4.558,37.284c-6.077,6.075-6.077,15.909,0,21.986l171.138,171.128L4.575,401.505 c-6.074,6.077-6.074,15.911,0,21.986l32.709,32.719c2.911,2.911,6.865,4.55,10.992,4.55c4.127,0,8.08-1.639,10.994-4.55 l171.117-171.12l171.118,171.12c2.913,2.911,6.866,4.55,10.993,4.55c4.128,0,8.081-1.639,10.992-4.55l32.709-32.719 c6.074-6.075,6.074-15.909,0-21.986L285.08,230.397z%27/%3E%3C/svg%3E";
    } else {
        l.style.display = "";
        m.src = "data:image/svg+xml;utf8,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 xmlns:xlink=%27http://www.w3.org/1999/xlink%27 width=%2724%27 height=%2716%27 viewBox=%270 0 120 100%27 fill=%27rgb(0,0,0)%27%3E%3Crect y=%270%27 width=%27120%27 height=%2720%27 rx=%2710%27 /%3E%3Crect y=%2740%27 width=%27120%27 height=%2720%27 rx=%2710%27 /%3E%3Crect y=%2780%27 width=%27120%27 height=%2720%27 rx=%2710%27 /%3E%3C/svg%3E";
    }
}
