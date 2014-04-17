function reload_table(){
    var campo=document.getElementById("field").value;
    document.getElementById("campo").value=campo;
    
}

function validate(){
    var count=0;
    var x=document.forms["form"]["nome"].value;
    var y=document.forms["form"]["cognome"].value;
    var z=document.forms["form"]["telefono"].value;
    var mail=document.forms["form"]["email"].value;
    var data=document.forms["form"]["data"].value;

    if(x.length<1){
	// messaggio nome mancante su div/span nel template
	document.getElementById('err_nome').innerHTML='pirla pirla pirla pirla';
	count++;
    }
    else{document.getElementById('err_nome').innerHTML='';}
    if(y.length<1){
	document.getElementById('err_cognome').innerHTML='pirla';
	count++;
    }
    else{document.getElementById('err_cognome').innerHTML='';}
    if(z.length<2 || isNaN(z)){
	document.getElementById('err_telefono').innerHTML='pirdog';
	count++;
    }
    else{document.getElementById('err_telefono').innerHTML='';}
    
    var patt=/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if(!patt.test(mail)){
	document.getElementById('err_email').innerHTML='fallimendog';
	count++;
    }
    else{document.getElementById('err_email').innerHTML='';}
    if(data eq ''){
	document.getElementById('err_data').innerHTML='datadog';
	count++;
    }
    else{document.getElementById('err_data').innerHTML='';}
    return (count==0);
    // etc per tutti i campi
}

$( "form" ).submit(function( event ) {
  if ( $( "input:first" ).val() === "correct" ) {
    $( "span" ).text( "Validated..." ).show();
    return;
  }
 
  $( "span" ).text( "Not valid!" ).show().fadeOut( 1000 );
  event.preventDefault();
});