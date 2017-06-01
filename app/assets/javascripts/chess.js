$(document).ready(function(){
    $("#backboard").on("click", "div", function(e){
        $("#backboard div").removeClass("selected");
        var val = $(this).data('val');
        $.ajax ({
        	type: 'POST',
        	url: "https://localhost:3000/chess/:pos",
        	data: {pos: {value: val}},
        	success: function(d){
        	  if(d === true){
        		$(this).addClass("selected").append("<p>"+val+"<p>");
        	  }
        	}
        });
   });
});


