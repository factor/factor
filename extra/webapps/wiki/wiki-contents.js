function toggleSidebar() {
    var l = document.getElementById("left");
    var m = document.getElementById("menu");
    if (l.style.display === "") {
        l.style.display = "inline";
        m.style.backgroundColor = "#f3f2ea";
    } else {
        l.style.display = "";
        m.style.backgroundColor = "";
    }
}
