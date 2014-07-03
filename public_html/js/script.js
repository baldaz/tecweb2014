function validateCourse(){
    var errors = new Array();
    var list = new Array('nome', 'Mensile', 'Trimestrale', 'Semestrale', 'Annuale');
    var nome = document.getElementById('nome').value;
    var mensile = document.getElementById('mensile').value;
    var trimestrale = document.getElementById('trimestrale').value;
    var semestrale = document.getElementById('semestrale').value;
    var annuale = document.getElementById('annuale').value;
    
    var prezzo = /(\d+).\€/;
    if(nome.length < 1) {
	errors.push("nome");
    }
    if(!prezzo.test(mensile)){
	errors.push("mensile");
    }
    if(!prezzo.test(trimestrale)){
	errors.push("trimestrale");
    }
    if(!prezzo.test(semestrale)){
	errors.push("semestrale");
    }
    if(!prezzo.test(annuale)){
	errors.push("annuale");
    }
    if(Object.keys(errors).length > 0){
	reportErrors(errors, 'prezzi', list);
	return false;
    }
    return true;
}

function validateNews(){
    var errors = new Array();
    var list = new Array('titolo', 'data', 'contenuto');
    var titolo = document.getElementById('titolo').value;
    var data = document.getElementById('data').value;
    var contenuto = document.getElementById('contenuto').value;
    var data_patt = /^(0[1-9]|[12][0-9]|3[01])[- \/.](0[1-9]|1[012])[- \/.](19|20)\d\d$/;
    
    if(titolo.length < 1){
	errors.push("titolo");
    }
    if(!data_patt.test(data)){
	errors.push("data");
    }
    if(contenuto.length < 1){
	errors.push("contenuto");
    }
    if(Object.keys(errors).length > 0){
	reportErrors(errors, 'content', list);
	return false;
    }
    return true;
}

function validateLogin(){
    var errors = new Array();
    var list = new Array('lg-email', 'passwd');
    var username = document.getElementById('lg-email').value;
    var password = document.getElementById('passwd').value;
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
    var email = document.getElementById('email').value;
    var message = document.getElementById('message').value;
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
    var vpwd = document.getElementById('vpassword').value;
    var opwd = document.getElementById('password').value;

    if(vpwd.length < 1){
	errors.push("vpassword");
    }
    if(opwd.length < 1){
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
    var name = document.getElementById('nome').value;
    var surn = document.getElementById('cognome').value;
    var mail = document.getElementById('email').value;
    var tel  = document.getElementById('telefono').value;
    if(bip){
	var pwd  = document.getElementById('password').value;
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
