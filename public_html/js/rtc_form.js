﻿/*var i = 0;
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
    var disc, date;
    var giorno = $("#giorno").val();
    var mese = $("#mese").val();
    disc = $("#disciplina").val();
    date = $("#anno").val() + "-" + $("#mese").val() + "-" + $("#giorno").val();
    var mesi = {
	1:31,
	2:28,
	3:31,
	4:30,
	5:31,
	6:30,
	7:31,
	8:31,
	9:30,
	10:31,
	11:30,
	12:31,
    };

    if(giorno > mesi[mese]){
	$("#tables").html("<div class='errore'>Errore data, ricontrollare il giorno(Dog)</div>");}
	else{
/*    var disciplina, date;
    var fase=$("#fase").val();
    if (undefined != fase ){
	disciplina=$("#disciplina_h").val();
>>>>>>> c5ab22f96463dee5d3fa7ef805948dfaded70c38
    }
    else{
/*    var fase=$("#fase").val();
/*    if (undefined != fase ){
	disciplina=$("#disciplina_h").val();
/*    }
    else{ disciplina=$("#disciplina").val();}
/*    date=$("#data").val();
	
/*    if(date.length == '' || date.length == 0){
	var d=new Date();
//	date=d.getFullYear()+'-'+d.getMonth()+'-'+d.getDate(); //funziona di merda, sbaglia il mese
    }*/

//    	alert(disciplina+" e "+date);*/
    $.ajax({
	type: "POST",
	url: "vbooked.pl",
//	data: "disciplina=" + disciplina + "&data=" + date,
	data: {disciplina: disc, data: date},
	error: function(request) { 
	    alert("Errore nella visualizzazione, ricontrollare che l' inserimento dei campi data e disciplina rispetti il formato richiesto.");
        }, 
	success: function(perl_data){
	    $("#tables").html(perl_data);
	}
    });
    return false;
    }
});

/*
document.getElementById('tables').addEventListener('click', function() {
 
    (this.style.height == '18em' || this.style.height == '')? this.style.height = '54em' : this.style.height = '18em';
    
<<<<<<< HEAD
}, false );			   */ 
});

