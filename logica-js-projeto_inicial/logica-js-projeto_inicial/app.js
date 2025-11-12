alert("Boas vindas ao jogo do número secreto");
let numeroSecreto = 5;
console.log("Esse é o número secreto:" + numeroSecreto);
let chute;
let tentativa = 1;

// enquanto chute não for igual ao número secreto
while(chute!= numeroSecreto){
chute = prompt("Escolha um número de 1 a 5:");
console.log("A tentativa de resposta foi:" + chute);
// se o chute for igual ao número secreto.
if (chute==numeroSecreto){
    alert(`Isso ai! Você acertou o número secreto ${numeroSecreto} com ${tentativa} tentativas.`);
} else {
    if (chute > numeroSecreto) {
        alert(`O número secreto é menor que ${chute}`);
    } else {
        alert(`O número secreto é maior que ${chute}`);
    }
  }
  // tentativas = tentivas + 1;
  tentativa++;
}