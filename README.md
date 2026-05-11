# Gerenciador de Contatos CLI (Elixir)

Este sistema é uma aplicação de linha de comando robusta, desenvolvida em Elixir, projetada para gerenciar registros de contatos com persistência de dados em formato JSON.

## Arquitetura do Sistema

O projeto foi construído seguindo os princípios da programação funcional e separação de responsabilidades:

1.  **Módulo Principal (`LivroDeRegistrosDeContatos`)**: Atua como a interface do usuário (CLI). Gerencia o loop de interação, faz o parsing dos comandos e orquestra as chamadas para os outros módulos. Possui um tratamento de erros avançado para garantir que entradas inválidas não interrompam a execução.
2.  **Módulo de Lógica (`Contacts`)**: Contém as funções puras para manipulação da lista de contatos (adicionar, buscar, editar, excluir). Utiliza imutabilidade, sempre retornando novas versões das listas.
3.  **Módulo de Persistência (`Store`)**: Responsável pela comunicação com o sistema de arquivos, utilizando a biblioteca `Jason` para codificar e decodificar os dados em `contacts.json`.

---

## Funcionalidades e Comandos

### 1. Adicionar Contato (`add`)

Permite cadastrar um novo contato informando nome, empresa, telefone e e-mail.

- **Sintaxe**: `add --name "Nome" --company "Empresa" --phone "Número" --email "email@exemplo.com"`
- **Validação**: O sistema impede o cadastro se algum campo obrigatório estiver faltando.

### 2. Listar Contatos (`list`)

Exibe uma visão resumida de todos os contatos salvos.

- **Campos mostrados**: ID (Gerado automaticamente), Nome e Telefone.

### 3. Ver Detalhes (`show`)

Exibe todas as informações de um contato específico através do seu ID.

- **Sintaxe**: `show <id>`
- **UX**: O sistema detecta se o usuário digitou literalmente `<id>` e sugere o uso correto com números.

### 4. Buscar Contatos (`search`)

Realiza buscas flexíveis (substring e case-insensitive) em campos específicos.

- **Sintaxe**: `search --name joao` ou `search --phone 85` ou `search --email gmail`
- **Regra**: Aceita apenas uma flag por vez. Gera um log da última busca em `lib/parse.json`.

### 5. Excluir Contato (`del`)

Remove permanentemente um contato da base de dados pelo ID.

- **Sintaxe**: `del <id>`

### 6. Editar Contato (`edit`)

Permite a atualização parcial de um contato. Você pode alterar apenas um campo ou vários simultaneamente.

- **Sintaxe**: `edit <id> --phone 99999999`
- **Nota**: Mantém os dados não informados intactos.

---

## Diferenciais de UX e Robustez

- **Recursão de Cauda**: O loop principal é otimizado para não consumir memória extra, independentemente de quanto tempo a aplicação fique aberta.
- **Pattern Matching**: Toda a lógica de decisão é baseada em padrões, o que torna o código previsível e fácil de estender.
- **Tratamento de Erros**: Mensagens amigáveis com prefixos visuais (`✅`, `❌`, `⚠️`, `🔍`) ajudam o usuário a entender o status de cada operação.
- **Persistência Transparente**: Cada alteração (add, del, edit) é salva instantaneamente no arquivo JSON, garantindo que os dados não sejam perdidos ao sair.

---

## Como Rodar

1. Instale as dependências: `mix deps.get`
2. Inicie o sistema: `mix run -e "LivroDeRegistrosDeContatos.main"`
