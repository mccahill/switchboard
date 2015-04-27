$(document).ready(function(){
	
	$("#add_subnet_btn").button({
		icons: {
			primary: "ui-icon-plus"
		},
		text: false
	});
	$("#add_ip_btn").button({
		icons: {
			primary: "ui-icon-plus"
		},
		text: false
	});
	$("#add_vlan_btn").button({
		icons: {
			primary: "ui-icon-plus"
		},
		text: false
	});
	
	//************* groups stuff
	
	$( "#selectable" ).selectable();
	
	$(".inbar li").click(function(){
		console.log("This is " + $(this).data('group-id'));
		$.getJSON("/admin/ajax_get_members",{id: $(this).data('group-id')}, function( data ){
			var s = $("#memberList");
			s.val('');
			var ol = $('<ol>');
			// ol.selectable();
			$.each(data, function(id, option){
				var li = $('<li>').text('baz');
				ol.append(li);
			});
			s.append(ol);
		});
	});
			
	$(".chg_ip_owner").click(function(){
		var mybut = $(this);
		var id = mybut.data('id');
		$("#og_"+id).toggle();
		$.getJSON("/admin/ajax_get_groups", function( data ){
			var s = $("<select id=\"foobar2\" name=\"foobar2\" />");
			
			$.each(data, function(id, option) {
				s.append($('<option></option>').val(option.value).html(option.name));
			});
			var foo = mybut.closest('td').append( s);
			s.change(function(){
				var val = $(this).val();
				$.post("/admin/ajax_set_group", {
								id: id,
								group: val
							}, function(data){
								$("#notice").text(data.text).show();
								$("#name_"+id).text(data.name);
							});
				$("#og_"+id).toggle();
				s.remove();
			});
		});
	});
});