function reload_table(){
    var campo=document.getElementById("field").value;
    document.getElementById("campo").value=campo;
    
}

function validate(){
    var count=0;
    if(document.getElementById("nome").value==""){
	// messaggio nome mancante su div/span nel template
	count++;
    }
    else if(document.getElementById("cognome").value==""){
	count++;
    }
    // etc per tutti i campi
    return (count==0);
}