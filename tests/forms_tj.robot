*** Settings ***
Resource          ../resources/common_keywords.robot

Suite Setup       Open Browser To Site
Suite Teardown    Close All Browsers

*** Test Cases ***
Consultar Lista De Nomes
    [Documentation]    Consulta processos usando URLs diretas do arquivo CSV e registra os resultados.

    # Prepara o arquivo de log principal no início do teste
    ${data}=          Get Current Date      result_format=%Y-%m-%d
    ${hora}=          Get Time              result_format=%H:%M:%S
    Create File       ${OUTPUT_DIR}/logs.txt      *** LOG DE CONSULTAS ***\nData de execução: ${data} ${hora}\n

    # Ler dados do nomes.csv (agora retorna uma lista de listas: [Nome, Status, URL] para cada linha)
    # O arquivo nomes.csv deve estar na raiz do projeto (New_Robot/nomes.csv)
    ${lista_de_partes}=   Ler Lista De Nomes Do Arquivo    nomes.csv

    # Loop principal para cada entrada no CSV de nomes
    FOR               ${parte_dados}      IN      @{lista_de_partes}
        # Extrai os dados de cada linha do CSV
        ${nome_da_parte}=     Set Variable    ${parte_dados}[0] 
        ${status_da_parte}=   Set Variable    ${parte_dados}[1] 
        ${url_direta}=        Set Variable    ${parte_dados}[2]

        Log With Timestamp    Iniciando consulta direta para: ${nome_da_parte}

        # Navega diretamente para a URL final do processo
        Go To             ${url_direta}
        Sleep             5s

        # Definir o XPath da tabela (o mesmo usado em Extrair Dados Da Tabela E Salvar CSV)
        ${table_xpath}=   Set Variable      xpath=//table[@class='mat-mdc-table mdc-data-table__table cdk-table mat-sort full-width mat-table-responsive']

        # --- NOVA LÓGICA: VERIFICA SE A TABELA DE DADOS ESTÁ VISÍVEL DENTRO DO TEMPO LIMITE ---
        ${tabela_visivel}=   Run Keyword And Return Status    Wait Until Element Is Visible    ${table_xpath}    timeout=30s

        IF    ${tabela_visivel}
            Log With Timestamp    Tabela de dados visível para ${nome_da_parte}. Extraindo dados.
            # Se a tabela está visível, então prossegue com a extração
            Extrair Dados Da Tabela E Salvar CSV      ${nome_da_parte}
        ELSE
            # Se a tabela NÃO está visível após 30 segundos, consideramos um problema
            Log With Timestamp    ERRO: Tabela de dados não visível após 30s para ${nome_da_parte}. Serviço indisponível ou problema de carregamento.
            # Opcional: Você pode pegar o HTML aqui para depuração adicional
            # ${html_pagina_erro}= Get Text xpath=//body
            # Log To Console    HTML da página com erro: ${html_pagina_erro}
            # Opcional: Para pular para o próximo nome se a tabela não carregar, descomente a linha abaixo:
            # Continue For Loop
            # Se você quer que o script PARE completamente em caso de tabela não visível, use 'Fail' aqui:
            # Fail    Tabela de dados não visível. Script abortado.
        END
        Sleep             5s
    END
    Log To Console        Processamento de todos os nomes concluído. Verifique os arquivos CSV na pasta output/files/gen.