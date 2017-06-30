
$(document).on('turbolinks:load', function(){
    $("#backboard div").removeClass("selected");
    var count = 0;
    var sp;
    var sv;

    $("#backboard").on("click", "div", function(e){
        var val = $(this).data('val');
        var me = $(this)
        
        if (count % 2 == 0){
            $("#backboard div").removeClass("selected");
            $.ajax ({
             type: 'POST',
             url: "https://chessappdenaux.herokuapp.com/"+val,
             success: function(d){
                if(d === true){
                  me.addClass("selected");
                  count +=1;
                  sp = me;
                  sv = val;
                }
            }
            });
        } else {
           $.ajax ({
             type: 'POST',
             //  http://localhost:3000
             // https://chessappdenaux.herokuapp.com
             url: "https://chessappdenaux.herokuapp.com/" + sv + "/" + val,
             success: function(d){
                count = 0;
             }
              
           });
           
           
        }


        
   });
});


