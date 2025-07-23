# Cubos DevOps Challenge

Bem-vindo ao projeto do Desafio DevOps da Cubos! Este repositório contém uma aplicação web composta por um frontend (usando Nginx), um backend (usando Node.js), um banco de dados PostgreSQL e orquestração com Terraform. Abaixo estão as instruções para configuração, execução e validação do projeto.

## Pré-requisitos

Antes de executar o projeto, certifique-se de que os seguintes softwares estão instalados na sua máquina:

- **Docker**: Versão 20.10 ou superior (necessário para criar e rodar os contêineres).
- **Terraform**: Versão 1.0 ou superior (usado para orquestração).
- **Node.js**: Versão 18.x (necessário para o ambiente do backend, mas instalado automaticamente no contêiner).
- **Git**: Para clonar o repositório (versão 2.30 ou superior recomendada).

### Verificação de Instalação
- Docker: Execute `docker --version` no terminal.
- Terraform: Execute `terraform -version` no terminal.
- Node.js: Não é necessário verificar localmente, pois é gerenciado pelo Dockerfile do backend.
- Git: Execute `git --version` no terminal.

Se algum pré-requisito estiver ausente, instale-o seguindo as instruções oficiais:
- Docker: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
- Terraform: [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)
- Node.js: [https://nodejs.org/](https://nodejs.org/) (opcional, mas útil para desenvolvimento).
- Git: [https://git-scm.com/downloads](https://git-scm.com/downloads)

## Estrutura do Projeto

A estrutura de diretórios deve ser mantida para que o Terraform funcione corretamente. Após clonar o repositório, você verá:

desafio-devops/
├── backend/           # Contém o código e Dockerfile do backend (Node.js)
├── database/          # Contém o Dockerfile e init.sql para o banco de dados PostgreSQL
├── frontend/          # Contém o código e Dockerfile do frontend (Nginx)
├── terraform/         # Contém os arquivos de configuração do Terraform
├── README.md          # Este arquivo


- **backend/**: Inclui o arquivo `index.js` (servidor Node.js), `package.json` e o `Dockerfile` para construir a imagem `backend:latest`.
- **database/**: Inclui o `Dockerfile` baseado em `postgres:15.8` e o `init.sql` para inicializar a tabela `users`.
- **frontend/**: Inclui `index.html`, `nginx.conf` e o `Dockerfile` para construir a imagem `frontend:latest`.
- **terraform/**: Contém `main.tf` para orquestração com Terraform.

## Como Executar

Siga os passos abaixo para configurar e executar o projeto:

### 1. Clone o Repositório
Clone o repositório para o seu ambiente local:
```bash
git clone <URL_DO_REPOSITORIO>
cd desafio-devops

2. Orquestração com Terraform
O Terraform é usado para criar e gerenciar os contêineres. Navegue até o diretório terraform e execute os seguintes comandos:
cd terraform
terraform init
terraform apply

terraform init: Inicializa o ambiente Terraform e baixa o provedor Docker.
terraform apply: Cria os contêineres, redes, volumes e imagens. Você será solicitado a digitar yes para confirmar a aplicação. Responda yes e pressione Enter.

3. Acesse a Aplicação
Após a execução bem-sucedida do terraform apply, abra um navegador e acesse: http://localhost:8080

Clique no botão "Verificar Backend e Banco" na página. O esperado é um retorno JSON como {"database": true, "userAdmin": true}, indicando que o backend e o banco estão funcionando.


Dependências
O projeto utiliza as seguintes dependências:

Imagens Docker:
postgres:15.8 (para o banco de dados).
node:18-alpine (base para o backend).
nginx:alpine (base para o frontend).
Terraform Provider:
kreuzwerker/docker ~> 3.0 (para orquestração via Terraform).
Dependências Node.js:
pg@^8.11.3 (para conexão com PostgreSQL no backend).
Essas dependências são baixadas automaticamente durante a execução do Terraform ou construção das imagens.

Configuração dos Componentes

Banco de Dados (db)
Imagem: postgres:15.8 (baixada do Docker Hub).
Dockerfile: Localizado em database/Dockerfile, configura o ambiente PostgreSQL.
Configuração:
Banco: app_db
Usuário: admin
Senha: securepassword
Inicialização: A tabela users é criada via init.sql (em database/init.sql) com um usuário admin_user de role admin.
Backend
Imagem: backend:latest (construída a partir de backend/Dockerfile)
Porta: Interna 5000, mapeada para 5001 no host.
Funcionalidade: Responde a /api com informações do banco de dados.
Frontend
Imagem: frontend:latest (construída a partir de frontend/Dockerfile)
Porta: Interna 80, mapeada para 8080 no host.
Funcionalidade: Serve uma página HTML simples com um botão que chama o endpoint /api do backend via proxy Nginx.
Notas Importantes
Portas: O projeto usa as portas 5001 (backend) e 8080 (frontend). Certifique-se de que essas portas estejam livres no seu sistema. Se houver conflitos:
No Windows: Use netstat -aon | findstr :5001 e netstat -aon | findstr :8080 para identificar o PID, e encerre o processo no Gerenciador de Tarefas.
No Linux/Mac: Use lsof -i :5001 e lsof -i :8080, e encerre com kill -9 <PID>.
Portabilidade: A configuração usa caminhos relativos (../backend, ../frontend, ../database) no main.tf, assumindo que o diretório terraform/ está dentro de desafio-devops/. Mantenha essa estrutura.
Limpeza: Para remover os contêineres após o uso, execute:

cd terraform
terraform destroy