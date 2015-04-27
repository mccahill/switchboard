$(document).ready(function() {
  $( document ).tooltip({
    items: "img, [title]",
    content: function() {
      var element = $( this );
      if ( element.is( "[title]" ) ) {
        return element.attr( "title" );
      }
      if ( element.is( "img" ) ) {
        return element.attr( "alt" );
      }
    }
  	
  });
});