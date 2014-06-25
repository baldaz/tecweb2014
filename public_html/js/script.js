function validateLogin(){
    var errors = {};
    var username = document.forms["login"]["username"].value;
    var password = document.forms["login"]["passwd"].value;
    var patt=/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    if(!patt.test(username)) {
	errors["username"] = "<span id='errore_username' class='errore'>*</span>";
    }
    if(password.length < 1) {
	errors["passwd"] = "<span id='errore_passwd' class='errore'>*</span>";
    }
    if(Object.keys(errors).length > 0){
	reportErrors(errors, 'login');
	return false;
    }
    return true;
}

function validate(){
    var errors = {};
    var name = document.forms["form"]["nome"].value;
    var surn = document.forms["form"]["cognome"].value;
    var mail = document.forms["form"]["email"].value;

    if(name.length<1){
	errors["nome"] = "<span id='errore_nome' class='errore'>Inserire nome</span>";
    }
    if(surn.length<1){
	errors["cognome"] = "<span id='errore_cognome' class='errore'>Inserire cognome</span>";
    }
    var patt=/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if(!patt.test(mail)){
	errors["email"] = "<span id='errore_email' class='errore'>Inserire email</span>";
    }
    if(Object.keys(errors).length > 0){
	reportErrors(errors, 'content');
	return false;
    }
    return true;
}

function reportErrors(errors, parentNode){
    var node;
    var div = document.createElement("div");
    var content = document.createTextNode("Errori nel riempimento dei campi");
    div.appendChild(content);
    if(isInPage(document.getElementById('errore'))){
	document.getElementById('errore').remove();
    }
    div.id = 'errore';
/*    var err_name = ['errore_nome', 'errore_cognome', 'errore_email', 'errore_username', 'errore_passwd'];
    for(var i in err_name){
	if(isInPage(document.getElementById(err_name[i]))){
	    document.getElementById(err_name[i]).remove();
	}
    }*/
    var last = document.getElementById(parentNode);
    last.appendChild(div);
    for (var key in errors){
/*	var dump = "errore_" + key;
	var obj = document.getElementById(key);
	if(!document.body.contains(obj)){*/
	node = document.getElementById(key).style.boxShadow="0px 0px 8px #f00";
/*	node.style.borderColor = 'red';
/*	    node.insertAdjacentHTML('afterEnd', errors[key]);*/
    }
}

function isInPage(node) {
    return (node === document.body) ? false : document.body.contains(node);
}
/*
function get_cookie() {
    if(document.cookie.length > 0){
	return document.cookie;
    }
    else 
}
*/