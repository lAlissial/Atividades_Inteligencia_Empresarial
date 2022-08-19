
----------------------------------------------+
CREATE USER C##INTEMP IDENTIFIED BY "ifpb"; --|
                                            --|
GRANT UNLIMITED TABLESPACE TO C##INTEMP;    --|
----------------------------------------------+

-----------------------------------------------------------------------------------------------------------------------+
CREATE TABLE FORNECEDORES (                                                                                          --|
    FORNECEDOR_ID           INT                                                                                      --|
   ,FORNECEDOR_NOME         VARCHAR(4000)                                                                            --|
   --                                                                                                                --|
   ,CONSTRAINT PK_FORNECEDORES  PRIMARY KEY(FORNECEDOR_ID)                                                           --|
);                                                                                                                   --|
-----------------------------------------------------------------------------------------------------------------------+
CREATE TABLE TRANSPORTADORAS (                                                                                       --|
    TRANSPORTADORA_ID       INT                                                                                      --|
   ,TRANSPORTADORA_NOME     VARCHAR(4000)                                                                            --|
   --                                                                                                                --|
   ,CONSTRAINT PK_TRANSPORTADORA  PRIMARY KEY(TRANSPORTADORA_ID)                                                     --|
);                                                                                                                   --|
-----------------------------------------------------------------------------------------------------------------------+
CREATE TABLE VENDEDORES (                                                                                            --|
    VENDEDOR_ID             INT                                                                                      --|
   ,VENDEDOR_NOME           VARCHAR(4000)                                                                            --|
   --                                                                                                                --|
   ,CONSTRAINT PK_VENDEDORES  PRIMARY KEY(VENDEDOR_ID)                                                               --|
);                                                                                                                   --|
-----------------------------------------------------------------------------------------------------------------------+
CREATE TABLE VENDAS_GLOBAIS (                                                                                        --|
    PEDIDO_ID               INT                                                                                      --|
   ,CATEGORIA_ID            INT                                                                                      --|
   ,CATEGORIA_NOME          VARCHAR(4000)                                                                            --|
   ,CATEGORIA_DESC          VARCHAR(4000)                                                                            --|
   ,CLIENTE_ID              INT                                                                                      --|
   ,CLIENTE_NOME            VARCHAR(4000)                                                                            --|
   ,CLIENTE_CONTATO         VARCHAR(4000)                                                                            --|
   ,CLIENTE_CIDADE          VARCHAR(4000)                                                                            --|
   ,CLIENTE_PAIS_ID         CHAR(3)                                                                                  --|
   ,CLIENTE_PAIS            VARCHAR(4000)                                                                            --|
   ,VENDAS_CUSTO            NUMBER(10,4)                                                                             --|
   ,MARGEM_BRUTA            NUMBER(10,4)                                                                             --|
   ,VENDAS                  NUMBER(10,4)                                                                             --|
   ,DESCONTO                NUMBER(10,4)                                                                             --|
   ,FRETE                   NUMBER(10,4)                                                                             --|
   ,QTDE                    INT                                                                                      --|
   ,DT                      DATE                                                                                     --|
   ,VENDEDOR_ID             INT                                                                                      --|
   ,PRODUTO_ID              INT                                                                                      --|
   ,PRODUTO_NOME            VARCHAR(4000)                                                                            --|
   ,TRANSPORTADORA_ID       INT                                                                                      --|
   ,FORNECEDOR_ID           INT                                                                                      --|
   --                                                                                                                --|
   ,CONSTRAINT FK_FORNECEDOR     FOREIGN KEY(FORNECEDOR_ID)     REFERENCES FORNECEDORES(FORNECEDOR_ID)               --|
   ,CONSTRAINT FK_TRANSPORTADORA FOREIGN KEY(TRANSPORTADORA_ID) REFERENCES TRANSPORTADORAS(TRANSPORTADORA_ID)        --|
   ,CONSTRAINT FK_VENDEDOR       FOREIGN KEY(VENDEDOR_ID)       REFERENCES VENDEDORES(VENDEDOR_ID)                   --|
);                                                                                                                   --|
                                                                                                                     --|
DELETE FROM VENDAS_GLOBAIS WHERE CLIENTE_ID IS NULL;                                                                 --|
-----------------------------------------------------------------------------------------------------------------------+

-----------------------------------------------------------------------------------------------+
                                                                                             --|-- Quem são os meus 10 maiores clientes, em termos de vendas ($)?
SELECT                                                                                       --|
    VG.CLIENTE_NOME                                                                          --|
    , TO_CHAR(SUM((VG.VENDAS)), 'FML999G999G999D00') AS TOTAL_VENDAS_QUANT_PROD              --|
 FROM VENDAS_GLOBAIS VG                                                                      --|
WHERE 1=1                                                                                    --|
GROUP                                                                                        --|
   BY VG.CLIENTE_NOME                                                                        --|
ORDER                                                                                        --|
   BY SUM(VG.VENDAS) DESC                                                                    --|
FETCH FIRST 10 ROWS ONLY                                                                     --|
;                                                                                            --|
                                                                                             --|
-----------------------------------------------------------------------------------------------+

-----------------------------------------------------------------------------------------------+
                                                                                             --|-- Quais os três maiores países, em termos de vendas ($)?
ALTER SESSION SET NLS_TERRITORY = 'Brazil';                                                  --|
SELECT                                                                                       --|
    VG.CLIENTE_PAIS                                                                          --|
    , TO_CHAR(SUM((VG.VENDAS)), 'FML999G999G999D00') AS TOTAL_VENDAS_QUANT_PROD              --|
 FROM VENDAS_GLOBAIS VG                                                                      --|
WHERE 1=1                                                                                    --|
GROUP                                                                                        --|
   BY VG.CLIENTE_PAIS                                                                        --|
ORDER                                                                                        --|
   BY SUM(VG.VENDAS) DESC                                                                    --|
FETCH FIRST 3 ROWS ONLY                                                                      --|
;                                                                                            --|
                                                                                             --|
-----------------------------------------------------------------------------------------------+

-----------------------------------------------------------------------------------------------+
                                                                                             --|-- Quais as categorias de produtos que geram maior faturamento (vendas $) no Brasil?
SELECT                                                                                       --|
     VG.CATEGORIA_NOME                                                                       --|
    , TO_CHAR(SUM(VG.VENDAS), 'FML999G999G999D00') AS TOTAL_VENDAS_CATEG_PROD                --|
 FROM VENDAS_GLOBAIS VG                                                                      --|
WHERE 1=1                                                                                    --|
  AND VG.CLIENTE_PAIS_ID  = 'BRA'                                                            --|
GROUP                                                                                        --|
   BY CATEGORIA_NOME                                                                         --|
ORDER                                                                                        --|
   BY SUM(VG.VENDAS) DESC                                                                    --|
;                                                                                            --|
                                                                                             --|
-----------------------------------------------------------------------------------------------+

-----------------------------------------------------------------------------------------------+
                                                                                             --|-- Qual a despesa com frete envolvendo cada transportadora?
SELECT                                                                                       --|
     T.TRANSPORTADORA_NOME                                                                   --|
    , TO_CHAR(SUM(VG.FRETE), 'FML999G999G999D00') AS TOTAL_VENDAS_CATEG_PROD                 --|
 FROM TRANSPORTADORAS T                                                                      --|
INNER                                                                                        --|
 JOIN VENDAS_GLOBAIS VG                                                                      --|
   ON T.TRANSPORTADORA_ID = VG.TRANSPORTADORA_ID                                             --|
GROUP                                                                                        --|
   BY T.TRANSPORTADORA_NOME, VG.TRANSPORTADORA_ID                                            --|
ORDER                                                                                        --|
   BY SUM(VG.FRETE) DESC                                                                     --|
;                                                                                            --|
                                                                                             --|
-----------------------------------------------------------------------------------------------+

-----------------------------------------------------------------------------------------------+
                                                                                             --|-- Quais são os principais clientes (vendas $) do segmento “Calçados Masculinos” (Men´s Footwear) na Alemanha?
SELECT                                                                                       --|
    VG.CLIENTE_NOME                                                                          --|
    , TO_CHAR(SUM(VG.VENDAS), 'FML999G999G999D00') AS TOTAL_VENDAS_ALEMANHA                  --|
 FROM VENDAS_GLOBAIS VG                                                                      --|  
WHERE 1=1                                                                                    --|
  AND VG.CLIENTE_PAIS_ID  = 'DEU'                                                            --|
  AND VG.CATEGORIA_ID = 6
GROUP                                                                                        --|
   BY VG.CLIENTE_NOME                                                                        --|
ORDER                                                                                        --|
   BY SUM(VG.VENDAS) DESC                                                                    --|
;                                                                                            --|
                                                                                             --|
-----------------------------------------------------------------------------------------------+
   
-----------------------------------------------------------------------------------------------+
                                                                                             --|-- Quais os vendedores que mais dão descontos nos Estados Unidos?
SELECT                                                                                       --|
    V.VENDEDOR_NOME                                                                          --|
    , TO_CHAR(SUM(VG.DESCONTO), 'FML999G999G999D00') AS TOTAL_DESCONTO                       --|
 FROM VENDAS_GLOBAIS VG                                                                      --|
INNER                                                                                        --|
 JOIN VENDEDORES V                                                                           --|
   ON V.VENDEDOR_ID = VG.VENDEDOR_ID                                                         --|
WHERE 1=1                                                                                    --|
  AND VG.CLIENTE_PAIS_ID  = 'USA'                                                            --|
GROUP                                                                                        --|
   BY V.VENDEDOR_NOME                                                                        --|
ORDER                                                                                        --|
   BY SUM(VG.DESCONTO) DESC                                                                  --|
;                                                                                            --|
                                                                                             --|
-----------------------------------------------------------------------------------------------+
   
-----------------------------------------------------------------------------------------------+
                                                                                             --|-- Quais os fornecedores que dão a maior margem de lucro ($) no segmento de “Vestuário Feminino” (Womens wear)?
SELECT                                                                                       --|
    F.FORNECEDOR_NOME                                                                        --|
    , TO_CHAR(SUM(MARGEM_BRUTA), 'FML999G999G999D00') AS TOTAL_MARGEM                        --|
 FROM VENDAS_GLOBAIS VG                                                                      --|
INNER                                                                                        --|
 JOIN FORNECEDORES F                                                                         --|
   ON F.FORNECEDOR_ID = VG.FORNECEDOR_ID                                                     --|
WHERE 1=1                                                                                    --|
  AND VG.CATEGORIA_ID = 2                                                                    --|
GROUP                                                                                        --|
   BY F.FORNECEDOR_NOME                                                                      --|
ORDER                                                                                        --|
   BY SUM(VG.MARGEM_BRUTA) DESC                                                              --|
;                                                                                            --|
                                                                                             --|
-----------------------------------------------------------------------------------------------+
   
-----------------------------------------------------------------------------------------------+
                                                                                             --|-- Quanto que foi vendido ($) no ano de 2009? Analisando as vendas anuais entre 2009 e 2012, podemos concluir que o faturamento vem crescendo, se mantendo estável ou decaindo?
WITH TOTAL_VENDAS_POR_ANO AS                                                                
(                                                                                           
    SELECT                                                                                  
        '2009'                                         AS ANO                               
        , TO_CHAR(SUM(VG.VENDAS), 'FML999G999G999D00') AS TOTAL_VENDAS_ANO                  
     FROM VENDAS_GLOBAIS VG                                                                 
    WHERE 1=1                                                                               
      AND EXTRACT(YEAR FROM VG.DT) = 2009                                                   
    UNION ALL                                                                               
    SELECT                                                                                  
        '2010'                                         AS ANO                               
        , TO_CHAR(SUM(VG.VENDAS), 'FML999G999G999D00') AS TOTAL_VENDAS_ANO                  
     FROM VENDAS_GLOBAIS VG                                                                 
    WHERE 1=1                                                                               
      AND EXTRACT(YEAR FROM VG.DT) = 2010                                                   
    UNION ALL                                                                               
    SELECT                                                                                  
        '2011'                                         AS ANO                               
        , TO_CHAR(SUM(VG.VENDAS), 'FML999G999G999D00') AS TOTAL_VENDAS_ANO                  
     FROM VENDAS_GLOBAIS VG                                                                 
    WHERE 1=1                                                                               
      AND EXTRACT(YEAR FROM VG.DT) = 2011                                                   
    UNION ALL                                                                               
    SELECT                                                                                  
        '2012'                                         AS ANO                                       , TO_CHAR(SUM(VG.VENDAS), 'FML999G999G999D00') AS TOTAL_VENDAS_ANO                  
     FROM VENDAS_GLOBAIS VG                                                                 
    WHERE 1=1                                                                               
      AND EXTRACT(YEAR FROM VG.DT) = 2012                                                   
)                                                                                           
SELECT *                                                                                    
 FROM TOTAL_VENDAS_POR_ANO                                                                  
ORDER                                                                                       
   BY ANO                                                                                   
;                                                                                           
                                                                                            
-----------------------------------------------------------------------------------------------+

   
-----------------------------------------------------------------------------------------------+
                                                                                             --|-- Quais os países nos quais mais se tiram pedidos (qtde total de pedidos)?	
SELECT                                                                                       --|
    VG.CLIENTE_PAIS                                                                          --|
    , TO_CHAR(SUM(VG.QTDE)) AS TOTAL_PEDIDOS                                                 --|
 FROM VENDAS_GLOBAIS VG                                                                      --|   
WHERE 1=1                                                                                    --|               
GROUP                                                                                        --|
   BY VG.CLIENTE_PAIS                                                                        --|
ORDER                                                                                        --|
   BY SUM(VG.QTDE) DESC                                                                      --|
;                                                                                            --|
                                                                                             --|
-----------------------------------------------------------------------------------------------+