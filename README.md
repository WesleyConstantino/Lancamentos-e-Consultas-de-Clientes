# Especificação:

1 - Criar uma tabela com os campos: NOME = CHAR 50,
 PRODUTO = CHAR 20,
 COD_CLI = CHAR 4 (Chave),
 VALOR_PROD = CHAR 10,
 ATIVO = CHAR 1.
2 - Criar um report com dois radio buttons, “Consultar” e “Lançar”, ao clicar em “consultar”, deverá 
ser apresentado um campo “Código do cliente” para que seja possível fazer o filtro de consulta
através do código do cliente.
3 – Ao executar o programa, deverá ser feita uma seleção onde COD_CLI = parâmetro de entrada, 
caso não existam dados de acordo com o filtro passado, deverá ser apresentada uma mensagem 
informando da inexistência.
4 – Caso sejam encontrados dados, deverá ser gerado um relatório ALV, com os campos Nome = 
nome do cliente associado ao código, Código = código, Produtos = todos os produtos em nome do 
cliente (caso não exista nenhum produto em nome do cliente, deverá ser estrito no campo “Sem 
produtos”) , Valor Total = soma de todos os campos VALOR_PROD do cliente e Ativo = ao campo 
ATIVO. Obs: com exceção dos dados do campo Produtos, todos os outros campos deverão 
apresentar os dados somente uma vez ( sem repetir).
5 – Ao clicar no radio button “Lançar”, deverá ser possível criar um cadastro inserindo o nome do 
cliente, ao fazer isso e executar o programa, o campo NOME = parâmetro no banco de dados, bem 
como, deverá ser gerado um código automático para o cliente
