*** Settings ***
Library           SeleniumLibrary
Library           Collections
Library           OperatingSystem
Library           String
Library           DateTime

*** Variables ***
${BROWSER}        chrome
${OUTPUT_DIR}   G:/My Drive/ProcessosRobo/Arquivos_Robo

# Email Configuration - Set these as environment variables or update directly
${SMTP_SERVER}    smtp.gmail.com
${SMTP_PORT}      587
${SENDER_EMAIL}   %{SENDER_EMAIL=your-email@gmail.com}
${SENDER_PASSWORD}    %{SENDER_PASSWORD=your-app-password}
${RECIPIENT_EMAILS}   %{RECIPIENT_EMAILS=recipient@example.com}

*** Keywords ***

Open Browser To Site
    [Documentation]    Abre o navegador e maximiza a janela. Ativa o modo headless para rodar em segundo plano.
    
    # Argumentos para o modo headless (para Chrome)
    # Importa a biblioteca selenium.webdriver diretamente para usar ChromeOptions
    ${chrome_options}=    Evaluate    selenium.webdriver.ChromeOptions()    modules=selenium.webdriver
    
    # ATIVA O MODO HEADLESS
    Call Method    ${chrome_options}    add_argument    --headless
    

    # Abre o navegador Chrome com as opções definidas (incluindo headless)
    Open Browser      about:blank    chrome    options=${chrome_options}
    
    # A linha abaixo "Maximize Browser Window" pode ser removida ou comentada,
    # pois --start-maximized nas opções do Chrome já cuida disso no modo headless.
    # Maximize Browser Window 

Close Browser
    [Documentation]    Fecha o navegador.
    Close Browser

Ler Lista De Nomes Do Arquivo
    [Documentation]    Lê dados de um arquivo CSV (nomes.csv), um conjunto de dados (nome, status, url) por linha.
    [Arguments]       ${file_path}=nomes.csv 
    # Nome do arquivo padrão
    ${conteudo_raw}=  Get File      ${file_path}    encoding=latin-1
    # Lê o conteúdo completo do arquivo como uma string
    ${linhas_raw}=    Split To Lines    ${conteudo_raw} 
    # Divide a string em uma lista de linhas

    # Remove a linha do cabeçalho (a primeira linha)
    Remove From List  ${linhas_raw}    0 
    
    ${dados_processados}=  Create List 
    # Lista para armazenar as sublistas [Nome, Status, URL]

    FOR  ${linha}  IN  @{linhas_raw}
        # Ignora linhas vazias, se houver
        Continue For Loop If    '${linha}' == '${EMPTY}'
        
        # Divide cada linha em campos usando o ponto e vírgula como delimitador
        ${campos}=        Split String    ${linha}    separator=;
        Append To List    ${dados_processados}    ${campos}
    END
    RETURN            ${dados_processados} 
    # Retorna uma lista de listas: [[Nome, Status, URL], ...]


Extrair Dados Da Tabela E Salvar CSV
    [Documentation]    Extrai dados de uma tabela HTML, salva em CSV individual e extrai parâmetros da URL para log tabular CSV.
    [Arguments]       ${nome_consultado}
    ${table_xpath}=   Set Variable      xpath=//table[@class='mat-mdc-table mdc-data-table__table cdk-table mat-sort full-width mat-table-responsive']

    # --- EXTRAÇÃO DE PARÂMETROS DA URL E SALVAR EM log-url.csv (COM VÍRGULAS) ---
    ${LOG_URL_FILENAME}=    Set Variable    log-url.csv
    ${LOG_URL_FILEPATH}=    Join Path       ${OUTPUT_DIR}    ${LOG_URL_FILENAME}

    # Verifica se o arquivo existe para adicionar o cabeçalho apenas na primeira vez
    ${log_url_exists}=      Run Keyword And Return Status    File Should Exist    ${LOG_URL_FILEPATH}
    Run Keyword If          not ${log_url_exists}    Create File    ${LOG_URL_FILEPATH}    "Nome","CPF/CNPJ","CodParte1g","CodParte2g","Timestamp","URL Completa"\n

    ${current_url}=   Get Location 
    Log To Console    URL atual para extração de parâmetros: ${current_url}

    # Extrair parteSelecionadaNome
    ${extracted_nome}=    Get Regexp Matches    ${current_url}    parteSelecionadaNome=([^&]+)    1
    ${param_nome}=        Run Keyword If    ${extracted_nome}    Set Variable    ${extracted_nome}[0]
    ...                   ELSE              Set Variable    N/A

    # Extrair parteSelecionadaCpfCnpj
    ${extracted_cpf_cnpj}=    Get Regexp Matches    ${current_url}    parteSelecionadaCpfCnpj=([^&]+)    1
    ${param_cpf_cnpj}=        Run Keyword If    ${extracted_cpf_cnpj}    Set Variable    ${extracted_cpf_cnpj}[0]
    ...                       ELSE              Set Variable    N/A

    # Extrair parteSelecionadaCodParte1g
    ${extracted_cod_1g}=    Get Regexp Matches    ${current_url}    parteSelecionadaCodParte1g=([^&]+)    1
    ${param_cod_1g}=        Run Keyword If    ${extracted_cod_1g}    Set Variable    ${extracted_cod_1g}[0]
    ...                     ELSE              Set Variable    N/A

    # Extrair parteSelecionadaCodParte2g
    ${extracted_cod_2g}=    Get Regexp Matches    ${current_url}    parteSelecionadaCodParte2g=([^&]+)    1
    ${param_cod_2g}=        Run Keyword If    ${extracted_cod_2g}    Set Variable    ${extracted_cod_2g}[0]
    ...                     ELSE              Set Variable    N/A

    # Decodificar o nome se ele vier com codificação de URL (ex: %20 para espaço)
    ${decoded_param_nome}=    Evaluate    urllib.parse.unquote("${param_nome}")    modules=urllib.parse
    # Decodificar o CPF/CNPJ se ele vier com codificação de URL
    ${decoded_param_cpf_cnpj}=    Evaluate    urllib.parse.unquote("${param_cpf_cnpj}")    modules=urllib.parse

    # Prepara a string de log para o arquivo log-url.csv em formato tabular (CSV)
    ${timestamp}=         Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${log_entry_csv}=       Catenate    SEPARATOR=, 
    ...                   "${decoded_param_nome}"
    ...                   "${decoded_param_cpf_cnpj}"
    ...                   "${param_cod_1g}"
    ...                   "${param_cod_2g}"
    ...                   "${timestamp}"
    ...                   "${current_url}" 

    # Anexa a entrada tabular ao arquivo log-url.csv
    Append To File        ${LOG_URL_FILEPATH}    ${log_entry_csv}\n

    Log To Console        Parâmetros da URL de ${nome_consultado} salvos em ${LOG_URL_FILEPATH}
    # --- FIM DO NOVO CÓDIGO DE EXTRAÇÃO DE URL ---

    Wait Until Element Is Visible     ${table_xpath}      timeout=30s

    # Obter cabeçalhos da tabela
    ${headers}=       Create List
    ${header_elements}=       Get WebElements       ${table_xpath}//thead//th
    FOR               ${header_element}      IN      @{header_elements}
        ${header_text}=       Get Text      ${header_element}
        Append To List        ${headers}      ${header_text}
    END
    ${csv_headers}=   Catenate      SEPARATOR=,      @{headers}
    ${csv_headers}=   Remove String     ${csv_headers}      [ ] '

    # Criar o nome do arquivo CSV
    ${filename}=      Set Variable      ${nome_consultado}_processos.csv
    ${filepath}=      Join Path         ${OUTPUT_DIR}      ${filename}

    # Iniciar o arquivo CSV com os cabeçalhos
    Create File       ${filepath}       ${csv_headers}\n

    # OBTEMOS O NÚMERO DE LINHAS E ITERAMOS POR ÍNDICE, CONSTRUINDO O XPATH DE CADA LINHA
    ${num_rows}=      Get Element Count     ${table_xpath}//tbody//tr
    Log To Console    Número de linhas detectadas para CSV para ${nome_consultado}: ${num_rows}

    FOR               ${row_index}    IN RANGE    1    ${num_rows + 1}
        ${current_row_xpath}=    Set Variable    ${table_xpath}//tbody//tr[${row_index}]

        # ESPERA PELA PRIMEIRA CÉLULA USANDO O XPATH COMPLETO DA LINHA
        Wait Until Element Is Visible     ${current_row_xpath}//td[1]    timeout=10s

        ${row_data}=      Create List
        # OBTEMOS AS CÉLULAS USANDO O XPATH COMPLETO DA LINHA
        ${cells}=         Get WebElements       ${current_row_xpath}//td

        FOR               ${cell_element}      IN      @{cells}
            ${cell_text}=     Get Text      ${cell_element}
            ${cleaned_text}=  Replace String      ${cell_text}      \n      ${EMPTY}
            ${cleaned_text}=  Strip String        ${cleaned_text}
            ${cell_text}=     Replace String      ${cleaned_text}   "      ""
            ${cell_text}=     Replace String      ${cell_text}      '      ${EMPTY}
            Append To List    ${row_data}       ${cell_text}
        END
        ${csv_row}=       Catenate      SEPARATOR=,      @{row_data}
        Append To File    ${filepath}       ${csv_row}\n
        
    END
    Log To Console    Dados da tabela extraídos e salvos em: ${filepath}


Log With Timestamp
    [Documentation]    Registra uma mensagem no log com a data e hora atuais.
    [Arguments]        ${message}
    ${timestamp}=      Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Log To Console     [${timestamp}] ${message}
    Append To File     ${OUTPUT_DIR}/logs.txt      [${timestamp}] ${message}\n


Send Email Notification
    [Documentation]    Envia email com resumo da execução do script
    [Arguments]        ${total_processados}    ${total_sucesso}    ${total_erros}    ${execution_time}

    ${timestamp}=      Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${date_only}=      Get Current Date    result_format=%d/%m/%Y

    # Determina o status geral
    ${status}=         Set Variable If    ${total_erros} > 0    ⚠️ CONCLUÍDO COM ERROS    ✅ CONCLUÍDO COM SUCESSO

    # Monta o corpo do email em HTML
    ${email_body}=     Catenate    SEPARATOR=\n
    ...    <html>
    ...    <head><style>
    ...    body { font-family: Arial, sans-serif; }
    ...    .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
    ...    .content { padding: 20px; }
    ...    .stats { background-color: #f1f1f1; padding: 15px; border-radius: 5px; margin: 10px 0; }
    ...    .stat-item { margin: 8px 0; font-size: 16px; }
    ...    .footer { background-color: #f1f1f1; padding: 10px; text-align: center; font-size: 12px; color: #666; }
    ...    </style></head>
    ...    <body>
    ...    <div class="header">
    ...    <h1>🤖 Robot TJRS - Relatório de Execução</h1>
    ...    </div>
    ...    <div class="content">
    ...    <h2>${status}</h2>
    ...    <div class="stats">
    ...    <div class="stat-item"><strong>📅 Data/Hora:</strong> ${timestamp}</div>
    ...    <div class="stat-item"><strong>👥 Total Processados:</strong> ${total_processados}</div>
    ...    <div class="stat-item"><strong>✅ Sucessos:</strong> ${total_sucesso}</div>
    ...    <div class="stat-item"><strong>❌ Erros:</strong> ${total_erros}</div>
    ...    <div class="stat-item"><strong>⏱️ Tempo de Execução:</strong> ${execution_time}</div>
    ...    </div>
    ...    <p><strong>📁 Arquivos salvos em:</strong><br>Google Drive → ProcessosRobo → Arquivos_Robo</p>
    ...    <p>Os resultados incluem:</p>
    ...    <ul>
    ...    <li>Arquivos CSV individuais para cada pessoa processada</li>
    ...    <li>Log de URLs consultadas (log-url.csv)</li>
    ...    <li>Log detalhado de execução (logs.txt)</li>
    ...    </ul>
    ...    </div>
    ...    <div class="footer">
    ...    <p>Este é um email automático do Robot TJRS. Não responda a esta mensagem.</p>
    ...    </div>
    ...    </body>
    ...    </html>

    # Assunto do email
    ${subject}=        Catenate    Robot TJRS - Execução ${date_only} - ${status}

    # Envia o email usando Python
    ${result}=         Evaluate
    ...    import smtplib; from email.mime.text import MIMEText; from email.mime.multipart import MIMEMultipart; msg = MIMEMultipart('alternative'); msg['Subject'] = '''${subject}'''; msg['From'] = '''${SENDER_EMAIL}'''; msg['To'] = '''${RECIPIENT_EMAILS}'''; html_part = MIMEText('''${email_body}''', 'html', 'utf-8'); msg.attach(html_part); server = smtplib.SMTP('${SMTP_SERVER}', ${SMTP_PORT}); server.starttls(); server.login('''${SENDER_EMAIL}''', '''${SENDER_PASSWORD}'''); server.send_message(msg); server.quit(); 'Email enviado com sucesso'

    Log To Console     ${result}
    Log With Timestamp    Email de notificação enviado para: ${RECIPIENT_EMAILS}