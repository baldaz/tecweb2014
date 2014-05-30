$("#telefono").keydown(function(event){
    if((event.which < 47 || event.which > 57) && event.which !=8 && event.which != 9 && event.which != 46){
	event.preventDefault();
	$("#err_telefono").text("Inserire numeri");
    }
    else{
	$("#err_telefono").text("");
    }
});

$(".p_field").change(function(){
    var disciplina, date;
    var fase=$("#fase").val();
    if (undefined != fase ){
	disciplina=$("#disciplina_h").val();
    }
    else{ disciplina=$("#disciplina").val();}
    date=$("#data").val();
	
    if(date.length == ''){
	var d=new Date();
	date=d.getFullYear()+'-'+d.getMonth()+'-'+d.getDate();
    }

    //	alert(disciplina+" e "+date);
    $.ajax({
	type: "GET",
	url: "vbooked.pl",
	data: "disciplina=" + disciplina + "&data=" + date,
	error: function() { 
	    alert("script call was not successful");
        }, 
	success: function(perl_data){
	    $("#tables").html(perl_data);
	}
    });
    return false;
});
/*
$("#telefono").keydown(function(event) {
  // Backspace, tab, enter, end, home, left, right,decimal(.)in number part, decimal(.) in alphabet
  // We don't support the del key in Opera because del == . == 46.
  var controlKeys = [8, 9, 13, 35, 36, 37, 39,110,190];
  // IE doesn't support indexOf
  var isControlKey = controlKeys.join(",").match(new RegExp(event.which));
  // Some browsers just don't raise events for control keys. Easy.
  // e.g. Safari backspace.
  if (!event.which || // Control keys in most browsers. e.g. Firefox tab is 0
      (49 <= event.which && event.which <= 57) || // Always 1 through 9
      (96 <= event.which && event.which <= 106) || // Always 1 through 9 from number section 
      (48 == event.which && $(this).attr("value")) || // No 0 first digit
      (96 == event.which && $(this).attr("value")) || // No 0 first digit from number section
      isControlKey) { // Opera assigns values for control keys.
    return;
  } else {
    event.preventDefault();
  }
});*/