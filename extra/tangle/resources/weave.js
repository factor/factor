$(function() { $.getJSON("/all", false, function(json) {
    var nodes = $('#nodes');
    for (node in json) {
        nodes.append("<option value='" + json[node] + "'>" + json[node] + "</option>");
    }
    nodes.change(function(){
        if (this.value == 'new') {
            $('#node-content').hide();
            $('#edit-wrapper').show();
        } else {
            $('#node-content').show();
            $('#edit-wrapper').hide();
            $.get('/node', { node_id: this.value }, function(data){
                $('#node-content').text(data);
            });
        }
    });
    $('#node-submit').click(function(){
        $.post('/node', { node_content: $('#node-content-edit').val() }, function(data){
            nodes.append("<option value='" + data + "'>" + data + "</option>");
            var option = nodes.get(0).options[data];
            option.selected = true;
            nodes.change();
        });
        return false;
    });
});})
