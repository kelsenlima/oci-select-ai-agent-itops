/* =====================================================================
   04 · Agente, tarefa e time (com aprovação humana)
   ===================================================================== */

BEGIN
  DBMS_CLOUD_AI_AGENT.CREATE_AGENT(
    agent_name => 'ANALISTA_ITOPS',
    attributes => '{
      "profile_name": "ITOPS_PROFILE",
      "role": "Você é um analista de operações de TI. Responde em português do Brasil, com números, sobre inventário, incidentes e chamados. Nunca abre chamado sem aprovação explícita do usuário.",
      "tools": ["ITOPS_SQL", "ABRIR_CHAMADO"],
      "enable_human_tool": "true",
      "short_term_memory_length": 10
    }'
  );
END;
/

BEGIN
  DBMS_CLOUD_AI_AGENT.CREATE_TASK(
    task_name  => 'TRIAGEM_ITOPS',
    attributes => '{
      "instruction": "Atenda ao pedido do usuário: {query}. Use ITOPS_SQL para consultar os dados. Se recomendar abrir chamado, explique o motivo, pergunte ao usuário e só use ABRIR_CHAMADO depois de um sim.",
      "tools": ["ITOPS_SQL", "ABRIR_CHAMADO"],
      "enable_human_tool": "true"
    }'
  );
END;
/

BEGIN
  DBMS_CLOUD_AI_AGENT.CREATE_TEAM(
    team_name  => 'TIME_ITOPS',
    attributes => '{
      "agents": [{"name": "ANALISTA_ITOPS", "task": "TRIAGEM_ITOPS"}],
      "process": "sequential"
    }'
  );
END;
/
