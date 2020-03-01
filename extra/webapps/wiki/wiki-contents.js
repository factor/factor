
function resetSidebar() {
    var l = document.getElementById("left");
    var m = document.getElementById("menu");
    l.style.position = "";
    l.style.display = "";
    l.style.marginTop = "";
    m.style.backgroundColor = "";
}

window.addEventListener("resize", resetSidebar);

function toggleSidebar() {
    var l = document.getElementById("left");
    var m = document.getElementById("menu");
    if (l.style.display === "") {
        l.style.position = "absolute";
        l.style.display = "inline";
        l.style.marginTop = "40px";
        m.style.backgroundColor = "#f3f2ea";
    } else {
        l.style.position = "";
        l.style.display = "";
        l.style.marginTop = "";
        m.style.backgroundColor = "";
    }
}
