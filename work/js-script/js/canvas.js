var CANVAS_MODULE = CANVAS_MODULE || function() {
	
	//FIXME should be given as parameters or pushed on module's environment stack
	var canvas;
	var context;
	
	$(function() {
		canvas = document.getElementById("canvas");
		if(!!canvas) {
		  context = canvas.getContext("2d");
		}
	});
	
	return {
		'supported': is_supported,
		'draw_line': draw_line,
		'draw_rectangle': draw_rectangle,
		'clear_rectangle': clear_rectangle,
		'clear_canvas': clear_canvas,
		'set_color': set_color		
	}
	
	function is_supported() {
		return !!canvas;
	}
	
	function clear_canvas() {
		clear_rectangle(0, 0, canvas.width, canvas.height);
	}
	
	function clear_rectangle(x1, y1, x2, y2) {
		context.clearRect(x1, y1, x2, y2);		
	}

	function draw_line(x1, y1, x2, y2) {
		context.save();
		context.beginPath();
		context.moveTo(x1, y1);
		context.lineTo(x2, y2);
		context.stroke();
		context.restore();
	}
	
	function draw_rectangle(x, y, width, height) {
		context.save();
		context.translate(x, y);
    context.fillRect(0, 0, width, height);
    context.restore();		
	}
	
	function set_color(r, g, b) {
		var alpha = 1;
		var style = "rgba(" + r + ", " + g + "," + b + ", " + alpha + ")";
		context.fillStyle = style; 
		context.strokeStyle = style;
	}
	
}();
