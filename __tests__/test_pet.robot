*** Settings ***
# Bibliotecas e Configurações
Library    RequestsLibrary

*** Variables ***
# Objetos, Atributos e Variables
${url}    https://petstore.swagger.io/v2/pet

${id}    72567201                     # $ sinaliza uma variavel simples
${name}    Snoopy
&{category}    id=1    name=cachorro    # & = lista com campos determinados. Ex: id e name - seria {}
@{photoUrls}                            # @ sinaliza uma lista com vários registros - seria []
&{tag}    id=1    name=vacinado
@{tags}   ${tag}                        # Fez uma lista de outra lista
${status}    avalaible

*** Test Cases ***
# Descritivo de Negócio + Passos de Automação

Post pet
    # Montar a mensagem / body
    ${body}    Create Dictionary    id=${id}    category=${category}    name=${name}    
    ...                             photoUrls=${photoUrls}  tags=${tags}    status=${status}

    # Executar
    ${response}    POST    url=${url}    json=${body}

    # Validar
    ${response_body}    Set Variable    ${response.json()}  # Recebe o conteúdo da outra variavel
    Log To Console      ${response_body}    # imprimir o retorno da API no terminal / console

    Status Should Be    200
    Should Be Equal    ${response_body}[id]               ${{int($id)}}
    Should Be Equal    ${response_body}[name]             ${name}
    Should Be Equal    ${response_body}[tags][0][id]      ${{int(${tag}[id])}}
    Should Be Equal    ${response_body}[tags][0][name]    ${tag}[name]  
    Should Be Equal    ${response_body}[status]           ${status}

Get pet
    # Executar
    ${response}    GET    ${{$url + '/' + $id}}
    
    # Valida
    ${response_body}    Set Variable    ${response.json()}
    Log To Console    ${response_body}

    Status Should Be    200
    Should Be Equal    ${response_body}[id]    ${{int($id)}}
    Should Be Equal    ${response_body}[name]    ${name}
    Should Be Equal    ${response_body}[category][id]    ${{int(${category}[id])}}
    Should Be Equal    ${response_body}[category][name]    ${category}[name]

Put pet
    # Montar a mensagem / body com a mudança
    ${body}    Evaluate    json.loads(open('./fixtures/json/pet2.json').read())

    # Executa
    ${response}    PUT    url=${url}    json=${body}

    # Valida
    ${response_body}    Set Variable    ${response.json()}
    Log To Console    ${response_body}

    Status Should Be    200
    Should Be Equal    ${response_body}[id]                ${{int($id)}}
    Should Be Equal    ${response_body}[category][id]      ${{int(${category}[id])}}
    Should Be Equal    ${response_body}[category][name]    ${category}[name]
    Should Be Equal    ${response_body}[name]              ${name}
    Should Be Equal    ${response_body}[tags][0][id]       ${{int(${tag}[id])}}
    Should Be Equal    ${response_body}[tags][0][name]     ${tag}[name]  
    Should Be Equal    ${response_body}[status]            sold

Delete pet
    # Executa
    ${response}    DELETE    ${{$url + '/' + $id}}

    # Valida
    ${response_body}    Set Variable    ${response.json()}
    Log To Console    ${response_body}

    Status Should Be    200
    Should Be Equal    ${response_body}[code]    ${{int(200)}}
    Should Be Equal    ${response_body}[type]    unknown
    Should Be Equal    ${response_body}[message]    ${id}


*** Keywords ***
# Descritivo de Negócio (se estruturar separadamente)
# DSL = Domain Specific Language = Linguagem Especifica de Dominio

