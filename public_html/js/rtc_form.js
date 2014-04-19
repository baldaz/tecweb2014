var triggered=0;
$("#telefono").keydown(function(event){
    if((event.which < 47 || event.which > 57) && event.which !=8 && event.which != 9 && event.which != 46){
	$("#err_telefono").text("Inserire numeri");
	triggered++;
    }
    else if(event.which == 46 || event.which == 8 || event.which==9){
	triggered--;
	if(triggered==0){
	    $("#err_telefono").text("");
	}
    }
});