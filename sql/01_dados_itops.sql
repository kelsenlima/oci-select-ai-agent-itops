/* =====================================================================
   01 · Dados de exemplo de ITOps
   Inventário, incidentes, chamados e a tabela de auditoria do agente.
   ===================================================================== */

CREATE TABLE servidores (
  servidor_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  hostname      VARCHAR2(60)  NOT NULL,
  ambiente      VARCHAR2(20)  NOT NULL,   -- PROD, HML, DEV
  nuvem         VARCHAR2(20)  NOT NULL,   -- OCI, GCP, AZURE
  criticidade   VARCHAR2(10)  NOT NULL,   -- ALTA, MEDIA, BAIXA
  dono_time     VARCHAR2(40)  NOT NULL
);
COMMENT ON TABLE  servidores IS 'Inventário de servidores da operação de TI';
COMMENT ON COLUMN servidores.ambiente IS 'PROD, HML ou DEV';
COMMENT ON COLUMN servidores.criticidade IS 'ALTA, MEDIA ou BAIXA';

CREATE TABLE incidentes (
  incidente_id  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  servidor_id   NUMBER REFERENCES servidores,
  aberto_em     TIMESTAMP     NOT NULL,
  resolvido_em  TIMESTAMP,
  severidade    VARCHAR2(10)  NOT NULL,   -- SEV1, SEV2, SEV3
  categoria     VARCHAR2(30)  NOT NULL,   -- DISCO, CPU, REDE, APLICACAO, CERTIFICADO
  descricao     VARCHAR2(400) NOT NULL
);
COMMENT ON TABLE  incidentes IS 'Incidentes de monitoramento por servidor';
COMMENT ON COLUMN incidentes.resolvido_em IS 'Nulo quando o incidente ainda está aberto';

CREATE TABLE chamados (
  chamado_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  servidor_id   NUMBER REFERENCES servidores,
  titulo        VARCHAR2(200) NOT NULL,
  prioridade    VARCHAR2(10)  NOT NULL,
  aberto_por    VARCHAR2(60)  NOT NULL,
  aberto_em     TIMESTAMP DEFAULT SYSTIMESTAMP
);
COMMENT ON TABLE chamados IS 'Chamados abertos para a operação';

CREATE TABLE auditoria_agente (
  evento_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  quando        TIMESTAMP DEFAULT SYSTIMESTAMP,
  ferramenta    VARCHAR2(60),
  entrada       VARCHAR2(4000),
  resultado     VARCHAR2(4000)
);

INSERT INTO servidores (hostname, ambiente, nuvem, criticidade, dono_time) VALUES ('erp-db-01',    'PROD', 'OCI',   'ALTA',  'Banco de Dados');
INSERT INTO servidores (hostname, ambiente, nuvem, criticidade, dono_time) VALUES ('erp-app-01',   'PROD', 'OCI',   'ALTA',  'Aplicações');
INSERT INTO servidores (hostname, ambiente, nuvem, criticidade, dono_time) VALUES ('portal-web-01','PROD', 'GCP',   'ALTA',  'Plataforma');
INSERT INTO servidores (hostname, ambiente, nuvem, criticidade, dono_time) VALUES ('bi-etl-01',    'PROD', 'AZURE', 'MEDIA', 'Dados');
INSERT INTO servidores (hostname, ambiente, nuvem, criticidade, dono_time) VALUES ('portal-web-hml','HML', 'GCP',   'BAIXA', 'Plataforma');
INSERT INTO servidores (hostname, ambiente, nuvem, criticidade, dono_time) VALUES ('n8n-01',       'PROD', 'OCI',   'MEDIA', 'Automação');

INSERT INTO incidentes (servidor_id, aberto_em, resolvido_em, severidade, categoria, descricao) VALUES (1, SYSTIMESTAMP - INTERVAL '3' DAY, SYSTIMESTAMP - INTERVAL '70' HOUR, 'SEV2', 'DISCO', 'Tablespace acima de 90%');
INSERT INTO incidentes (servidor_id, aberto_em, resolvido_em, severidade, categoria, descricao) VALUES (1, SYSTIMESTAMP - INTERVAL '5' HOUR, NULL, 'SEV1', 'DISCO', 'Disco de archive em 97%');
INSERT INTO incidentes (servidor_id, aberto_em, resolvido_em, severidade, categoria, descricao) VALUES (2, SYSTIMESTAMP - INTERVAL '2' DAY, SYSTIMESTAMP - INTERVAL '47' HOUR, 'SEV3', 'CPU', 'CPU acima de 85% por 20 minutos');
INSERT INTO incidentes (servidor_id, aberto_em, resolvido_em, severidade, categoria, descricao) VALUES (3, SYSTIMESTAMP - INTERVAL '1' DAY, NULL, 'SEV2', 'CERTIFICADO', 'Certificado TLS expira em 6 dias');
INSERT INTO incidentes (servidor_id, aberto_em, resolvido_em, severidade, categoria, descricao) VALUES (3, SYSTIMESTAMP - INTERVAL '6' DAY, SYSTIMESTAMP - INTERVAL '6' DAY + INTERVAL '40' MINUTE, 'SEV3', 'REDE', 'Latência alta para o load balancer');
INSERT INTO incidentes (servidor_id, aberto_em, resolvido_em, severidade, categoria, descricao) VALUES (4, SYSTIMESTAMP - INTERVAL '10' HOUR, NULL, 'SEV3', 'APLICACAO', 'Job de carga noturna falhou');
INSERT INTO incidentes (servidor_id, aberto_em, resolvido_em, severidade, categoria, descricao) VALUES (6, SYSTIMESTAMP - INTERVAL '4' DAY, SYSTIMESTAMP - INTERVAL '4' DAY + INTERVAL '15' MINUTE, 'SEV3', 'APLICACAO', 'Workflow parado por credencial expirada');
COMMIT;
