# Modelo Entidade-Relacionamento da Aplicação UnB-RU

## Introdução

A aplicação UnB-RU é um sistema desenvolvido em Ruby on Rails para o gerenciamento do
Restaurante Universitário da Universidade de Brasília. O sistema permite controlar
alunos, campi, restaurantes, refeições, cartões, transações financeiras e o acesso
às catracas. Este documento descreve as entidades representadas no modelo
entidade-relacionamento e seus principais relacionamentos.

![Modelo Entidade-Relacionamento](image.png)

## Entidades principais

### 1. Universidade

- **ID**: Identificador único da universidade (chave primária).
- **Nome**: Nome da universidade.

**Relacionamento:** Uma universidade pode possuir um ou vários campi. Cada campus
deve estar associado a uma universidade.

### 2. Campus

- **Universidade ID**: Chave estrangeira associada à universidade.
- **ID**: Identificador único do campus (chave primária).
- **Nome**: Nome do campus.

**Relacionamento:** Cada campus pertence a uma universidade. Um campus pode
possuir um ou vários restaurantes.

### 3. Restaurante

- **ID**: Identificador único do restaurante (chave primária).
- **Campus**: Chave estrangeira associada ao campus onde o restaurante está
  localizado.

**Relacionamentos:** Cada restaurante pertence a um campus, está associado a
uma ou várias catracas e pode oferecer uma ou várias refeições. Um restaurante
também pode estar associado a nenhuma ou várias transações e inscrições
FastPass.

### 4. Aluno

- **Matrícula**: Identificador único do aluno (chave primária).
- **Nome**: Nome completo do aluno.
- **Saldo**: Saldo financeiro disponível para utilização no restaurante.

**Relacionamentos:** Um aluno pode possuir nenhum ou vários cartões, realizar
nenhuma ou várias transações, fazer nenhuma ou várias inscrições FastPass e
possuir nenhum ou vários registros de acesso no histórico das catracas.

### 5. Funcionário

- **Matrícula**: Identificador único do funcionário (chave primária).
- **Nome**: Nome completo do funcionário.

**Relacionamento:** Um funcionário pode estar associado a nenhuma ou várias
catracas. Cada catraca deve estar associada a um funcionário.

### 6. Cartão

- **Número**: Número identificador do cartão (chave primária).
- **Bandeira**: Bandeira ou operadora do cartão.
- **Nome**: Nome do titular do cartão.
- **Saldo**: Saldo disponível no cartão.
- **Data de validade**: Data até a qual o cartão é válido.
- **Código de verificação**: Código de segurança do cartão.

**Relacionamento:** Um aluno pode possuir nenhum ou vários cartões. Cada cartão
deve estar associado a um aluno.

### 7. Catraca

- **Restaurante ID**: Chave estrangeira associada ao restaurante.
- **Funcionário ID**: Chave estrangeira associada ao funcionário.
- **Número**: Número identificador da catraca.
- **Piso**: Piso onde a catraca está instalada.

**Relacionamentos:** Cada catraca pertence a um restaurante e está associada a
um funcionário. Uma catraca pode possuir nenhum ou vários registros no
histórico de acessos.

### 8. Tipo de Refeição

- **ID**: Identificador único do tipo de refeição (chave primária).
- **Nome da refeição**: Nome do tipo de refeição, como café da manhã, almoço ou
  jantar.
- **Hora de início**: Horário inicial em que o tipo de refeição é servido.
- **Hora final**: Horário final em que o tipo de refeição é servido.

**Relacionamento:** Um tipo de refeição pode estar associado a várias refeições.
Cada refeição deve possuir um tipo de refeição.

### 9. Refeição

- **Restaurante ID**: Chave estrangeira associada ao restaurante.
- **Refeição ID**: Identificador da refeição (chave estrangeira associada ao
  tipo de refeição).
- **Data**: Data em que a refeição será servida.
- **Opção normal**: Indica a opção normal do cardápio.
- **Opção ovolactovegetariana**: Indica a opção ovolactovegetariana do
  cardápio.
- **Opção vegetariana estrita**: Indica a opção vegetariana estrita do
  cardápio.

**Relacionamentos:** Cada refeição pertence a um restaurante e a um tipo de
refeição. Um restaurante pode oferecer várias refeições. Uma refeição pode
estar associada a nenhuma ou várias inscrições FastPass e transações.

### 10. Transação

- **Aluno ID**: Chave estrangeira associada ao aluno.
- **Restaurante ID**: Chave estrangeira associada ao restaurante.
- **Data e hora**: Data e hora em que a transação ocorreu (chave primária).
- **Tipo de transação**: Tipo da operação financeira realizada.
- **Valor transferido**: Valor movimentado na transação.

**Relacionamento:** Cada transação deve estar associada a um aluno e a um
restaurante. Um aluno e um restaurante podem participar de nenhuma ou várias
transações.

### 11. Inscrição FastPass

- **Aluno ID**: Chave estrangeira associada ao aluno.
- **Restaurante ID**: Chave estrangeira associada ao restaurante.
- **Refeição ID**: Chave estrangeira associada à refeição.
- **Data**: Data da inscrição (chave primária).
- **Hora de chegada**: Horário em que o aluno chegou ao restaurante.

**Relacionamento:** Cada inscrição FastPass deve estar associada a um aluno,
um restaurante e uma refeição. Um aluno, um restaurante ou uma refeição pode
estar associado a nenhuma ou várias inscrições FastPass.

### 12. Histórico Catraca

- **Catraca ID**: Chave estrangeira associada à catraca.
- **Aluno ID**: Chave estrangeira associada ao aluno.
- **Data e hora**: Data e hora do acesso (chave primária).

**Relacionamento:** Cada registro do histórico deve estar associado a uma
catraca e a um aluno. Um aluno ou uma catraca pode possuir nenhum ou vários
registros de acesso.

## Resumo dos relacionamentos

- Uma **universidade** possui um ou vários **campi**, e cada campus pertence a
  uma universidade.
- Um **campus** possui um ou vários **restaurantes**, e cada restaurante
  pertence a um campus.
- Um **restaurante** possui uma ou várias **catracas** e oferece uma ou várias
  **refeições**.
- Uma **catraca** pertence a um restaurante e está associada a um funcionário;
  um funcionário pode estar associado a nenhuma ou várias catracas.
- Um **tipo de refeição** classifica várias refeições, enquanto cada refeição
  possui um único tipo.
- **Transação**, **Inscrição FastPass** e **Histórico Catraca** são entidades
  associativas: cada registro depende das entidades às quais suas chaves
  estrangeiras apontam, mas cada entidade relacionada pode não possuir
  registros ou possuir vários.