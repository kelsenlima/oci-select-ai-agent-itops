/* =====================================================================
   02 · Perfil de IA restrito
   Só as tabelas em object_list ficam visíveis para a IA.
   A auditoria_agente fica de fora de propósito.
   O compartimento é lido do próprio banco e o owner é o schema atual,
   então não precisa colar OCID nenhum.
   ===================================================================== */

DECLARE
  v_comp  VARCHAR2(400);
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
BEGIN
  SELECT JSON_VALUE(cloud_identity, '$.COMPARTMENT_OCID') INTO v_comp FROM v$pdbs;

  DBMS_CLOUD_AI.CREATE_PROFILE(
    profile_name => 'ITOPS_PROFILE',
    attributes   => '{"provider":"oci",'
                 || '"credential_name":"OCI$RESOURCE_PRINCIPAL",'
                 || '"oci_compartment_id":"' || v_comp || '",'
                 || '"region":"us-chicago-1",'
                 || '"comments":"true",'
                 || '"object_list":['
                 || '{"owner":"' || v_owner || '","name":"SERVIDORES"},'
                 || '{"owner":"' || v_owner || '","name":"INCIDENTES"},'
                 || '{"owner":"' || v_owner || '","name":"CHAMADOS"}]}'
  );
END;
/
-- region: use uma região com OCI Generative AI (us-chicago-1 funciona).

-- Teste rápido do perfil.
-- No SQLcl ou SQL Developer:
--   EXEC DBMS_CLOUD_AI.SET_PROFILE('ITOPS_PROFILE');
--   SELECT AI quantos incidentes estão abertos por servidor;
-- No Database Actions (navegador), SELECT AI não funciona. Use:
SELECT DBMS_CLOUD_AI.GENERATE(
         prompt       => 'quantos incidentes estão abertos por servidor',
         profile_name => 'ITOPS_PROFILE',
         action       => 'narrate') AS resposta
  FROM dual;
