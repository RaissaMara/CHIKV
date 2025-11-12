//Pergunte ao usuário qual é o dia da semana. 
// Se a resposta for "Sábado" ou "Domingo", mostre "Bom fim de semana!". 
// Caso contrário, mostre "Boa semana!".

let dia = prompt("Qual é o dia da semana?Responda com:seg, ter, quar, qui, sex, sab, dom.");
let finalSemana ="sab"||"dom";
if (dia === finalSemana){
    alert("Bom fim de semana!");
    console.log("Bom fim de semana!");
} else { 
    alert("Boa semana!");
    console.log("Boa semana!");
}

//Verifique se um número digitado pelo usuário é positivo ou negativo. 
// Mostre um alerta informando.

let numero = parseInt(prompt("Digite um número, por favor!"));
if (numero>0){
    alert(`"Seu número é Positivo"${numero}`);
} else {(numero<0);
    alert (`"Seu número é Negativo"${numero}`);
}

//Crie um sistema de pontuação para um jogo. 
// Se a pontuação for maior ou igual a 100, mostre "Parabéns, você venceu!".
//Caso contrário, mostre "Tente novamente para ganhar.".

alert ("bem vindo ao jogo!");
let pontos = parseInt(prompt("Digite a pontuação obtida durante a partida:"));
if(pontos>=100){
    alert("Parabéns, você venceu!");
} else {
    alert("Tente novamente para ganhar.");
}

//Crie uma mensagem que informa o usuário sobre o saldo da conta,
// usando uma template string para incluir o valor do saldo.

let saldoConta = 10000;
alert(`"Seu Saldo em Conta é"${saldoConta}`);

//Peça ao usuário para inserir seu nome usando prompt. 
//Em seguida, mostre um alerta de boas-vindas usando esse nome.

let nome = prompt("Digite seu nome:");
alert(`"Bem vindo," ${nome}`);

//Leia a gramatica sintática do javaScript:
//<https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Lexical_grammar#automatic_semicolon_insertion>