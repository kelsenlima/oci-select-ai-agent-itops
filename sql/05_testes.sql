/* =====================================================================
   05 · Testes
   Opção A: SQLcl ou SQL Developer (SELECT AI AGENT)
   Opção B: Database Actions (navegador), com RUN_TEAM e conversa salva
   ===================================================================== */

/* ---------- Opção A · SQLcl / SQL Developer ---------- */
-- EXEC DBMS_CLOUD_AI_AGENT.SET_TEAM('TIME_ITOPS');
-- SELECT AI AGENT quais servidores de produção têm incidentes abertos agora;
-- SELECT AI AGENT qual categoria de incidente mais se repete e quanto tempo em média levamos para resolver;
-- SELECT AI AGENT o erp-db-01 está com o disco crítico, você recomenda abrir chamado;
-- SELECT AI AGENT sim, pode abrir com prioridade ALTA;
-- SELECT AI AGENT abra um chamado para o servidor xpto-99 com prioridade urgente;


/* ---------- Opção B · Database Actions ----------
   Helper que guarda o conversation_id, para o agente lembrar do
   contexto entre uma pergunta e outra (e da aprovação humana).        */
CREATE TABLE conversa_lab (
  id              NUMBER PRIMARY KEY,
  conversation_id VARCHAR2(4000)
);

CREATE OR REPLACE FUNCTION perguntar_agente (
  p_texto IN VARCHAR2,
  p_nova  IN VARCHAR2 DEFAULT 'N'
) RETURN CLOB
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_conv VARCHAR2(4000);
  v_resp CLOB;
BEGIN
  IF p_nova = 'S' THEN
    DELETE FROM conversa_lab;
  END IF;

  BEGIN
    SELECT conversation_id INTO v_conv FROM conversa_lab WHERE id = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_conv := DBMS_CLOUD_AI.CREATE_CONVERSATION();
      INSERT INTO conversa_lab (id, conversation_id) VALUES (1, v_conv);
  END;

  v_resp := DBMS_CLOUD_AI_AGENT.RUN_TEAM(
              team_name   => 'TIME_ITOPS',
              user_prompt => p_texto,
              params      => '{"conversation_id":"' || v_conv || '"}');
  COMMIT;
  RETURN v_resp;
END;
/

-- Teste 1 · pergunta simples (abre conversa nova)
SELECT perguntar_agente('quais servidores de produção têm incidentes abertos agora', 'S') FROM dual;

-- Teste 2 · análise
SELECT perguntar_agente('qual categoria de incidente mais se repete e quanto tempo em média levamos para resolver') FROM dual;

-- Teste 3 · ação com aprovação humana (o agente deve perguntar antes)
SELECT perguntar_agente('o erp-db-01 está com o disco crítico, você recomenda abrir chamado') FROM dual;
SELECT perguntar_agente('sim, pode abrir com prioridade ALTA') FROM dual;

-- Teste 4 · fora da regra (a função deve recusar)
SELECT perguntar_agente('abra um chamado para o servidor xpto-99 com prioridade urgente') FROM dual;
