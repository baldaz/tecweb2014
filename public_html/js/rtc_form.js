$(document).ready(function(){
var i = 0;
    var src = ['../images/piscina.jpg', '../images/tennis.jpg', '../images/entrata_centro.jpg'];
setInterval(function(){
    $("#splash").attr('src', src[i]);
    i++;
    if(i == src.length) i = 0;
}, 6000);

$(".p_field").change(function(){
    var disc, date;
    var giorno = $("#giorno").val();
    var mese = $("#mese").val();
    disc = $("#disciplina").val();
    date = $("#anno").val() + "-" + $("#mese").val() + "-" + $("#giorno").val();
    var mesi = {
	01:31,
	02:28,
	03:31,
	04:30,
	05:31,
	06:30,
	07:31,
	08:31,
	09:30,
	10:31,
	11:30,
	12:31,
    };

    if(giorno > mesi[mese]){
	$("#tables").html("<div class='errore'>Errore data, ricontrollare il giorno(Dog)</div>");
    }
    else{
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
			    });			  
