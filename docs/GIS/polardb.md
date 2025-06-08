```bash

docker pull polardb/polardb_pg_local_instance:15

docker run -it --rm \
    --cap-add=SYS_PTRACE --privileged=true \
    --env POLARDB_PORT=5432 \
    --env POLARDB_USER=postgres \
    --env POLARDB_PASSWORD=Superman@2021 \
    -v ${your_data_dir}:/var/polardb \
    polardb/polardb_pg_local_instance:15

```