/* This code will produce Hello World inside a HTML div with cass "root" */
var h1 = document.createElement("h1");
h1.innerHTML = "Hello World!";

var p = document.createElement("p")
p.innerHTML = "I was created using only JavaScript"

document.getElementById(id="root").appendChild(h1).appendChild(p);

