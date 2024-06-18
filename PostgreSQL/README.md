psql (PostgreSQL) 15.3 (Debian 15.3-1.pgdg110+1)


## primary 폴더 구성  
( 2개의 초기화 파일 생성 : init.sql, set_pg_hba.sh)

(파일 명은 사실 딱히 상관 없지만 확장자는 중요)

(postgresql.conf 파일을 생성 후 볼륨 처리하여 구성할 수 도 있지만,  포스트그리스는 구성파일과 데이터파일의 디렉토리가 같기 때문에 디비가 시작될 때 볼륨 바인딩된 파일 때문에 디렉토리가 비어있지 않다는 에러가 발생한다. 따라서 아래처럼 초기화 sql문을 작성하여 컨테이너가 시작될 때 실행되도록 해주어야 한다) 

### ① init.sql 파일 내용

```sql
# replica 라는 유저를 만들고 REPLICATION, LOGIN 권한을 부여한다,
CREATE ROLE replica WITH REPLICATION PASSWORD 'madcoder' LOGIN;

#WAL(Write-Ahead Logging) 
# -- Set wal_level
ALTER SYSTEM SET wal_level = 'replica';

# -- Set max_wal_senders
ALTER SYSTEM SET max_wal_senders = 10;

# -- Set wal_keep_size
ALTER SYSTEM SET wal_keep_size = '64MB';

# -- Listen on all addresses
ALTER SYSTEM SET listen_addresses = '*';

# -- Reload configuration to apply changes
SELECT pg_reload_conf();
```

### ② set_pg_hba.sh 파일 내용
```sql
#!/bin/bash
echo "host replication replica 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf
```

## replica 폴더 구성  
( 1개의 초기화 파일 생성 : init.sh)

```bash
#!/bin/bash
set -e

# Wait for the primary server to be ready
export PGPASSWORD="madcoder"
until psql -h "$PRIMARY_HOST" -U "keti_root" -d "keti_3pdx" -c '\q'; do
  >&2 echo "Primary is unavailable - sleeping"
  sleep 1
done

# Stop PostgreSQL server
pg_ctl -D "$PGDATA" -m fast -w stop

# Clear the data directory ★매우 중요★
rm -rf "$PGDATA"/*

# Backup from primary
pg_basebackup -h "$PRIMARY_HOST" -D "$PGDATA" -U replica -Fp -Xs -P -R

# Start PostgreSQL server
pg_ctl -D "$PGDATA" -o "-c config_file=$PGDATA/postgresql.conf" -w start
```

## Replica - [init.sh](http://init.sh) 코드 설명

```bash
until psql -h "$PRIMARY_HOST" -U "keti_root" -d "keti_3pdx" -c '\q'; do
  >&2 echo "Primary is unavailable - sleeping"
  sleep 1
done
```

- `psql`: PostgreSQL의 클라이언트 명령어로, 데이터베이스에 연결하여 SQL 명령을 실행할 수 있습니다.
    - `h "$PRIMARY_HOST"`: primary 서버의 호스트 이름 또는 IP 주소를 지정합니다. `$PRIMARY_HOST`는 환경 변수로 설정된 primary 서버의 주소를 의미합니다.
    - `U "keti_root"`: 데이터베이스 사용자 이름을 지정합니다. 여기서는 `keti_root` 사용자로 접속합니다.
    - `d "keti_3pdx"`: 접속할 데이터베이스의 이름을 지정합니다. 여기서는 `keti_3pdx` 데이터베이스에 접속합니다.
    - `c '\q'`: `\q` 명령을 실행하여 데이터베이스 연결을 종료합니다. 이 명령은 단순히 데이터베이스가 접속 가능한지 확인하는 데 사용됩니다.

```bash
pg_ctl -D "$PGDATA" -m fast -w stop
```

- `pg_ctl`: PostgreSQL 서버를 제어하는 명령어입니다.
    - `D "$PGDATA"`: 데이터 디렉토리 경로를 지정합니다. `$PGDATA`는 PostgreSQL 데이터가 저장된 디렉토리 경로를 의미합니다.
    - `m fast`: 서버를 빠르게 종료합니다. 이 옵션은 현재 실행 중인 트랜잭션을 중단하고 즉시 종료합니다.
    - `w`: 서버 종료를 기다립니다. 서버가 완전히 종료될 때까지 스크립트 실행을 멈춥니다.
    - `stop`: 서버를 중지하는 명령어입니다.

```bash
pg_basebackup -h "$PRIMARY_HOST" -D "$PGDATA" -U replica -Fp -Xs -P -R
```

- `pg_basebackup`: PostgreSQL 기본 백업 도구입니다.
    - `h "$PRIMARY_HOST"`: primary 서버의 호스트 이름 또는 IP 주소를 지정합니다. `$PRIMARY_HOST`는 환경 변수로 설정된 primary 서버의 주소를 의미합니다.
    - `D "$PGDATA"`: 백업 데이터를 저장할 디렉토리 경로를 지정합니다. `$PGDATA`는 PostgreSQL 데이터 디렉토리 경로를 의미합니다.
    - `U replica`: 백업을 수행할 사용자 이름을 지정합니다. 여기서는 `replica` 사용자로 백업을 수행합니다.
    - `Fp`: 백업 형식을 지정합니다. `Fp`는 plain 형식을 의미하며, 파일 시스템의 각 데이터 파일을 그대로 백업합니다.
    - `Xs`: WAL(Write-Ahead Logging) 파일을 포함시킵니다. `Xs`는 스트리밍 모드를 의미하며, WAL 파일을 백업에 포함시키는 동시에 스트리밍하여 동기화 상태를 유지합니다.
    - `P`: 진행 상황을 표시합니다. 백업 진행률을 출력하여 백업 상태를 모니터링할 수 있게 합니다.
    - `R`: `recovery.conf` 파일을 생성하여 백업된 데이터 디렉토리를 복구 모드로 설정합니다. 이 옵션을 사용하면 replica 서버가 시작될 때 자동으로 primary 서버에서 스트리밍 복제를 수행하도록 설정됩니다.
