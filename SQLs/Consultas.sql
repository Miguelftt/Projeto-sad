# a) Qual o número de chamados abertos ? Nos últimos meses ? 

SELECT 
    dt.Ano,
    dt.Mes,
    dt.nomeMes,
    COUNT(*) AS Total_Chamados
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
WHERE 
    dt.Data >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) -- últimos 6 meses
GROUP BY 
    dt.Ano, dt.Mes, dt.nomeMes
ORDER BY 
    dt.Ano DESC, dt.Mes DESC;

# -------------------------------------------------------------------------------
# b) Qual o número de chamados fechados ? 

SELECT 
    dt.Ano,
    dt.Mes,
    dt.nomeMes,
    COUNT(*) AS Total_Chamados_Fechados
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
WHERE 
    fc.ID_Status = 5  -- Status 'Fechado'
GROUP BY 
    dt.Ano, dt.Mes, dt.nomeMes
ORDER BY 
    dt.Ano DESC, dt.Mes DESC;

# -------------------------------------------------------------------------------
# c) Qual o número de chamados que passaram para o status ‘Em Andamento’ ? 
SELECT 
    dt.Ano,
    dt.Mes,
    dt.nomeMes,
    COUNT(*) AS Total_Em_Andamento
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
WHERE 
    fc.ID_Status = 2  -- Status 'Em Andamento'
GROUP BY 
    dt.Ano, dt.Mes, dt.nomeMes
ORDER BY 
    dt.Ano DESC, dt.Mes DESC;
# -------------------------------------------------------------------------------
# d)
-- Por Dia
SELECT 
    'Dia' AS Tipo_Agrupamento,
    dt.Data AS Periodo,
    NULL AS Mes,
    NULL AS NomeMes,
    NULL AS Semestre,
    NULL AS NomeSemestre,
    COUNT(*) AS Total_Fechados
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
WHERE 
    fc.ID_Status = 5
GROUP BY 
    dt.Data

UNION ALL

-- Por Mês
SELECT 
    'Mês' AS Tipo_Agrupamento,
    NULL AS Periodo,
    dt.Mes,
    dt.nomeMes,
    NULL AS Semestre,
    NULL AS NomeSemestre,
    COUNT(*) AS Total_Fechados
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
WHERE 
    fc.ID_Status = 5
GROUP BY 
    dt.Ano, dt.Mes, dt.nomeMes

UNION ALL

-- Por Semestre
SELECT 
    'Semestre' AS Tipo_Agrupamento,
    NULL AS Periodo,
    NULL AS Mes,
    NULL AS NomeMes,
    dt.Semestre,
    dt.NomeSemestre,
    COUNT(*) AS Total_Fechados
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
WHERE 
    fc.ID_Status = 5
GROUP BY 
    dt.Ano, dt.Semestre, dt.NomeSemestre;

# --------------------------------------------------------------------
# e)
SELECT 
    dd.Nome_Departamento,
    dt.Ano,
    dt.Mes,
    dt.nomeMes,
    COUNT(*) AS Total_Chamados
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Departamento dd ON fc.ID_Departamento = dd.ID_Departamento
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
GROUP BY 
    dd.Nome_Departamento, dt.Ano, dt.Mes, dt.nomeMes
ORDER BY 
    dd.Nome_Departamento, dt.Ano, dt.Mes;

# --------------------------------------------------------------------
# f)

-- Chamados por Canal de Atendimento por Ano, Mês e Semestre
SELECT 
    dca.descricao_canal AS Canal_Atendimento,
    dt.Ano,
    dt.Mes,
    dt.nomeMes,
    dt.Semestre,
    dt.NomeSemestre,
    COUNT(*) AS Total_Chamados
FROM 
    Fato_Chamados fc
JOIN 
    Dim_CanalAtendimento dca ON fc.ID_Canal = dca.ID_Canal
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
GROUP BY 
    dca.descricao_canal, dt.Ano, dt.Mes, dt.nomeMes, dt.Semestre, dt.NomeSemestre
ORDER BY 
    dca.descricao_canal, dt.Ano, dt.Mes;

# --------------------------------------------------------------------
# g)
-- Chamados por Tipo de Serviço por Ano, Mês e Semestre
SELECT 
    dts.descricao_servico AS Tipo_Servico,
    dt.Ano,
    dt.Mes,
    dt.nomeMes,
    dt.Semestre,
    dt.NomeSemestre,
    COUNT(*) AS Total_Chamados
FROM 
    Fato_Chamados fc
JOIN 
    Dim_TipoServico dts ON fc.ID_Servico = dts.ID_Servico
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
GROUP BY 
    dts.descricao_servico, dt.Ano, dt.Mes, dt.nomeMes, dt.Semestre, dt.NomeSemestre
ORDER BY 
    dts.descricao_servico, dt.Ano, dt.Mes;

# --------------------------------------------------------------------
# h)
SELECT 
    dp.Nivel_Prioridade AS Prioridade,
    dt.Ano,
    dt.Mes,
    dt.nomeMes,
    dt.Semestre,
    dt.NomeSemestre,
    COUNT(*) AS Total_Chamados_Abertos
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
JOIN 
    Dim_Prioridade dp ON fc.ID_Prioridade = dp.ID_Prioridade
WHERE 
    fc.ID_Status = 1  -- Apenas chamados abertos
GROUP BY 
    dp.Nivel_Prioridade, dt.Ano, dt.Mes, dt.nomeMes, dt.Semestre, dt.NomeSemestre
ORDER BY 
    dp.Nivel_Prioridade, dt.Ano, dt.Mes;

# --------------------------------------------------------------------
# i)
SELECT 
    df.Nome AS Funcionario,
    df.Cargo,
    COUNT(*) AS Total_Chamados_Atendidos
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Funcionario df ON fc.ID_Funcionario = df.ID_Funcionario
WHERE 
    df.Departamento = 'TI'
GROUP BY 
    df.Nome, df.Cargo
ORDER BY 
    Total_Chamados_Atendidos DESC;


# --------------------------------------------------------------------
# j)
SELECT 
    df.Setor,
    COUNT(*) AS Total_Chamados_Atendidos
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Funcionario df ON fc.ID_Funcionario = df.ID_Funcionario
WHERE 
    df.Departamento = 'TI'
GROUP BY 
    df.Setor
ORDER BY 
    Total_Chamados_Atendidos DESC;

# --------------------------------------------------------------------
# k)
SELECT 
    dd.Nome_Departamento AS Departamento_Usuario,
    dt.Ano,
    dt.Mes,
    dt.nomeMes,
    dt.Semestre,
    dt.NomeSemestre,
    COUNT(*) AS Total_Chamados_Abertos
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Departamento dd ON fc.ID_Departamento = dd.ID_Departamento
JOIN 
    Dim_Tempo dt ON fc.ID_Tempo = dt.ID_Tempo
WHERE 
    fc.ID_Status = 1 -- Apenas chamados abertos
GROUP BY 
    dd.Nome_Departamento, dt.Ano, dt.Mes, dt.nomeMes, dt.Semestre, dt.NomeSemestre
ORDER BY 
    dd.Nome_Departamento, dt.Ano, dt.Mes;
# --------------------------------------------------------------------
# L)

SELECT 
    CASE 
        WHEN df.Cargo LIKE '%Técnico N1%' THEN 'Nível 1'
        WHEN df.Cargo LIKE '%Técnico N2%' THEN 'Nível 2'
        ELSE 'Nível 3'
    END AS Nivel_Suporte,
    COUNT(*) AS Total_Chamados_Fechados
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Funcionario df ON fc.ID_Funcionario = df.ID_Funcionario
WHERE 
    fc.ID_Status = 5 -- Fechado
  AND df.Departamento = 'TI'
GROUP BY 
    Nivel_Suporte
ORDER BY 
    Nivel_Suporte;



# --------------------------------------------------------------------
# m) n) o) 
SELECT 
    -- 1) Média de tempo abertura → atendimento (N1 + Alta prioridade)
    ROUND(AVG(CASE 
        WHEN dp.Nivel_Prioridade = 'Alta' AND 
             (ds.descricao_suporte LIKE '%Desktop%' OR ds.cod_suporte = 1001)
        THEN fc.tempo_abertura_andamento 
        ELSE NULL 
    END) / 24, 2) AS Media_Abertura_Atendimento_N1_Alta,

    -- 2) Média de tempo abertura → atendimento (N1, todas prioridades)
    ROUND(AVG(CASE 
        WHEN (ds.descricao_suporte LIKE '%Desktop%' OR ds.cod_suporte = 1001)
        THEN fc.tempo_abertura_andamento 
        ELSE NULL 
    END) / 24, 2) AS Media_Abertura_Atendimento_N1_Geral,

    -- 3) Média de tempo abertura → fechamento (todos os chamados com tempo calculado)
    ROUND(AVG(fc.tempo_abertura_fechamento) / 24, 2) AS Media_Abertura_Fechamento
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Prioridade dp ON fc.ID_Prioridade = dp.ID_Prioridade
JOIN 
    Dim_Suporte ds ON fc.id_suporte = ds.id_suporte
WHERE 
    -- Só considera registros com tempos calculados válidos
    (fc.tempo_abertura_andamento IS NOT NULL OR fc.tempo_abertura_fechamento IS NOT NULL);


# -------------------------------------------------------------------------------------
# p) q)

SELECT 
    ds.Nivel_Satisfacao AS Satisfacao,
    COUNT(*) AS Total_Chamados,
    SUM(CASE WHEN fc.tempo_abertura_fechamento > fc.Tempo_Esperado_Atendimento THEN 1 ELSE 0 END) AS Fora_SLA,
    SUM(CASE WHEN fc.tempo_abertura_fechamento <= fc.Tempo_Esperado_Atendimento THEN 1 ELSE 0 END) AS Dentro_SLA
FROM 
    Fato_Chamados fc
JOIN 
    Dim_Satisfacao ds ON fc.ID_Satisfacao = ds.ID_Satisfacao
WHERE 
    fc.tempo_abertura_fechamento IS NOT NULL
GROUP BY 
    ds.Nivel_Satisfacao
ORDER BY 
    ds.Nivel_Satisfacao;
