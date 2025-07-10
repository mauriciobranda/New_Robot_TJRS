*** Settings ***
Library           SeleniumLibrary
Library           Collections
Library           OperatingSystem
Library           String
Library           DateTime

*** Variables ***
${BROWSER}        chrome
${URL_BASE}       https://consulta.tjrs.jus.br/consulta-processual/partes/por-nome?comarca=&tipoPesquisa=F&movimentados=0&&iframe=1&nome=
${OUTPUT_DIR}     ${CURDIR}/../output/files/gen

*** Keywords ***

Open Browser To Site
    [Documentation]    Abre o navegador e maximiza a janela.
    Open Browser      about:blank    ${BROWSER}
    Maximize Browser Window

Close Browser
    [Documentation]    Fecha o navegador.
    Close Browser

Ler Lista De Nomes Do Arquivo
    [Documentation]    Lê nomes de um arquivo 'nomes.txt', um nome por linha.
    ${conteudo}=      Get File      nomes.txt
    ${linhas}=        Split To Lines      ${conteudo}
    RETURN            ${linhas}

Acessar Site Com Nome
    [Documentation]    Navega para a URL base com o nome formatado.
    [Arguments]       ${nome_formatado}
    ${url}=           Catenate      SEPARATOR=    ${URL_BASE}    ${nome_formatado}
    Go To             ${url}


Clicar No Nome Encontrado
    [Documentation]    Clica no link do nome encontrado na página, esperando que overlays de carregamento desapareçam.
    [Arguments]       ${nome}
    
    Wait Until Element Is Visible     xpath=//a[contains(text(), '${nome}')]      timeout=90s

    Click Element     xpath=//a[contains(text(), '${nome}')]
    Sleep             20s 
    #Pequena pausa após o clique para a nova página começar a carregar

Extrair Dados Da Tabela E Salvar CSV
    [Documentation]    Extrai dados de uma tabela HTML, salva em CSV e extrai parâmetros da URL para log tabular CSV.
    [Arguments]       ${nome_consultado}
    ${table_xpath}=   Set Variable      xpath=//table[@class='mat-mdc-table mdc-data-table__table cdk-table mat-sort full-width mat-table-responsive']

    # --- NOVO CÓDIGO: EXTRAÇÃO DE PARÂMETROS DA URL E SALVAR EM log-url.csv (COM VÍRGULAS) ---
    ${LOG_URL_FILENAME}=    Set Variable    log-url.csv
    ${LOG_URL_FILEPATH}=    Join Path       ${OUTPUT_DIR}    ${LOG_URL_FILENAME}

    # Verifica se o arquivo existe para adicionar o cabeçalho apenas na primeira vez
    ${log_url_exists}=      Run Keyword And Return Status    File Should Exist    ${LOG_URL_FILEPATH}
    Run Keyword If          not ${log_url_exists}    Create File    ${LOG_URL_FILEPATH}    "Nome","CPF/CNPJ","CodParte1g","CodParte2g","Timestamp","URL Completa"\n

    ${current_url}=   Get Location 
    # Obtém a URL atual do navegador
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
    # --- FIM DO NOVO CÓDIGO ---

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
            #Append To List    ${row_data}       "${cell_text}"
            Append To List    ${row_data}         ${cell_text}
        END
        ${csv_row}=       Catenate      SEPARATOR=,      @{row_data}
        Append To File    ${filepath}       ${csv_row}\n
        
    END
    Log To Console    Dados da tabela extraídos e salvos em: ${filepath}


Log With Timestamp
    [Documentation]    Registra uma mensagem no log com a data e hora atuais.
    [Arguments]        ${message}
    ${timestamp}=      Get Current Date      result_format=%Y-%m-%d %H:%M:%S
    Log To Console     [${timestamp}] ${message}
    Append To File     ${OUTPUT_DIR}/logs.txt      [${timestamp}] ${message}\n