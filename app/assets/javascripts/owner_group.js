function deleteUser(who){
	var groupid = $("#group_id").text();

	$.post( "/owner_group/rm_user", { netid: who, groupid: groupid})
	  .done(function( data ) {
			$("#row_" + who).remove();
		});
	return false;
}


$(document).ready(function() {
	
	function addMe(matchStr){

		var found = matchStr.match(/(.*)\((.*)\)/);
		var netid = found[2];
		var groupid = $("#group_id").text();

		$.post( "/owner_group/add_user", { netid: netid, groupid: groupid})
		  .done(function( data ) {
				var row = $("<tr>");
				row.attr("id",'row_'+found[2]);
				row.append( $("<td>").text(found[1]) );
				row.append( $("<td>").text(found[2]) );
		
				var anchor = $('<a></a>').attr("href","#").attr("id",'user_delete_'+found[2]);
				anchor.text("Remove");
				anchor.attr('onclick', 'return deleteUser("'+found[2]+'")');
				row.append( $("<td>").append( anchor));

				$("#user_table").append(row);
				$("#user_netid").val('');
			});
	}
	
	jQuery(function(){
		var r_opt = {
			 source: function( request, response ) {
				 $.getJSON( '/owner_group/ajax_users', {
					 term: request.term
				 }, response )
				 .success(function(data) {
					 if(data.length == 0)
					 	$("#empty-user-message").text("No results found");
					else
						$("#empty-user-message").empty();
	  			});
				},
			select: function(event, ui){ 
				addMe(ui.item.value);
			},
			search: function(event, ui){
				$("#empty-user-message").text("Searching...");
				$('#user_netid_add').hide();
			}
		};
		$('#user_netid').autocomplete(r_opt);		
	});
	

});