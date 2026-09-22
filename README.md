# Caderno de Campo do Vale — Controle de Estoque de Insumos

Aplicação desenvolvida para a disciplina de **Programação para Dispositivos Móveis** do Bacharelado em Sistemas de Informação no **Instituto Federal Goiano — Campus Ceres**, sob orientação do Prof. Dr. Paulo César Ferreira Melo.

---

## 👥 Integrantes e Divisão de Papéis

* **Construtor:** Samuel Antunes de Oliveira Gomes
  * *Responsabilidade:* Modelagem dos dados (`Insumo`), gerência de estado mutável (`setState`), validações de regra de negócio (recusa de baixa inválida e alertas de estoque mínimo) e integração dos componentes do Flutter.
* **Designer de Interface:** Samuel Kushi de Paiva
  * *Responsabilidade:* Hierarquia visual da tela, contraste dinâmico de cores para alertas no campo, dimensionamento dos alvos de toque e escolha dos ícones e categorias.
* **Relator:** Matheus Felipe Bastos Pereira
  * *Responsabilidade:* Documentação do projeto, estruturação do `README.md`, gestão do repositório Git e condução da demonstração ao vivo.

---

## 🌾 Sobre a Funcionalidade (Opção D)

A tela de **Controle de Estoque de Insumos** permite ao produtor rural do Vale de São Patrício acompanhar em tempo real as quantidades disponíveis de sementes, fertilizantes e defensivos agrícolas.

### Principais Recursos
* **Listagem Dinâmica e Mutável:** Acompanhamento de insumos com indicadores de progresso e quantidades expressas em unidades agrícolas regionais (`sc`, `t`, `L`).
* **Operações Rápidas de Entrada e Baixa:** Botões dedicados (`+` / `−`) ajustados por passo padrão de cada insumo.
* **Validação de Regra de Negócio:** Bloqueio automático de retiradas superiores ao saldo em estoque, emitindo alertas visuais de recusa.
* **Destaque Condicional de Estoque Mínimo:** Identificação imediata através de cards e faixas vermelhas quando a quantidade cai abaixo do limite cadastrado.
* **Cadastro Integrado:** Formulário modal para inclusão de novos produtos com validações de dados incorretos ou negativos.
* **Remoção Interativa por Gesto:** Exclusão rápida de itens arrastando para a esquerda (`Dismissible`), com ação de restauração imediata ("DESFAZER").

---

## 🚜 Decisões de Interface para Uso no Campo

1. **Alvos de Toque Generosos e Botões de Ação Direta (`IconButton.filled`):**
   * *Justificativa:* Pensando no produtor rural que opera o smartphone em ambiente externo, muitas vezes utilizando luvas de proteção ou com as mãos sujas durante o manuseio de insumos, os botões de incremento e decremento possuem área de clique expandida e ícones destacados para evitar toques acidentais.
2. **Contraste Dinâmico de Alto Impacto para Alertas Visuais:**
   * *Justificativa:* Sob luz solar direta na lavoura, telas convencionais perdem visibilidade. O sistema utiliza uma paleta de alto contraste com alteração de cor dos cards de verde (`#1E8449`) para vermelho de alerta (`#C0392B`), acompanhado de um indicador de progresso visual e uma faixa fixa no topo ressaltando quais itens exigem reposição imediata.

---

## 🚀 Como Executar o Projeto

1. Certifique-se de ter o **Flutter SDK** instalado e configurado no seu ambiente.
2. Clone este repositório:
   ```bash
   git clone [https://github.com/samueloli22/Caderno-de-Campo-do-Vale.git](https://github.com/samueloli22/Caderno-de-Campo-do-Vale.git)