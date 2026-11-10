/* =====================================================================
   06 · Provas de governança
   ===================================================================== */
SELECT * FROM chamados ORDER BY chamado_id;

SELECT quando, ferramenta, entrada, resultado
  FROM auditoria_agente
 ORDER BY evento_id;

-- Histórico do agente (os nomes das views podem variar por versão)
SELECT * FROM user_ai_agent_team_history ORDER BY start_date DESC FETCH FIRST 5 ROWS ONLY;
SELECT * FROM user_ai_agent_tool_history ORDER BY start_date DESC FETCH FIRST 10 ROWS ONLY;
