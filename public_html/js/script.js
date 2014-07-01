function validateCourse(){
    var errors = new Array();
    var list = new Array('nome', 'Mensile', 'Trimestrale', 'Semestrale', 'Annuale');
    var nome = document.forms["courses"]["nome"].value;
    var mensile = document.forms["courses"]["mensile"].value;
    var trimestrale = document.forms["courses"]["trimestrale"].value;
    var semestrale = document.forms["courses"]["semestrale"].value;
    var annuale = document.forms["courses"]["annuale"].value;
    
}

function validateLogin(){
    var errors = new Array();
    var list = new Array('lg-email', 'passwd');
    var username = document.forms["loginfrm"]["lg-email"].value;
    var password = document.forms["loginfrm"]["passwd"].value;
    var patt=/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    if(!patt.test(username)) {
	errors.push("lg-email");
    }
    if(password.length < 1) {
	errors.push("passwd");
    }
    if(Object.keys(errors).length > 0){
	reportErrors(errors, 'login', list);
	return false;
    }
    return true;
}

function validate_contact(){
    var errors = new Array();
    var list = new Array('email', 'message');
    var email = document.forms["contattaci"]["email"].value;
    var message = document.forms["contattaci"]["message"].value;
    var patt = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    if(!patt.test(email)){
	errors.push("email");
    }
    if(message.length < 1 || message.length > 250){
	errors.push("message");
    }
    if(Object.keys(errors).length > 0){
	reportErrors(errors, 'content', list);
	return false;
    }
    return true;
}

function validate_pwd_change(){
    var errors = new Array();
    var list = new Array('vpassword', 'password');
    var vpwd = document.forms["pwd_change"]["vpassword"].value;
    var opwd = document.forms["pwd_change"]["password"].value;

    if(vpwd.length < 6){
	errors.push("vpassword");
    }
    if(opwd.length < 6){
	errors.push("password");
    }
    if(Object.keys(errors).length > 0){
	reportErrors(errors, 'content', list);
	return false;
    }
    return true;
}

function validate(bip){
    var errors = new Array();
    var list = new Array('nome', 'cognome', 'email', 'telefono');
    var name = document.forms["form"]["nome"].value;
    var surn = document.forms["form"]["cognome"].value;
    var mail = document.forms["form"]["email"].value;
    var tel  = document.forms["form"]["telefono"].value;
    if(bip){
	var pwd  = document.forms["form"]["password"].value;
	list.push("password");
    }
    if(name.length<1){
	errors.push("nome");
    }
    if(surn.length<1){
	errors.push("cognome");
    }
    if(bip){
	if(pwd.length < 6){
	    errors.push("password");
	}
    }
    if(isNaN(tel) || tel.length < 6){
	errors.push("telefono");
    }
    var patt=/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if(!patt.test(mail)){
	errors.push("email");
    }
    if(Object.keys(errors).length > 0){
	reportErrors(errors, 'content', list);
	return false;
    }
    return true;
}

function reportErrors(errors, parentNode, EList){
    var div = document.createElement("div");
    var content = document.createTextNode("Errori nel riempimento dei campi");
    div.appendChild(content);
    if(isInPage(document.getElementsByClassName('errore')[0])){
	document.getElementsByClassName('errore')[0].remove();
    }
    for(var i in EList){
	var node = document.getElementById(EList[i]);
	if(isInPage(node)){
	    node.style.boxShadow = "";
	}
    }
    div.className = 'errore';
    var last = document.getElementById(parentNode);
    last.appendChild(div);
    for (var i in errors){
	document.getElementById(errors[i]).style.boxShadow = "0px 0px 8px #f00";
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