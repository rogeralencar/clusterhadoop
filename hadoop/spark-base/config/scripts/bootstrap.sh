#!/bin/bash

# Este trecho rodará independente de termos um container master ou
# worker. Necesário para funcionamento do HDFS e para comunicação
# dos containers/nodes.
/etc/init.d/ssh start

# Abaixo temos o trecho que rodará apenas no master.
if [[ $HOSTNAME = spark-master ]]; then
    
    # Formatamos o namenode
    hdfs namenode -format

    # Iniciamos os serviços
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/sbin/start-yarn.sh

    # Criação de diretórios no ambiente distribuído do HDFS
    hdfs dfs -mkdir /spark_logs
    hdfs dfs -mkdir /datasets
    hdfs dfs -mkdir /datasets_processed
    hdfs dfs -mkdir /lab08

    # Envia os arquivos da pasta user_data para o HDFS
   
    hdfs dfs -put /user_data/lab08/* /lab08 
   
    # Caso mantenha notebooks personalizados na pasta que tem bind mount com o 
    # container /user_data, o trecho abaixo automaticamente fará o processo de 
    # confiar em todos os notebooks, também liberando o server do jupyter de
    # solicitar um token
    cd /user_data
    jupyter trust *.ipynb
    jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &

    # Inicializa o servi�o do FastAPI
    uvicorn api:app --host 0.0.0.0 --port 8000 --reload

    while ! hdfs dfs -test -d /datasets;
    do
        echo "datasets doesn't exist yet... retrying"
        sleep 1;
    done

    while ! hdfs dfs -mkdir -p /spark_logs;
    do
        echo "Failed creating /spark_logs hdfs dir"
        sleep 1;
    done

# E abaixo temos o trecho que rodará nos workers
else

    # Configs de HDFS nos dataNodes (workers)
    $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode &
    $HADOOP_HOME/bin/yarn nodemanager &
    
fi

while :; do sleep 2073600; done
