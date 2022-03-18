#!/bin/bash
#set -x
#set -e
set -x

HADOOP_BIN="/home/recsys/hadoop-lt/bin/hadoop"
JAR_PATH="/home/recsys/hadoop-lt/share/hadoop/tools/lib/hadoop-streaming-2.5.2.jar"

WORK_DIR="/home/recsys/guofangfang/interest_analyze/"
interest_user_local_file=${WORK_DIR}"/data/avg_15_days_interest_user"

#date_str=`date -d" 2 day ago" +"%Y-%m-%d"`
input_hdfs_path="/datastream/recsys/news/recom/"${date_str}"/"
input_hdfs_path="/datastream/recsys/news/result/"

input_path="/user/recsys/guofangfang/test_input/"
output_path="/user/recsys/guofangfang/test_output/"

analyze_recom_py="analyze_recom_distri.py"
reducer_file="reducer_in_one.py"
${HADOOP_BIN} fs -rmr ${output_path}

## the following is same 2
    #-jobconf num.key.fields.for.partition=1 \
    #-jobconf mapred.text.key.partitioner.options="-k1,1" \

## 
    ###-D stream.map.input.ignoreKey=true \
        ### -jobconf mapred.text.key.partitioner.options.2="-k1,1" 
    ##-jobconf stream.num.map.output.key.fields=2 \
${HADOOP_BIN} jar ${JAR_PATH} \
    -D mapred.job.name="statistic_interest_article" \
    -D mapred.reduce.tasks=1 \
    -input ${input_path} \
    -output ${output_path} \
    -mapper "cat" \
    -reducer "cat" \
    -jobconf stream.num.map.output.key.fields=2 \
    -jobconf mapred.text.key.partitioner.options="-k1,1" \
    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
    -jobconf mapred.text.key.comparator.options="-k1,1 -k2,2n" \
    -jobconf mapred.output.key.comparator.class=org.apache.hadoop.mapred.lib.KeyFieldBasedComparator
    ##-file "/home/recsys/guofangfang/data_analyze/py/ifs_grouper.py"
# -inputformat com.hadoop.mapred.DeprecatedLzoTextInputFormat \

if [ $? != 0 ];then
    echo "hadoop failed!"
    exit 1
fi
