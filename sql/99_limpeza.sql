/* =====================================================================
   99 · Limpeza
   ===================================================================== */
EXEC DBMS_CLOUD_AI_AGENT.DROP_TEAM('TIME_ITOPS');
EXEC DBMS_CLOUD_AI_AGENT.DROP_TASK('TRIAGEM_ITOPS');
EXEC DBMS_CLOUD_AI_AGENT.DROP_AGENT('ANALISTA_ITOPS');
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('ABRIR_CHAMADO');
EXEC DBMS_CLOUD_AI_AGENT.DROP_TOOL('ITOPS_SQL');
EXEC DBMS_CLOUD_AI.DROP_PROFILE('ITOPS_PROFILE');
DROP FUNCTION perguntar_agente;
DROP FUNCTION abrir_chamado;
DROP TABLE conversa_lab PURGE;
DROP TABLE auditoria_agente PURGE;
DROP TABLE chamados PURGE;
DROP TABLE incidentes PURGE;
DROP TABLE servidores PURGE;
