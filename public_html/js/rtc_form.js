/*var i = 0;
var src = ['../images/campo-tennis.jpg', '../images/campo_calcetto.jpg', '../images/seagal-3.jpg', '../images/fitness.jpg'];
setInterval(function(){
    $("#ft").attr('src', src[i]);
    i++;
    if(i == src.length) i = 0;
}, 5000);

$("#telefono").keydown(function(event){
    if((event.which < 47 || event.which > 57) && event.which !=8 && event.which != 9 && event.which != 46){
	event.preventDefault();
	var error = $("<span class='errore'>Inserire numeri</span>");
	if(!$(".errore").length){
	    $(this).after(error);
	    setTimeout(function() {
		$(".errore").remove();
	    }, 2000);
	}
    }
    else{
	$(".errore").remove();
    }
});
*/
$(document).ready(function(){$(".p_field").change(function(){
    var disciplina, date;
    var fase=$("#fase").val();
    if (undefined != fase ){
	disciplina=$("#disciplina_h").val();
    }
    else{ disciplina=$("#disciplina").val();}
    date=$("#data").val();
	
    if(date.length == '' || date.length == 0){
	var d=new Date();
//	date=d.getFullYear()+'-'+d.getMonth()+'-'+d.getDate(); //funziona di merda, sbaglia il mese
    }

//    	alert(disciplina+" e "+date);
    $.ajax({
	type: "GET",
	url: "vbooked.pl",
	data: "disciplina=" + disciplina + "&data=" + date,
	error: function(request) { 
	    alert(request.responseText);
        }, 
	success: function(perl_data){
	    $("#tables").html(perl_data);
	}
    });
    return false;
});


document.getElementById('tables').addEventListener('click', function() {
 
    (this.style.height == '18em' || this.style.height == '')? this.style.height = '54em' : this.style.height = '18em';
    
}, false );			    });