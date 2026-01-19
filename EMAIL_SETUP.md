# 📧 Configuração de Notificações por Email

## Visão Geral

O Robot TJRS agora envia notificações por email ao final de cada execução, incluindo:

- ✅ Status da execução (Sucesso/Erros)
- 📊 Número total de processos consultados
- ⏱️ Tempo de execução
- 📁 Localização dos arquivos no Google Drive
- ⚠️ Detalhes de erros (se houver)

---

## 🔧 Configuração

### Opção 1: Usando Gmail (Recomendado)

#### Passo 1: Gerar Senha de App no Gmail

1. Acesse sua conta Google: https://myaccount.google.com/
2. Vá em **Segurança** → **Verificação em duas etapas** (ative se não estiver ativada)
3. Role até **Senhas de app**
4. Selecione:
   - **App**: Email
   - **Dispositivo**: Outro (Robot TJRS)
5. Copie a senha de 16 caracteres gerada

#### Passo 2: Configurar Variáveis de Ambiente

**Para execução local:**

**Linux/Mac:**
```bash
export SENDER_EMAIL="seu-email@gmail.com"
export SENDER_PASSWORD="sua-senha-de-app-16-digitos"
export RECIPIENT_EMAILS="destinatario1@example.com,destinatario2@example.com"
```

**Windows (CMD):**
```cmd
set SENDER_EMAIL=seu-email@gmail.com
set SENDER_PASSWORD=sua-senha-de-app-16-digitos
set RECIPIENT_EMAILS=destinatario1@example.com,destinatario2@example.com
```

**Windows (PowerShell):**
```powershell
$env:SENDER_EMAIL="seu-email@gmail.com"
$env:SENDER_PASSWORD="sua-senha-de-app-16-digitos"
$env:RECIPIENT_EMAILS="destinatario1@example.com,destinatario2@example.com"
```

---

### Opção 2: Configuração Direta no Arquivo

Se preferir não usar variáveis de ambiente, edite o arquivo:

`resources/common_keywords.robot`

Altere as linhas:

```robot
${SENDER_EMAIL}       seu-email@gmail.com
${SENDER_PASSWORD}    sua-senha-de-app-aqui
${RECIPIENT_EMAILS}   destinatario1@example.com,destinatario2@example.com
```

⚠️ **ATENÇÃO**: Nunca faça commit de senhas no Git! Use variáveis de ambiente.

---

## ☁️ Configuração no Google Cloud Run

### Passo 1: Adicionar Variáveis de Ambiente no Cloud Run

```bash
gcloud run services update robot-tjrs \
  --update-env-vars SENDER_EMAIL="seu-email@gmail.com" \
  --update-env-vars SENDER_PASSWORD="sua-senha-de-app" \
  --update-env-vars RECIPIENT_EMAILS="destinatario@example.com" \
  --region=us-central1
```

### Passo 2: Ou via Console Web

1. Acesse: https://console.cloud.google.com/run
2. Selecione o serviço **robot-tjrs**
3. Clique em **EDIT & DEPLOY NEW REVISION**
4. Vá em **Variables & Secrets** → **Environment Variables**
5. Adicione:
   - `SENDER_EMAIL`: seu-email@gmail.com
   - `SENDER_PASSWORD`: sua-senha-de-app
   - `RECIPIENT_EMAILS`: destinatario@example.com

---

## 📨 Múltiplos Destinatários

Para enviar para várias pessoas, separe os emails por vírgula:

```bash
export RECIPIENT_EMAILS="pessoa1@example.com,pessoa2@example.com,pessoa3@example.com"
```

---

## 🔐 Usando Outros Provedores de Email

### Outlook/Hotmail

```robot
${SMTP_SERVER}    smtp-mail.outlook.com
${SMTP_PORT}      587
```

### Yahoo

```robot
${SMTP_SERVER}    smtp.mail.yahoo.com
${SMTP_PORT}      587
```

### Gmail (SMTP Personalizado)

```robot
${SMTP_SERVER}    smtp.gmail.com
${SMTP_PORT}      587
```

---

## 🧪 Testando a Configuração

Execute o robot localmente para testar:

```bash
# Configure as variáveis de ambiente primeiro
export SENDER_EMAIL="seu-email@gmail.com"
export SENDER_PASSWORD="sua-senha-de-app"
export RECIPIENT_EMAILS="seu-email-de-teste@gmail.com"

# Execute o robot
robot --outputdir output tests/forms_tj.robot
```

Ao final da execução, você receberá um email com o resumo.

---

## 🎨 Exemplo de Email Recebido

**Assunto:** Robot TJRS - Execução 19/01/2026 - ✅ CONCLUÍDO COM SUCESSO

**Corpo:**
```
🤖 Robot TJRS - Relatório de Execução

✅ CONCLUÍDO COM SUCESSO

📅 Data/Hora: 2026-01-19 08:30:45
👥 Total Processados: 15
✅ Sucessos: 14
❌ Erros: 1
⏱️ Tempo de Execução: 8m 32s

📁 Arquivos salvos em:
Google Drive → ProcessosRobo → Arquivos_Robo

Os resultados incluem:
• Arquivos CSV individuais para cada pessoa processada
• Log de URLs consultadas (log-url.csv)
• Log detalhado de execução (logs.txt)
```

---

## ❓ Solução de Problemas

### Erro: "Authentication failed"

**Causa:** Senha incorreta ou senha de app não gerada
**Solução:** Verifique se está usando uma **Senha de App** do Gmail, não sua senha normal

### Erro: "SMTPAuthenticationError"

**Causa:** Verificação em duas etapas não ativada
**Solução:** Ative a verificação em duas etapas no Gmail antes de gerar a senha de app

### Email não está sendo enviado

**Verifique:**
1. As variáveis de ambiente estão definidas corretamente
2. O email remetente está correto
3. A senha de app foi copiada sem espaços
4. Teste com um único destinatário primeiro

### Emails indo para SPAM

**Solução:** Adicione o email remetente aos contatos confiáveis

---

## 🔒 Segurança

- ✅ NUNCA faça commit de senhas no código
- ✅ Use sempre variáveis de ambiente
- ✅ Use senhas de app específicas (não sua senha principal)
- ✅ Revogue senhas de app não utilizadas
- ✅ Monitore atividade suspeita na conta

---

## 📞 Suporte

Para problemas ou dúvidas:

1. Verifique se seguiu todos os passos acima
2. Teste localmente antes de fazer deploy no Cloud Run
3. Consulte os logs: `${OUTPUT_DIR}/logs.txt`
4. Abra uma issue no GitHub

---

**Configuração atualizada em:** Janeiro 2026
**Versão do Robot TJRS:** 2.0
