function toggleSidebar() {
    var l = document.getElementById("left");
    var m = document.getElementById("menu");
    if (l.style.display === "") {
        l.style.display = "inline";
        var darkMode = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
        if (!darkMode) {
            m.style.backgroundColor = "#f3f2ea";
        }
    } else {
        l.style.display = "";
        m.style.backgroundColor = "";
    }
}
