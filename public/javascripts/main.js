// JavaScript Document

function atualizar(obj) {
	var uf = obj.options[obj.selectedIndex].value;
	if (uf != '') document.location.href = document.location.href.replace(/turno\/?([a-z]{2})?$/,'turno/' + uf + '');
}
function atualizar_city(obj) {
	var city = obj.options[obj.selectedIndex].value;
	if (city != '') document.location.href = document.location.href.replace(/turno\/([a-z]{2})\/?([0-9]+)?$/,'turno/$1/' + city + '');
}
