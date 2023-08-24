window.onload = function() {
    var radios = document.getElementsByClassName("radiotab");
    if (radios.length > 0) {
        radios[0].checked = true;
    }
}

document.addEventListener('keydown', function (event) {
    if (event.code == 'Slash') {
        let input = document.getElementById('search');
        if (input != null) {
            if (input !== document.activeElement) {
                event.preventDefault();
                setTimeout(function() {
                    input.focus();
                }, 0);
            }
        }
    }
});
