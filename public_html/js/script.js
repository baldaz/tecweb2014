/*function destroy(tag){
    document.getElementById(tag).outerHTML='';
}

function validate(){
    var count=0;
    var x=document.forms["form"]["nome"].value;
    var y=document.forms["form"]["cognome"].value;
    var mail=document.forms["form"]["email"].value;

    if(x.length<1){
	var name = document.getElementById('nome');
	name.insertAdjacentHTML('afterEnd', "<span id='err_nome' class='errore'>pirla pirla pirla</span>");
	setTimeout(function(){destroy('err_nome')}, 2000);
	count++;
    }
    else{document.getElementById('err_nome').outerHTML='';}
    if(y.length<1){
	var surname = document.getElementById('cognome');
	surname.insertAdjacentHTML('afterEnd', "<span id='err_cogn' class='errore'>pirla </span>");
	setTimeout(function(){destroy('err_cogn')}, 2000);
	count++;
    }
    else{document.getElementById('err_cogn').outerHTML='';}
    var patt=/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if(!patt.test(mail)){
	var email = document.getElementById('email');
	email.insertAdjacentHTML('afterEnd', "<span id='err_email' class='errore'>pirla </span>");
	setTimeout(function(){destroy('err_email')}, 2000);
	count++;
    }
    else{document.getElementById('err_email').outerHTML='';}
    
    return (count==0);
}
*/