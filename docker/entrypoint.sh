#!/usr/bin/env bash
set -euo pipefail

export AIRFLOW_HOME="${AIRFLOW_HOME:-/usr/local/airflow}"

# Mensagem de ambiente
echo "AIRFLOW_HOME=${AIRFLOW_HOME}"

# Aguarda o banco ficar disponível (Railway Postgres)
# Requer que a conexão esteja em AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
if [[ -z "${AIRFLOW__DATABASE__SQL_ALCHEMY_CONN:-}" ]]; then
  echo "ERRO: AIRFLOW__DATABASE__SQL_ALCHEMY_CONN não definido. Defina a URL do Postgres do Railway." >&2
  exit 1
fi

# Tenta checar o DB algumas vezes
for i in {1..20}; do
  if airflow db check >/dev/null 2>&1; then
    echo "Banco disponível."
    break
  fi
  echo "Aguardando banco... ($i)"
  sleep 3
  if [[ $i -eq 20 ]]; then
    echo "Timeout aguardando banco" >&2
    exit 1
  fi
done

# Migra o banco
echo "Executando migrations do Airflow..."
airflow db migrate

# Cria usuário admin (idempotente)
: "${AIRFLOW_ADMIN_USERNAME:=admin}"
: "${AIRFLOW_ADMIN_PASSWORD:=admin}"
: "${AIRFLOW_ADMIN_EMAIL:=admin@example.com}"

airflow users create \
  --role Admin \
  --username "$AIRFLOW_ADMIN_USERNAME" \
  --password "$AIRFLOW_ADMIN_PASSWORD" \
  --firstname Admin \
  --lastname User \
  --email "$AIRFLOW_ADMIN_EMAIL" || true

# Inicia o scheduler em segundo plano
echo "Iniciando scheduler..."
airflow scheduler &

# Inicia o webserver em primeiro plano
PORT="${PORT:-8080}"
echo "Iniciando webserver na porta ${PORT}..."
exec airflow webserver --port "$PORT"
