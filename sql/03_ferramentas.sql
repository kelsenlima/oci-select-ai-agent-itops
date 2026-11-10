/* =====================================================================
   03 · Ferramentas do agente
   ITOPS_SQL: consulta em linguagem natural.
   ABRIR_CHAMADO: função PL/SQL determinística. O agente nunca escreve
   direto na tabela; a função valida, grava e audita.
   ===================================================================== */

BEGIN
  DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
    tool_name  => 'ITOPS_SQL',
    attributes => '{"tool_type": "SQL",
                    "tool_params": {"profile_name": "ITOPS_PROFILE"}}',
    description => 'Consulta inventário, incidentes e chamados em linguagem natural'
  );
END;
/


/* ---------------------------------------------------------------------
   PASSO 4 · Ferramenta própria em PL/SQL: abrir chamado, com auditoria
   O agente nunca escreve direto na tabela. Ele só pode chamar esta
   função, que valida, grava e registra tudo na auditoria.
   --------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION abrir_chamado (
  p_hostname   IN VARCHAR2,
  p_titulo     IN VARCHAR2,
  p_prioridade IN VARCHAR2
) RETURN CLOB
IS
  v_servidor_id servidores.servidor_id%TYPE;
  v_chamado_id  chamados.chamado_id%TYPE;
  v_prior       VARCHAR2(10) := UPPER(TRIM(p_prioridade));
  v_resultado   VARCHAR2(4000);
BEGIN
  IF v_prior NOT IN ('ALTA', 'MEDIA', 'BAIXA') THEN
    v_resultado := 'Recusado: prioridade deve ser ALTA, MEDIA ou BAIXA.';
  ELSE
    BEGIN
      SELECT servidor_id INTO v_servidor_id
        FROM servidores WHERE LOWER(hostname) = LOWER(TRIM(p_hostname));

      INSERT INTO chamados (servidor_id, titulo, prioridade, aberto_por)
      VALUES (v_servidor_id, SUBSTR(p_titulo, 1, 200), v_prior, 'AGENTE_ITOPS')
      RETURNING chamado_id INTO v_chamado_id;

      v_resultado := 'Chamado ' || v_chamado_id || ' aberto para ' || p_hostname || ' com prioridade ' || v_prior || '.';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_resultado := 'Recusado: servidor ' || p_hostname || ' não existe no inventário.';
    END;
  END IF;

  INSERT INTO auditoria_agente (ferramenta, entrada, resultado)
  VALUES ('ABRIR_CHAMADO',
          'host=' || p_hostname || '; titulo=' || p_titulo || '; prioridade=' || p_prioridade,
          v_resultado);
  COMMIT;
  RETURN v_resultado;
END;
/

BEGIN
  DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
    tool_name  => 'ABRIR_CHAMADO',
    attributes => '{
      "instruction": "Abre um chamado para um servidor do inventário. Use somente depois que o usuário aprovar explicitamente a abertura.",
      "function": "ABRIR_CHAMADO",
      "tool_inputs": [
        {"name": "p_hostname",   "description": "Hostname exato do servidor, por exemplo erp-db-01"},
        {"name": "p_titulo",     "description": "Título curto e objetivo do chamado"},
        {"name": "p_prioridade", "description": "ALTA, MEDIA ou BAIXA"}
      ]
    }',
    description => 'Abre chamado com validação e auditoria'
  );
END;
/
