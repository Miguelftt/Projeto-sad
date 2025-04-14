-- Script para preencher a tabela Dim_Tempo com os anos 2023 e 2024 (MySQL) 

 -- Função auxiliar para obter o último dia do mês 
DELIMITER // 
CREATE FUNCTION IF NOT EXISTS ultimo_dia_mes(data DATE)  
RETURNS DATE 
DETERMINISTIC 
BEGIN 
    RETURN LAST_DAY(data); 
END // 
DELIMITER ; 
 -- Procedimento para preencher a tabela Dim_Tempo 
DELIMITER // 
CREATE PROCEDURE preencher_dim_tempo() 
BEGIN 
    DECLARE data_atual DATE; 
    DECLARE data_final DATE; 
    DECLARE id_tempo INT; 
    DECLARE dia INT; 
    DECLARE dia_semana VARCHAR(25); 
    DECLARE dia_util CHAR(3); 
    DECLARE feriado CHAR(3); 
    DECLARE fim_semana CHAR(3); 
    DECLARE quinzena SMALLINT; 
    DECLARE mes INT; 
    DECLARE nome_mes VARCHAR(20); 
    DECLARE fim_mes VARCHAR(3); 
    DECLARE trimestre SMALLINT; 
    DECLARE nome_trimestre VARCHAR(20); 
    DECLARE semestre SMALLINT; 
    DECLARE nome_semestre VARCHAR(20); 
    DECLARE ano SMALLINT; 
    DECLARE estacao VARCHAR(9); 
     
    -- Inicializar variáveis 
    SET data_atual = '2023-01-01'; 
    SET data_final = '2024-12-31'; 
    SET id_tempo = 1; 
     
    -- Loop para gerar registros para cada dia 
    WHILE data_atual <= data_final DO 
        -- Calcular valores para cada campo 
        SET dia = DAY(data_atual); 
         
        -- Dia da semana 
        SET dia_semana = CASE DAYOFWEEK(data_atual) 
            WHEN 1 THEN 'Domingo' 
            WHEN 2 THEN 'Segunda-feira' 
            WHEN 3 THEN 'Terça-feira' 
            WHEN 4 THEN 'Quarta-feira' 
            WHEN 5 THEN 'Quinta-feira' 
            WHEN 6 THEN 'Sexta-feira' 
            WHEN 7 THEN 'Sábado' 
        END; 
         
        -- Dia útil 
        SET dia_util = CASE WHEN DAYOFWEEK(data_atual) IN (1, 7) THEN 'NAO' ELSE 
'SIM' END; 
         
        -- Feriado (por padrão, não é feriado) 
        SET feriado = 'NAO'; 
         
        -- Fim de semana 
        SET fim_semana = CASE WHEN DAYOFWEEK(data_atual) IN (1, 7) THEN 'SIM' 
ELSE 'NAO' END; 
         
        -- Quinzena 
        SET quinzena = CASE WHEN DAY(data_atual) <= 15 THEN 1 ELSE 2 END; 
         
        -- Mês 
        SET mes = MONTH(data_atual); 
         
        -- Nome do mês 
        SET nome_mes = CASE MONTH(data_atual) 
            WHEN 1 THEN 'Janeiro' 
            WHEN 2 THEN 'Fevereiro' 
            WHEN 3 THEN 'Março' 
            WHEN 4 THEN 'Abril' 
            WHEN 5 THEN 'Maio' 
            WHEN 6 THEN 'Junho' 
            WHEN 7 THEN 'Julho' 
            WHEN 8 THEN 'Agosto' 
            WHEN 9 THEN 'Setembro' 
            WHEN 10 THEN 'Outubro' 
            WHEN 11 THEN 'Novembro' 
            WHEN 12 THEN 'Dezembro' 
        END; 
         
        -- Fim do mês 
        SET fim_mes = CASE WHEN DAY(data_atual) = DAY(ultimo_dia_mes(data_atual)) 
THEN 'SIM' ELSE 'NAO' END; 
         
        -- Trimestre 
        SET trimestre = QUARTER(data_atual); 
         
        -- Nome do trimestre 
        SET nome_trimestre = CONCAT('T', QUARTER(data_atual)); 
         
        -- Semestre 
        SET semestre = CASE WHEN MONTH(data_atual) <= 6 THEN 1 ELSE 2 END; 
         
        -- Nome do semestre 
        SET nome_semestre = CASE WHEN MONTH(data_atual) <= 6 THEN '1º Semestre' 
ELSE '2º Semestre' END; 
         
        -- Ano 
        SET ano = YEAR(data_atual); 
         
        -- Estação do ano
        SET estacao = CASE  
            WHEN (MONTH(data_atual) = 12 AND DAY(data_atual) >= 21) OR 
(MONTH(data_atual) IN (1, 2) OR (MONTH(data_atual) = 3 AND DAY(data_atual) < 21)) 
THEN 'Verão' 
            WHEN (MONTH(data_atual) = 3 AND DAY(data_atual) >= 21) OR 
(MONTH(data_atual) IN (4, 5) OR (MONTH(data_atual) = 6 AND DAY(data_atual) < 21)) 
THEN 'Outono' 
            WHEN (MONTH(data_atual) = 6 AND DAY(data_atual) >= 21) OR 
(MONTH(data_atual) IN (7, 8) OR (MONTH(data_atual) = 9 AND DAY(data_atual) < 21)) 
THEN 'Inverno' 
            WHEN (MONTH(data_atual) = 9 AND DAY(data_atual) >= 21) OR 
(MONTH(data_atual) IN (10, 11) OR (MONTH(data_atual) = 12 AND DAY(data_atual) < 21)) 
THEN 'Primavera' 
        END; 
         
        -- Inserir registro na tabela 
        INSERT INTO Dim_Tempo ( 
            ID_Tempo, Data, Dia, Dia_Semana, DiaUtil, Feriado, FimSemana,  
            Quinzena, Mes, nomeMes, FimMes, Trimestre, nomeTrimestre,  
            Semestre, NomeSemestre, Ano, Estacao 
        ) VALUES ( 
            id_tempo, data_atual, dia, dia_semana, dia_util, feriado, fim_semana, 
            quinzena, mes, nome_mes, fim_mes, trimestre, nome_trimestre, 
            semestre, nome_semestre, ano, estacao 
        ); 
         
        -- Incrementar para o próximo dia 
        SET data_atual = DATE_ADD(data_atual, INTERVAL 1 DAY); 
        SET id_tempo = id_tempo + 1; 
    END WHILE; 
     
    -- Atualizar feriados nacionais para 2023 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-01-01'; -- Ano Novo 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-02-20'; -- Carnaval 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-02-21'; -- Carnaval 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-04-07'; -- Sexta-feira Santa 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-04-09'; -- Páscoa 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-04-21'; -- Tiradentes 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-05-01'; -- Dia do Trabalho 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-06-08'; -- Corpus Christi 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-09-07'; -- Independência 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-10-12'; -- N. Sra. Aparecida 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-11-02'; -- Finados 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-11-15'; -- Proclamação da República 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2023-12-25'; -- Natal 
 
    -- Feriados 2024 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-01-01'; -- Ano Novo 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-02-12'; -- Carnaval 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-02-13'; -- Carnaval 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-03-29'; -- Sexta-feira Santa 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-03-31'; -- Páscoa 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-04-21'; -- Tiradentes 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-05-01'; -- Dia do Trabalho 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-05-30'; -- Corpus Christi 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-09-07'; -- Independência 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-10-12'; -- N. Sra. Aparecida 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-11-02'; -- Finados 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-11-15'; -- Proclamação da República 
    UPDATE Dim_Tempo SET Feriado = 'SIM', DiaUtil = 'NAO' WHERE Data = '2024-12-25'; -- Natal 
END // 
DELIMITER ; 
 -- Executar o procedimento 
CALL preencher_dim_tempo(); 
 
 -- DROP FUNCTION IF EXISTS ultimo_dia_mes; 
 -- DROP PROCEDURE IF EXISTS preencher_dim_tempo; 
 -- Verificação (opcional) -- SELECT COUNT(*) AS Total_Dias FROM Dim_Tempo WHERE Ano IN (2023, 2024); 
 -- SELECT * FROM Dim_Tempo WHERE Ano IN (2023, 2024) ORDER BY Data; 
 
 
 #----------------------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------------------
   #--------------------------------------------------------------------------------------------------------
 
 
 -- Script para preencher a tabela Fato_Chamados com dados para 2023 e 2024 
DELIMITER // 
CREATE PROCEDURE preencher_fato_chamados() 
BEGIN 
    -- Declaração de variáveis 
    DECLARE i INT DEFAULT 1; 
    DECLARE total_registros INT DEFAULT 100; -- Total de 100 registros (50 para cada ano) 
    DECLARE categoria_id INT; 
    DECLARE canal_id INT; 
    DECLARE satisfacao_id INT; 
    DECLARE prioridade_id INT; 
    DECLARE status_id INT; 
    DECLARE servico_id INT; 
    DECLARE suporte_id INT; 
    DECLARE funcionario_id INT; 
    DECLARE tempo_id INT;  
    DECLARE usuario_id INT; 
    DECLARE departamento_id INT; 
    DECLARE tempo_aber_and INT; 
    DECLARE tempo_aber_fech INT; 
    DECLARE tempo_and_fech INT; 
    DECLARE tempo_esperado INT; 
    DECLARE data_chamado DATE; 
    DECLARE ano_chamado INT; 
     
    -- 1. Dim_Categoria
    IF (SELECT COUNT(*) FROM Dim_Categoria) = 0 THEN 
        INSERT INTO Dim_Categoria (id_categoria, cod_categoria, descricao_categoria) 
VALUES 
        (1, 101, 'Hardware'), 
        (2, 102, 'Software'), 
        (3, 103, 'Redes'), 
        (4, 104, 'Banco de Dados'), 
        (5, 105, 'Email'), 
        (6, 106, 'ERP'), 
        (7, 107, 'Impressoras'), 
        (8, 108, 'Sistemas Web'), 
        (9, 109, 'Telecom'), 
        (10, 110, 'Segurança'); 
    END IF; 
     
    -- 2. Dim_CanalAtendimento
    IF (SELECT COUNT(*) FROM Dim_CanalAtendimento) = 0 THEN 
        INSERT INTO Dim_CanalAtendimento (ID_Canal, Cod_Canal, descricao_canal) 
VALUES 
        (1, 'WEB', 'Portal Web'), 
        (2, 'TEL', 'Telefone'), 
        (3, 'EMAIL', 'Email'), 
        (4, 'APP', 'Aplicativo Móvel'), 
        (5, 'CHAT', 'Chat Online'); 
    END IF; 
     
    -- 3. Dim_Satisfacao 
    IF (SELECT COUNT(*) FROM Dim_Satisfacao) = 0 THEN 
        INSERT INTO Dim_Satisfacao (ID_Satisfacao, Cod_Satisfacao, Nivel_Satisfacao) 
VALUES 
        (1, 1, 'Muito insatisfeito'), 
        (2, 2, 'Insatisfeito'), 
        (3, 3, 'Neutro'), 
        (4, 4, 'Satisfeito'), 
        (5, 5, 'Muito satisfeito'); 
    END IF; 
     
    -- 4. Dim_Prioridade 
    IF (SELECT COUNT(*) FROM Dim_Prioridade) = 0 THEN 
        INSERT INTO Dim_Prioridade (ID_Prioridade, Nivel_Prioridade, cod_prioridade) 
VALUES 
        (1, 'Baixa', 1), 
        (2, 'Média', 2), 
        (3, 'Alta', 3), 
        (4, 'Crítica', 4); 
    END IF; 
     
    -- 5. Dim_Status 
    IF (SELECT COUNT(*) FROM Dim_Status) = 0 THEN 
        INSERT INTO Dim_Status (ID_Status, cod_status, Descricao_Status) VALUES 
        (1, 1, 'Aberto'), 
        (2, 2, 'Em andamento'), 
        (3, 3, 'Aguardando usuário'), 
        (4, 4, 'Resolvido'), 
        (5, 5, 'Fechado'), 
        (6, 6, 'Cancelado'); 
    END IF; 
     
    -- 6. Dim_TipoServico
    IF (SELECT COUNT(*) FROM Dim_TipoServico) = 0 THEN 
        INSERT INTO Dim_TipoServico (ID_Servico, cod_servico, descricao_servico) VALUES 
        (1, 101, 'Suporte técnico'), 
        (2, 102, 'Instalação de software'), 
        (3, 103, 'Configuração de rede'), 
        (4, 104, 'Backup de dados'), 
        (5, 105, 'Recuperação de dados'), 
        (6, 106, 'Manutenção preventiva'), 
        (7, 107, 'Manutenção corretiva'), 
        (8, 108, 'Treinamento'), 
        (9, 109, 'Configuração de email'), 
        (10, 110, 'Acesso remoto'); 
    END IF; 
     
    -- 7. Dim_Suporte
    IF (SELECT COUNT(*) FROM Dim_Suporte) = 0 THEN 
        INSERT INTO Dim_Suporte (id_suporte, cod_suporte, descricao_suporte) VALUES 
        (1, 1001, 'Equipe de Desktop'), 
        (2, 1002, 'Equipe de Servidores'), 
        (3, 1003, 'Equipe de Redes'), 
        (4, 1004, 'Equipe de Segurança'), 
        (5, 1005, 'Equipe de Sistemas'); 
    END IF; 
     
    -- 8. Dim_Funcionario 
    IF (SELECT COUNT(*) FROM Dim_Funcionario) = 0 THEN 
        INSERT INTO Dim_Funcionario (ID_Funcionario, Nome, matricula, Departamento, 
Cargo, Setor) VALUES 
        (1, 'João Silva', 'F1001', 'TI', 'Técnico N1', 'Suporte'), 
        (2, 'Maria Santos', 'F1002', 'TI', 'Técnico N2', 'Suporte'), 
        (3, 'Pedro Costa', 'F1003', 'TI', 'Analista', 'Suporte'), 
        (4, 'Ana Ferreira', 'F1004', 'TI', 'Analista Sênior', 'Infraestrutura'), 
        (5, 'Carlos Oliveira', 'F1005', 'TI', 'Coordenador', 'Suporte'), 
        (6, 'Luiza Pereira', 'F1006', 'TI', 'Especialista', 'Segurança'), 
        (7, 'Fernando Souza', 'F1007', 'TI', 'Gerente', 'TI'), 
        (8, 'Julia Lima', 'F1008', 'TI', 'Técnico N1', 'Redes'), 
        (9, 'Rafael Almeida', 'F1009', 'TI', 'Técnico N2', 'Banco de Dados'), 
        (10, 'Amanda Ribeiro', 'F1010', 'TI', 'Analista', 'Desenvolvimento'); 
    END IF; 
     
    -- 9. Dim_Departamento 
    IF (SELECT COUNT(*) FROM Dim_Departamento) = 0 THEN 
        INSERT INTO Dim_Departamento (ID_Departamento, Nome_Departamento, Setor) 
VALUES 
        (1, 'TI', 'Tecnologia'), 
        (2, 'RH', 'Administrativo'), 
        (3, 'Financeiro', 'Administrativo'), 
        (4, 'Marketing', 'Comercial'), 
        (5, 'Vendas', 'Comercial'), 
        (6, 'Logística', 'Operacional'), 
        (7, 'Produção', 'Operacional'), 
        (8, 'Jurídico', 'Administrativo'), 
        (9, 'Compras', 'Administrativo'), 
        (10, 'Atendimento', 'Comercial'); 
    END IF; 
     
    -- 10. Dim_Usuario  
    IF (SELECT COUNT(*) FROM Dim_Usuario) = 0 THEN 
        INSERT INTO Dim_Usuario (ID_Usuario, Nome_Usuario, Cargo) VALUES 
        (1, 'Roberto Gomes', 'Analista Financeiro'), 
        (2, 'Carolina Dias', 'Gerente de RH'), 
        (3, 'Marcelo Vieira', 'Analista de Marketing'), 
        (4, 'Juliana Bastos', 'Vendedor'), 
        (5, 'Ricardo Campos', 'Diretor Comercial'), 
        (6, 'Aline Castro', 'Assistente Administrativo'), 
        (7, 'Bruno Martins', 'Supervisor de Produção'), 
        (8, 'Tatiana Nunes', 'Advogada'), 
        (9, 'Leandro Soares', 'Comprador'), 
        (10, 'Mariana Duarte', 'Atendente SAC'), 
        (11, 'Lucas Pinto', 'Estagiário TI'), 
        (12, 'Patrícia Vieira', 'Gerente de Projetos'), 
        (13, 'Gabriel Costa', 'Desenvolvedor'), 
        (14, 'Fernanda Lima', 'Analista de Dados'), 
        (15, 'Rodrigo Santos', 'Contador'); 
    END IF; 
     
    -- Loop para inserir os registros 
    WHILE i <= total_registros DO 
        -- Definir ano aleatoriamente (2023 ou 2024) 
        IF i <= 50 THEN 
            SET ano_chamado = 2023; 
        ELSE 
            SET ano_chamado = 2024; 
        END IF; 
         
        -- Buscar um ID_Tempo aleatório para o ano
        SELECT ID_Tempo INTO tempo_id  
        FROM Dim_Tempo  
        WHERE Ano = ano_chamado  
        ORDER BY RAND()  
        LIMIT 1; 
         
        -- Selecionar valores aleatórios para 
        SET categoria_id = FLOOR(1 + RAND() * 10); 
        SET canal_id = FLOOR(1 + RAND() * 5); 
        SET satisfacao_id = FLOOR(1 + RAND() * 5); 
        SET prioridade_id = FLOOR(1 + RAND() * 4); 
        SET status_id = FLOOR(1 + RAND() * 6); 
        SET servico_id = FLOOR(1 + RAND() * 10); 
        SET suporte_id = FLOOR(1 + RAND() * 5); 
        SET funcionario_id = FLOOR(1 + RAND() * 10); 
        SET usuario_id = FLOOR(1 + RAND() * 15); 
        SET departamento_id = FLOOR(1 + RAND() * 10); 
         
        -- Quanto maior a prioridade, menor o tempo esperado 
        SET tempo_esperado = CASE prioridade_id 
            WHEN 1 THEN FLOOR(24 + RAND() * 48) -- Baixa: 24-72 horas 
            WHEN 2 THEN FLOOR(8 + RAND() * 16) -- Média: 8-24 horas 
            WHEN 3 THEN FLOOR(2 + RAND() * 6) -- Alta: 2-8 horas 
            WHEN 4 THEN FLOOR(1 + RAND() * 1) -- Crítica: 1-2 horas 
        END; 
         
        -- Tempos entre as etapas (em horas) 
        SET tempo_aber_and = FLOOR(1 + RAND() * 4); -- 1-5 horas para começar a atender 
         
        -- Tempo total até fechamento depende do status 
        IF status_id IN (4, 5) THEN 
            SET tempo_and_fech = FLOOR(tempo_esperado * (0.6 + RAND() * 0.8)); -- 60%-140% do tempo esperado 
            SET tempo_aber_fech = tempo_aber_and + tempo_and_fech; 
        ELSE -- Outros status (ainda não fechados) 
            SET tempo_and_fech = NULL; 
            SET tempo_aber_fech = NULL; 
        END IF; 
         
        -- Inserir na tabela Fato_Chamados 
        INSERT INTO Fato_Chamados ( 
            ID_Chamado, 
            id_categoria, 
            ID_Satisfacao, 
            ID_Prioridade, 
            ID_Status, 
            ID_Servico, 
            id_suporte, 
            ID_Funcionario, 
            ID_Tempo, 
            ID_Usuario, 
            ID_Departamento, 
            ID_Canal, 
            tempo_abertura_andamento, 
            tempo_abertura_fechamento, 
            tempo_andamento_fechamento, 
            Tempo_Esperado_Atendimento, 
            quantidade 
        ) VALUES ( 
            i, -- ID do chamado é o contador 
            categoria_id, 
            satisfacao_id, 
            prioridade_id, 
            status_id, 
            servico_id, 
            suporte_id, 
            funcionario_id, 
            tempo_id, 
            usuario_id, 
            departamento_id, 
            canal_id, 
            tempo_aber_and, 
            tempo_aber_fech, 
            tempo_and_fech, 
            tempo_esperado, 
            1 -- quantidade sempre 1 para chamados individuais 
        ); 
         
        SET i = i + 1; 
    END WHILE; 
     
    -- Verificar quantos registros de cada ano foram inseridos 
    SELECT CONCAT('Total de chamados em 2023: ', COUNT(*)) AS info  
    FROM Fato_Chamados fc 
    JOIN Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo 
    WHERE dt.Ano = 2023; 
     
    SELECT CONCAT('Total de chamados em 2024: ', COUNT(*)) AS info  
    FROM Fato_Chamados fc 
    JOIN Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo 
    WHERE dt.Ano = 2024; 
END // 
DELIMITER ; 
 -- Executar o procedimento 
CALL preencher_fato_chamados(); 

 -- DROP PROCEDURE IF EXISTS preencher_fato_chamados; 

SELECT  
    dt.Ano, 
    COUNT(*) AS Total_Chamados, 
    AVG(fc.tempo_abertura_fechamento) AS Media_Tempo_Resolucao, 
    SUM(CASE WHEN fc.tempo_abertura_fechamento <= fc.Tempo_Esperado_Atendimento 
THEN 1 ELSE 0 END) AS Dentro_SLA, 
    SUM(CASE WHEN fc.tempo_abertura_fechamento > fc.Tempo_Esperado_Atendimento 
THEN 1 ELSE 0 END) AS Fora_SLA 
FROM  
    Fato_Chamados fc 
JOIN  
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo 
WHERE  
    fc.tempo_abertura_fechamento IS NOT NULL 
GROUP BY  
    dt.Ano 
ORDER BY  
    dt.Ano; 
 -- Distribuição dos chamados por mês em cada ano 
SELECT  
    dt.Ano, 
    dt.Mes, 
    dt.nomeMes, 
    COUNT(*) AS Total_Chamados, 
    SUM(CASE WHEN dp.Nivel_Prioridade = 'Crítica' THEN 1 ELSE 0 END) AS 
Chamados_Criticos 
FROM  
    Fato_Chamados fc 
JOIN  
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo 
JOIN  
    Dim_Prioridade dp ON fc.ID_Prioridade = dp.ID_Prioridade 
GROUP BY  
    dt.Ano, dt.Mes, dt.nomeMes 
ORDER BY  
    dt.Ano, dt.Mes; 
     
     
    SELECT  
    dt.Ano, 
    COUNT(*) AS Total_Chamados 
FROM  
    Fato_Chamados fc 
JOIN  
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo 
GROUP BY  
    dt.Ano 
ORDER BY  
    dt.Ano;
    
    
     
 #----------------------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------------------
   #--------------------------------------------------------------------------------------------------------
   
   CREATE TABLE Agregado_Chamados_Semestral ( 
    ID_Agregado INT AUTO_INCREMENT PRIMARY KEY, 
    Ano SMALLINT NOT NULL, 
    Semestre SMALLINT NOT NULL, 
    NomeSemestre VARCHAR(20) NOT NULL, 
     
    -- Dimensões mais relevantes para segmentação 
    ID_Categoria INT, 
    ID_Prioridade INT, 
    ID_Status INT, 
    ID_Servico INT, 
    ID_Departamento INT, 
    ID_Canal INT, 
     
    -- Métricas agregadas 
    Total_Chamados INT NOT NULL, 
    Tempo_Medio_Abertura_Andamento FLOAT, 
    Tempo_Medio_Abertura_Fechamento FLOAT, 
    Tempo_Medio_Andamento_Fechamento FLOAT, 
    Tempo_Medio_Esperado FLOAT, 
    Percentual_SLA_Cumprido FLOAT, 
    Total_Resolvidos INT, 
    Total_Pendentes INT, 
     
    -- Distribuição por satisfação 
    Total_Muito_Insatisfeito INT, 
    Total_Insatisfeito INT, 
    Total_Neutro INT, 
    Total_Satisfeito INT, 
    Total_Muito_Satisfeito INT, 
     
    -- Indicadores de eficiência 
    Indice_Eficiencia FLOAT,  -- Relação entre tempo esperado e tempo real 
     
    -- Controle de atualização 
    Data_Atualizacao DATETIME NOT NULL, 
     
    -- Chaves para garantir unicidade do agregado 
    UNIQUE KEY uk_agregado_semestre (Ano, Semestre, ID_Categoria, ID_Prioridade, 
ID_Status, ID_Servico, ID_Departamento, ID_Canal) 
); 
 
DELIMITER // 
CREATE PROCEDURE sp_Atualizar_Agregado_Semestral() 
BEGIN 
    -- Limpar dados antigos 
    TRUNCATE TABLE Agregado_Chamados_Semestral; 
     
    -- Inserir dados agregados 
    INSERT INTO Agregado_Chamados_Semestral ( 
        Ano,  
        Semestre,  
        NomeSemestre, 
        ID_Categoria, 
        ID_Prioridade, 
        ID_Status, 
        ID_Servico, 
        ID_Departamento, 
        ID_Canal, 
        Total_Chamados, 
        Tempo_Medio_Abertura_Andamento, 
        Tempo_Medio_Abertura_Fechamento, 
        Tempo_Medio_Andamento_Fechamento, 
        Tempo_Medio_Esperado, 
        Percentual_SLA_Cumprido, 
        Total_Resolvidos, 
        Total_Pendentes, 
        Total_Muito_Insatisfeito, 
        Total_Insatisfeito, 
        Total_Neutro, 
        Total_Satisfeito, 
        Total_Muito_Satisfeito, 
        Indice_Eficiencia, 
        Data_Atualizacao 
    ) 
    SELECT  
        dt.Ano, 
        dt.Semestre, 
        dt.NomeSemestre, 
        fc.id_categoria, 
        fc.ID_Prioridade, 
        fc.ID_Status, 
        fc.ID_Servico, 
        fc.ID_Departamento, 
        fc.ID_Canal, 
        COUNT(*) AS Total_Chamados, 
        AVG(fc.tempo_abertura_andamento) AS Tempo_Medio_Abertura_Andamento, 
        AVG(fc.tempo_abertura_fechamento) AS Tempo_Medio_Abertura_Fechamento, 
        AVG(fc.tempo_andamento_fechamento) AS Tempo_Medio_Andamento_Fechamento, 
        AVG(fc.Tempo_Esperado_Atendimento) AS Tempo_Medio_Esperado, 
        (SUM(CASE WHEN fc.tempo_abertura_fechamento <= 
fc.Tempo_Esperado_Atendimento THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS 
Percentual_SLA_Cumprido, 
        SUM(CASE WHEN fc.ID_Status IN (4, 5) THEN 1 ELSE 0 END) AS Total_Resolvidos, 
        SUM(CASE WHEN fc.ID_Status NOT IN (4, 5) THEN 1 ELSE 0 END) AS 
Total_Pendentes, 
        SUM(CASE WHEN fc.ID_Satisfacao = 1 THEN 1 ELSE 0 END) AS 
Total_Muito_Insatisfeito, 
        SUM(CASE WHEN fc.ID_Satisfacao = 2 THEN 1 ELSE 0 END) AS Total_Insatisfeito, 
        SUM(CASE WHEN fc.ID_Satisfacao = 3 THEN 1 ELSE 0 END) AS Total_Neutro, 
        SUM(CASE WHEN fc.ID_Satisfacao = 4 THEN 1 ELSE 0 END) AS Total_Satisfeito, 
        SUM(CASE WHEN fc.ID_Satisfacao = 5 THEN 1 ELSE 0 END) AS 
Total_Muito_Satisfeito, 
        CASE  
            WHEN AVG(fc.tempo_abertura_fechamento) > 0  
            THEN AVG(fc.Tempo_Esperado_Atendimento) / 
AVG(fc.tempo_abertura_fechamento)  
            ELSE NULL  
        END AS Indice_Eficiencia, 
        NOW() AS Data_Atualizacao 
    FROM  
        Fato_Chamados fc 
    JOIN  
        Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo 
    GROUP BY  
        dt.Ano, 
        dt.Semestre, 
        dt.NomeSemestre, 
        fc.id_categoria, 
        fc.ID_Prioridade, 
        fc.ID_Status, 
        fc.ID_Servico, 
        fc.ID_Departamento, 
        fc.ID_Canal; 
         
    -- Registrar conclusão 
    SELECT CONCAT('Agregação semestral atualizada em ', NOW(), ' com ',  
                 (SELECT COUNT(*) FROM Agregado_Chamados_Semestral), ' registros.') AS 
Mensagem; 
END // 
DELIMITER ; 
 
CREATE INDEX idx_agregado_ano_semestre ON Agregado_Chamados_Semestral(Ano, 
Semestre); 
CREATE INDEX idx_agregado_categoria ON 
Agregado_Chamados_Semestral(ID_Categoria); 
CREATE INDEX idx_agregado_prioridade ON 
Agregado_Chamados_Semestral(ID_Prioridade); 
CREATE INDEX idx_agregado_status ON Agregado_Chamados_Semestral(ID_Status); 
CREATE INDEX idx_agregado_departamento ON 
Agregado_Chamados_Semestral(ID_Departamento); 
 
 
SELECT  
    Ano, 
    NomeSemestre, 
    SUM(Total_Chamados) AS Total_Chamados, 
    AVG(Tempo_Medio_Abertura_Fechamento) AS Tempo_Medio_Resolucao, 
    AVG(Percentual_SLA_Cumprido) AS Media_SLA_Cumprido 
FROM  
    Agregado_Chamados_Semestral 
GROUP BY  
    Ano, Semestre, NomeSemestre 
ORDER BY  
    Ano, Semestre; 
     
    SELECT  
    Ano, 
    NomeSemestre, 
    SUM(Total_Chamados) AS Total_Chamados, 
    SUM(Total_Muito_Satisfeito + Total_Satisfeito) AS Satisfeitos, 
    SUM(Total_Insatisfeito + Total_Muito_Insatisfeito) AS Insatisfeitos, 
    (SUM(Total_Muito_Satisfeito + Total_Satisfeito) / SUM(Total_Chamados)) * 100 AS 
Percentual_Satisfacao 
FROM  
Agregado_Chamados_Semestral 
GROUP BY  
Ano, Semestre, NomeSemestre 
ORDER BY  
Ano, Semestre;
   