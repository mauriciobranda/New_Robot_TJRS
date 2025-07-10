*** Settings ***
Resource          ../resources/common_keywords.robot

Suite Setup       Open Browser To Site
Suite Teardown    Close All Browsers

*** Test Cases ***
Consultar Lista De Nomes
    [Documentation]    Consulta uma lista de nomes em um site e registra os resultados.
    ${nomes}=         Ler Lista De Nomes Do Arquivo

    # Prepara o arquivo de log no início do teste
    ${data}=          Get Current Date      result_format=%Y-%m-%d
    ${hora}=          Get Time              result_format=%H:%M:%S
    Create File       ${OUTPUT_DIR}/logs.txt      *** LOG DE CONSULTAS ***\nData de execução: ${data} ${hora}\n

    FOR               ${nome}      IN      @{nomes}
        Log With Timestamp    Iniciando consulta para o nome: ${nome}
        Acessar Site Com Nome     ${nome}
        Sleep             5s
        ${html}=          Get Text      xpath=//body

        ${sem_processo}=      Run Keyword And Return Status    Should Contain    ${html}    Não foram encontrados processos para esse nome com os critérios informados
        ${tem_resultado}=     Evaluate      not ${sem_processo}

        ${resultado}=     Run Keyword If    ${tem_resultado}    Set Variable    Resultado encontrado para ${nome}
        ...               ELSE              Set Variable    Não tem resultado para ${nome}
        Log With Timestamp    NOME CONSULTADO: ${nome} - RESULTADO: ${resultado}

        Run Keyword If    ${tem_resultado}    Clicar No Nome Encontrado      ${nome}
        Run Keyword If    ${tem_resultado}    Extrair Dados Da Tabela E Salvar CSV      ${nome}
        Sleep             5s
    END