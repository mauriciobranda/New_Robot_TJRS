*** Settings ***
Resource          ../resources/common_keywords.robot

Suite Setup       Open Browser To Site
Suite Teardown    Close All Browsers

*** Test Cases ***
Consultar Lista De Nomes
    [Documentation]    Consulta processos usando URLs diretas do arquivo CSV e registra os resultados.

    # Registra o tempo de início da execução
    ${start_time}=    Get Current Date      result_format=epoch

    # Prepara o arquivo de log principal no início do teste
    ${data}=          Get Current Date      result_format=%Y-%m-%d
    ${hora}=          Get Time              result_format=%H:%M:%S
    Create File       ${OUTPUT_DIR}/logs.txt      *** LOG DE CONSULTAS ***\nData de execução: ${data} ${hora}\n

    # Ler dados do nomes.csv (agora retorna uma lista de listas: [Nome, Status, URL] para cada linha)
    # O arquivo nomes.csv deve estar na raiz do projeto (New_Robot/nomes.csv)
    ${lista_de_partes}=   Ler Lista De Nomes Do Arquivo    nomes.csv

    # Inicializa contadores de estatísticas
    ${total_processados}=    Set Variable    0
    ${total_sucesso}=        Set Variable    0
    ${total_erros}=          Set Variable    0

    # Loop principal para cada entrada no CSV de nomes
    FOR               ${parte_dados}      IN      @{lista_de_partes}
        # Extrai os dados de cada linha do CSV
        ${nome_da_parte}=     Set Variable    ${parte_dados}[0]
        ${status_da_parte}=   Set Variable    ${parte_dados}[1]
        ${url_direta}=        Set Variable    ${parte_dados}[2]

        ${total_processados}=    Evaluate    ${total_processados} + 1

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
            ${total_sucesso}=    Evaluate    ${total_sucesso} + 1
        ELSE
            # Se a tabela NÃO está visível após 30 segundos, consideramos um problema
            Log With Timestamp    ERRO: Tabela de dados não visível após 30s para ${nome_da_parte}. Serviço indisponível ou problema de carregamento.
            ${total_erros}=      Evaluate    ${total_erros} + 1
        END
        Sleep             5s
    END

    # Calcula o tempo de execução
    ${end_time}=      Get Current Date      result_format=epoch
    ${duration_seconds}=    Evaluate    ${end_time} - ${start_time}
    ${duration_minutes}=    Evaluate    int(${duration_seconds} / 60)
    ${duration_secs}=       Evaluate    int(${duration_seconds} % 60)
    ${execution_time}=      Set Variable    ${duration_minutes}m ${duration_secs}s

    Log To Console        Processamento de todos os nomes concluído. Verifique os arquivos CSV na pasta output/files/gen.
    Log To Console        Estatísticas: ${total_sucesso} sucessos, ${total_erros} erros de ${total_processados} processados

    # Envia email de notificação com o resumo da execução
    Log To Console        Enviando email de notificação...
    Send Email Notification    ${total_processados}    ${total_sucesso}    ${total_erros}    ${execution_time}