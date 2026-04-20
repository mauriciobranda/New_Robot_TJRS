🤖 Robot TJRS - Automação de Consultas Processuais
Robô automatizado para consulta e extração de dados processuais do site do Tribunal de Justiça do Rio Grande do Sul (TJRS). Desenvolvido em Robot Framework com Selenium, executa diariamente no Google Cloud Run e salva os resultados automaticamente no Google Drive.
📋 Descrição
Este projeto automatiza o processo de:

✅ Consulta de processos judiciais via URLs diretas
✅ Extração de dados estruturados de tabelas HTML
✅ Geração de relatórios em formato CSV
✅ Upload automático para Google Drive
✅ Registro de logs detalhados com timestamp
✅ Execução programada diariamente (Cloud Scheduler)

🚀 Características Gerais

Headless Mode: Execução em segundo plano sem interface gráfica
Cloud Native: Deploy containerizado no Google Cloud Run
Agendamento: Execução automática via Cloud Scheduler
Armazenamento: Upload automático para Google Drive via API
Escalável: Processa múltiplas consultas em lote
Logs Completos: Rastreamento de todas as operações

🛠️ Tecnologias

Robot Framework 6.1.1 - Framework de automação
SeleniumLibrary - Interação com navegadores
Python 3.11 - Linguagem de suporte
Google Cloud Run - Hospedagem serverless
Google Cloud Scheduler - Agendamento de tarefas
Google Drive API - Armazenamento de resultados
Docker - Containerização

🔧 Configuração Local
Pré-requisitos

Python 3.11+
Chrome/Chromium
Robot Framework
Conta Google Cloud (para deploy)

Instalação
bash# Clone o repositório
git clone https://github.com/mauriciobranda/New_Robot_TJRS.git
cd New_Robot_TJRS

# Instale as dependências
pip install -r requirements.txt

# Execute localmente
robot --outputdir output tests/forms_tj.robot
☁️ Deploy no Google Cloud
Pré-requisitos

Google Cloud SDK instalado
Projeto GCP criado (newrobottjrs)
Billing ativado
Service Account configurada para Google Drive

Deploy Rápido
bash# 1. Configure o projeto
gcloud config set project newrobottjrs

# 2. Execute o deploy
chmod +x deploy.sh
./deploy.sh

# 3. Configure execução diária
chmod +x setup-scheduler.sh
./setup-scheduler.sh
Para instruções detalhadas, consulte:

📖 GUIA-DE-DEPLOY.md
📁 CONFIGURAR-GOOGLE-DRIVE.md

📊 Formato dos Dados
Arquivo de Entrada (nomes.csv)
csvNome;Status;URL
NOME PESSOA;ATIVO;https://www.tjrs.jus.br/...
Arquivos de Saída

{nome}_processos.csv - Dados extraídos das tabelas
log-url.csv - Log de URLs consultadas com parâmetros
logs.txt - Registro detalhado da execução

Todos os arquivos são salvos automaticamente em: Google Drive → ProcessosRobo → Arquivos_Robo
⏰ Agendamento
Por padrão, o robô executa:

Horário: 8h da manhã (horário de Brasília)
Frequência: Diariamente
Timeout: 1 hora por execução

Para alterar, edite SCHEDULE em setup-scheduler.sh:
bashSCHEDULE="0 8 * * *"   # Todo dia às 8h
SCHEDULE="0 14 * * *"  # Todo dia às 14h
SCHEDULE="0 */6 * * *" # A cada 6 horas
📈 Monitoramento
Ver logs em tempo real:
bashgcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=robot-tjrs" --limit 50
Console Web:
https://console.cloud.google.com/run?project=newrobottjrs
🔐 Segurança

⚠️ O arquivo service-account.json contém credenciais sensíveis
✅ Nunca faça commit deste arquivo
✅ Já está incluído no .gitignore
✅ Use variáveis de ambiente em produção

💰 Custos Estimados

Cloud Run: ~$1-10/mês (dependendo do tempo de execução)
Cloud Scheduler: Gratuito (primeiros 3 jobs)
Google Drive: Gratuito (15GB inclusos)

Total estimado: $1-10/mês
🤝 Contribuindo
Contribuições são bem-vindas! Por favor:

Fork o projeto
Crie uma branch para sua feature (git checkout -b feature/NovaFuncionalidade)
Commit suas mudanças (git commit -m 'Adiciona nova funcionalidade')
Push para a branch (git push origin feature/NovaFuncionalidade)
Abra um Pull Request

📝 Licença
Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.
👤 Autor
Mauricio Branda

GitHub: @mauriciobranda
Projeto: New_Robot_TJRS

🙏 Agradecimentos

Robot Framework - Framework de automação
Selenium - Automação de navegadores
Google Cloud - Infraestrutura em nuvem
