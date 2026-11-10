/* =====================================================================
   00 · Setup [rode como ADMIN]
   Habilita o resource principal: o banco acessa o OCI Generative AI
   com a própria identidade, sem chave de API guardada.

   Antes, no console OCI:
     a) Dynamic Group com a regra:
          resource.id = '<OCID_DO_SEU_AUTONOMOUS_DATABASE>'
     b) Policy no compartimento (ou na raiz):
          allow dynamic-group <NOME_DO_DG> to use generative-ai-family in compartment <SEU_COMPARTIMENTO>
   ===================================================================== */

EXEC DBMS_CLOUD_ADMIN.ENABLE_RESOURCE_PRINCIPAL();

-- Confere: deve aparecer a credencial OCI$RESOURCE_PRINCIPAL
SELECT owner, credential_name FROM dba_credentials
 WHERE credential_name = 'OCI$RESOURCE_PRINCIPAL';

/* ---------------------------------------------------------------------
   Opcional (recomendado em produção): usuário dedicado.
   Eu rodei o lab como ADMIN para simplificar. Em produção, não.
   --------------------------------------------------------------------- */
-- CREATE USER itops_lab IDENTIFIED BY "<SENHA_FORTE>";
-- GRANT DWROLE, UNLIMITED TABLESPACE TO itops_lab;
-- GRANT EXECUTE ON DBMS_CLOUD_AI TO itops_lab;
-- GRANT EXECUTE ON DBMS_CLOUD_AI_AGENT TO itops_lab;
-- EXEC DBMS_CLOUD_ADMIN.ENABLE_RESOURCE_PRINCIPAL(username => 'ITOPS_LAB');
